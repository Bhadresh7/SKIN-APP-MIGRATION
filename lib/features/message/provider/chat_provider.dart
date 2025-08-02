import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;
import 'package:skin_app_migration/core/helpers/app_logger_helper.dart';
import 'package:skin_app_migration/core/service/local_db_service.dart';
import 'package:skin_app_migration/features/message/models/chat_message_model.dart';
import 'package:skin_app_migration/features/message/screens/image_preview_screen.dart';

class ChatProvider extends ChangeNotifier {
  StreamSubscription<List<SharedFile>>? _sharingIntentSubscription;
  List<SharedFile>? sharedFiles;
  List<String> sharedValues = [];

  final TextEditingController messageController = TextEditingController();

  String? _receivedText;
  bool _isLoadingMetadata = false;
  String? _imageMetadata;

  List<ChatMessageModel> _messages = [];

  List<ChatMessageModel> get messages => _messages;

  // === INIT SHARING & INTENTS ===
  void initializeSharingIntent(BuildContext context) {
    _sharingIntentSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedFile> files) {
            _updateSharedFiles(files, context);
          },
          onError: (err) {
            debugPrint("Error in getMediaStream: $err");
          },
        );

    FlutterSharingIntent.instance
        .getInitialSharing()
        .then((List<SharedFile> files) {
          _updateSharedFiles(files, context);
        })
        .catchError((err) {
          debugPrint("Error in getInitialSharing: $err");
        });
  }

  void _updateSharedFiles(List<SharedFile> files, BuildContext context) {
    final newSharedValues = files.map((file) => file.value ?? "").toList();

    if (sharedValues != newSharedValues) {
      sharedFiles = files;
      sharedValues = newSharedValues;
      notifyListeners();

      final firstFile = sharedFiles?[0];
      if (firstFile != null) {
        if (firstFile.type == SharedMediaType.TEXT) {
          messageController.text = firstFile.value ?? "";
        } else if (firstFile.type == SharedMediaType.IMAGE) {
          final imagePath = sharedFiles![0].value!;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImagePreviewScreen(image: File(imagePath)),
            ),
          );
        } else {
          debugPrint("Unsupported media type: ${firstFile.type}");
        }
      }
    }
  }

  void initIntentHandling() {
    receive_intent.ReceiveIntent.receivedIntentStream.listen(_handleIntent);
    receive_intent.ReceiveIntent.getInitialIntent().then(_handleIntent);
  }

  void _handleIntent(receive_intent.Intent? intent) {
    if (intent == null) return;

    _receivedText = intent.extra?['android.intent.extra.TEXT']?.toString();
    _imageMetadata = _receivedText;
    notifyListeners();

    if (_receivedText != null && _isValidUrl(_receivedText!)) {
      fetchLinkMetadata(_receivedText!);
    }
  }

  bool _isValidUrl(String text) {
    try {
      final uri = Uri.parse(text);
      return uri.hasScheme && uri.hasAuthority;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchLinkMetadata(String url) async {
    _isLoadingMetadata = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoadingMetadata = false;
    notifyListeners();
  }

  void clearMetadata() {
    _imageMetadata = null;
    notifyListeners();
  }

  void clear() {
    sharedFiles = null;
    sharedValues = [];
    notifyListeners();
  }

  // === CHAT LOGIC ===

  // Load All Chat Messages
  Future<void> loadMessages() async {
    _messages = await LocalDBService().getAllMessages();

    AppLoggerHelper.logInfo(
      'Loaded ${_messages.length} messages from local DB',
    );

    for (final msg in _messages) {
      AppLoggerHelper.logInfo(
        '🟩 Message: id=${msg.senderId}, name=${msg.name}, ts=${msg.createdAt}, text=${msg.metadata?.text}, url=${msg.metadata?.url}, img=${msg.metadata?.img}',
      );
    }

    notifyListeners();
  }

  // Add Chat Messages
  Future<void> addMessage(ChatMessageModel message) async {
    try {
      await LocalDBService().insertChatMessage(message);
      _messages.add(message);
      notifyListeners();

      AppLoggerHelper.logInfo(
        'New message added locally: ${message.metadata?.text}',
      );

      AppLoggerHelper.logInfo(
        '📥 Local DB Inserted Message: ${message.toJson()}',
      );
    } catch (e) {
      AppLoggerHelper.logError('Failed to insert chat message: $e');
    }
  }

  // Sync Firestore to Local
  Future<void> syncFirestoreToLocal() async {
    try {
      final localMessages = await LocalDBService().getAllMessages();
      final lastLocalTs = localMessages.isNotEmpty
          ? localMessages
                .map((m) => m.createdAt)
                .reduce((a, b) => a > b ? a : b)
          : 0;

      AppLoggerHelper.logInfo('Last local timestamp: $lastLocalTs');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('ts', isGreaterThan: lastLocalTs)
          .orderBy('ts')
          .get();

      if (querySnapshot.docs.isEmpty) {
        AppLoggerHelper.logInfo('No new Firestore messages to sync.');
        return;
      }

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final message = ChatMessageModel.fromJson(data);

        await LocalDBService().insertChatMessage(message);
        AppLoggerHelper.logInfo(
          'Synced Firestore message: ${message.metadata?.text}',
        );
      }

      // Reload all local messages to reflect new insertions
      _messages = await LocalDBService().getAllMessages();
      notifyListeners();
    } catch (e) {
      AppLoggerHelper.logError('Failed to sync messages from Firestore: $e');
    }
  }

  @override
  void dispose() {
    _sharingIntentSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }
}
