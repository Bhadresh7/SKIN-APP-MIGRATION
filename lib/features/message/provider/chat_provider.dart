import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;

import '../screens/image_preview_screen.dart';

class ChatProvider extends ChangeNotifier {
  StreamSubscription<List<SharedFile>>? _sharingIntentSubscription;
  List<SharedFile>? sharedFiles;
  List<String> sharedValues = [];

  final TextEditingController messageController = TextEditingController();

  String? _receivedText;
  String? _receivedImagePath;
  bool _isLoadingMetadata = false;
  String? _imageMetadata;

  // Getters
  String? get receivedText => _receivedText;
  String? get receivedImagePath => _receivedImagePath;
  bool get isLoadingMetadata => _isLoadingMetadata;
  String? get imageMetadata => _imageMetadata;


  void initializeSharingIntent(context) {
    // Listen for new media shared while app is running
    _sharingIntentSubscription = FlutterSharingIntent.instance
        .getMediaStream()
        .listen(
          (List<SharedFile> files) {
        _updateSharedFiles(files,context);
      },
      onError: (err) {
        debugPrint("Error in getMediaStream: $err");
      },
    );

    // Handle media when app is launched via sharing
    FlutterSharingIntent.instance
        .getInitialSharing()
        .then( (List<SharedFile> files) {
      _updateSharedFiles(files,context);
    },)
        .catchError((err) {
      debugPrint("Error in getInitialSharing: $err");
    });
  }

  void _updateSharedFiles(List<SharedFile> files,context) {
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
                builder: (_) => ImagePreviewScreen(
              image: File(imagePath),
                  // initialText: ,


            ),
            ));
        } else {
          debugPrint("Unsupported media type: ${firstFile.type}");
        }
      }
    }
  }

  void clear() {
    sharedFiles = null;
    sharedValues = [];
    notifyListeners();
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

    // Simulated metadata fetch
    await Future.delayed(const Duration(milliseconds: 500));

    _isLoadingMetadata = false;
    notifyListeners();
  }

  void clearMetadata() {
    _imageMetadata = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sharingIntentSubscription?.cancel();
    messageController.dispose();
    super.dispose();
  }
}
