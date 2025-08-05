import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:receive_intent/receive_intent.dart' as receive_intent;
import 'package:skin_app_migration/core/helpers/app_logger.dart';
import 'package:skin_app_migration/core/service/local_db_service.dart';

import '../models/chat_message_model.dart';
import '../screens/image_preview_screen.dart';

class ChatProvider extends ChangeNotifier {
  // Sharing intent
  StreamSubscription<List<SharedFile>>? _sharingIntentSubscription;
  List<SharedFile>? sharedFiles;
  List<String> sharedValues = [];
  final TextEditingController messageController = TextEditingController();

  String? _receivedText;
  bool _isLoadingMetadata = false;
  String? _imageMetadata;

  // Firestore sync and local storage
  List<ChatMessageModel> _messages = [];
  Set<String> _syncedMessageIds = {};
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  // Public getters
  List<ChatMessageModel> get messages => _messages;
  bool get isLoadingMetadata => _isLoadingMetadata;
  String? get imageMetadata => _imageMetadata;

  // ==== SHARING INTENT HANDLING ====

  void initializeSharingIntent(BuildContext context) {
    try {
      AppLoggerHelper.logInfo('Initializing sharing intent...');

      _sharingIntentSubscription = FlutterSharingIntent.instance
          .getMediaStream()
          .listen(
            (List<SharedFile> files) {
              AppLoggerHelper.logInfo(
                'Received ${files.length} shared files from media stream',
              );
              _updateSharedFiles(files, context);
            },
            onError: (err) {
              AppLoggerHelper.logError("Error in getMediaStream: $err");
            },
          );

      FlutterSharingIntent.instance
          .getInitialSharing()
          .then((files) {
            AppLoggerHelper.logInfo(
              'Received ${files.length} files from initial sharing',
            );
            _updateSharedFiles(files, context);
          })
          .catchError((err) {
            AppLoggerHelper.logError("Error in getInitialSharing: $err");
          });

      AppLoggerHelper.logInfo('Sharing intent initialized successfully');
    } catch (e) {
      AppLoggerHelper.logError('Failed to initialize sharing intent: $e');
    }
  }

  void _updateSharedFiles(List<SharedFile> files, BuildContext context) {
    try {
      final newSharedValues = files.map((file) => file.value ?? "").toList();

      AppLoggerHelper.logInfo(
        'Updating shared files. New values: $newSharedValues',
      );

      if (sharedValues != newSharedValues) {
        sharedFiles = files;
        sharedValues = newSharedValues;
        notifyListeners();

        // Check if files list is not empty before accessing
        if (files.isNotEmpty) {
          final firstFile = files[0];
          AppLoggerHelper.logInfo(
            'Processing first shared file: ${firstFile.type}',
          );

          if (firstFile.type == SharedMediaType.TEXT) {
            messageController.text = firstFile.value ?? "";
            AppLoggerHelper.logInfo('Set text content to message controller');
          } else if (firstFile.type == SharedMediaType.IMAGE) {
            final imagePath = firstFile.value;
            if (imagePath != null && imagePath.isNotEmpty) {
              AppLoggerHelper.logInfo(
                'Navigating to image preview for: $imagePath',
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImagePreviewScreen(image: File(imagePath)),
                ),
              );
            }
          }
        } else {
          AppLoggerHelper.logInfo('No shared files to process');
        }
      } else {
        AppLoggerHelper.logInfo('Shared values unchanged, skipping update');
      }
    } catch (e) {
      AppLoggerHelper.logError('Error updating shared files: $e');
    }
  }

  void initIntentHandling() {
    try {
      AppLoggerHelper.logInfo('Initializing intent handling...');

      receive_intent.ReceiveIntent.receivedIntentStream.listen(_handleIntent);
      receive_intent.ReceiveIntent.getInitialIntent().then(_handleIntent);

      AppLoggerHelper.logInfo('Intent handling initialized successfully');
    } catch (e) {
      AppLoggerHelper.logError('Failed to initialize intent handling: $e');
    }
  }

  void _handleIntent(receive_intent.Intent? intent) {
    try {
      if (intent == null) {
        AppLoggerHelper.logInfo('Received null intent');
        return;
      }

      AppLoggerHelper.logInfo('Handling intent: ${intent.action}');

      _receivedText = intent.extra?['android.intent.extra.TEXT']?.toString();
      _imageMetadata = _receivedText;

      AppLoggerHelper.logInfo('Received text from intent: $_receivedText');

      notifyListeners();

      if (_receivedText != null && _isValidUrl(_receivedText!)) {
        AppLoggerHelper.logInfo('Valid URL detected, fetching metadata...');
        fetchLinkMetadata(_receivedText!);
      }
    } catch (e) {
      AppLoggerHelper.logError('Error handling intent: $e');
    }
  }

  bool _isValidUrl(String text) {
    try {
      final uri = Uri.parse(text);
      final isValid = uri.hasScheme && uri.hasAuthority;
      AppLoggerHelper.logInfo('URL validation for "$text": $isValid');
      return isValid;
    } catch (e) {
      AppLoggerHelper.logInfo('Invalid URL format: $text');
      return false;
    }
  }

  Future<void> fetchLinkMetadata(String url) async {
    try {
      AppLoggerHelper.logInfo('Fetching metadata for URL: $url');
      _isLoadingMetadata = true;
      notifyListeners();

      // Simulate metadata fetching
      await Future.delayed(const Duration(milliseconds: 500));

      _isLoadingMetadata = false;
      notifyListeners();
      AppLoggerHelper.logInfo('Metadata fetching completed for: $url');
    } catch (e) {
      AppLoggerHelper.logError('Error fetching metadata: $e');
      _isLoadingMetadata = false;
      notifyListeners();
    }
  }

  void clearMetadata() {
    AppLoggerHelper.logInfo('Clearing metadata');
    _imageMetadata = null;
    notifyListeners();
  }

  void clear() {
    AppLoggerHelper.logInfo('Clearing shared files and values');
    sharedFiles = null;
    sharedValues = [];
    notifyListeners();
  }

  // ==== CHAT SYNC & DB ====

  // Load Messages
  Future<void> loadMessages() async {
    try {
      AppLoggerHelper.logInfo('Loading messages from local DB...');

      _messages = await LocalDBService().getAllMessages();
      _syncedMessageIds = _messages
          .map((m) => '${m.senderId}_${m.createdAt}')
          .toSet();

      AppLoggerHelper.logInfo(
        'Loaded ${_messages.length} messages from local DB',
      );
      notifyListeners();
    } catch (e) {
      AppLoggerHelper.logError('Failed to load messages: $e');
    }
  }

  // Add Message
  Future<void> addMessage(ChatMessageModel message) async {
    try {
      AppLoggerHelper.logInfo('Adding new message to local DB...');

      await LocalDBService().insertChatMessage(message);
      _messages.add(message);
      _syncedMessageIds.add('${message.senderId}_${message.createdAt}');
      notifyListeners();

      AppLoggerHelper.logInfo('New message added: ${message.metadata?.text}');
    } catch (e) {
      AppLoggerHelper.logError('Failed to insert message: $e');
    }
  }

  // Safe method to create ChatMessageModel from Firestore data
  ChatMessageModel? _createMessageFromFirestoreData(
    Map<String, dynamic> data,
    String docId,
  ) {
    try {
      // Validate required fields and provide defaults for null values
      final messageData = <String, dynamic>{
        'id': data['id'] ?? docId, // Use document ID as fallback
        'senderId': data['senderId'] ?? data['id'] ?? docId,
        'createdAt':
            data['createdAt'] ??
            data['ts'] ??
            DateTime.now().millisecondsSinceEpoch,
        'timestamp':
            data['timestamp'] ??
            data['ts'] ??
            DateTime.now().millisecondsSinceEpoch,
        'name': data['name'] ?? 'Unknown User',
        'metadata': data['metadata'] ?? {},
      };

      // Add any other fields that exist in the original data
      for (final entry in data.entries) {
        if (!messageData.containsKey(entry.key)) {
          messageData[entry.key] = entry.value;
        }
      }

      return ChatMessageModel.fromJson(messageData);
    } catch (e) {
      AppLoggerHelper.logError(
        'Error creating message from Firestore data: $e',
      );
      AppLoggerHelper.logError('Document ID: $docId');
      AppLoggerHelper.logError('Raw data: $data');
      return null;
    }
  }

  // Firestore Listener
  void startFirestoreListener() {
    try {
      AppLoggerHelper.logInfo('Starting Firestore listener...');

      _firestoreSubscription = FirebaseFirestore.instance
          .collection('chats')
          .orderBy('ts')
          .snapshots()
          .listen(
            (QuerySnapshot snapshot) async {
              try {
                AppLoggerHelper.logInfo(
                  'Received Firestore snapshot with ${snapshot.docs.length} documents',
                );

                final localMessages = await LocalDBService().getAllMessages();
                final lastLocalTimestamp = localMessages.isNotEmpty
                    ? localMessages.map((m) => m.timestamp).reduce(max)
                    : 0;

                AppLoggerHelper.logInfo(
                  'Last local timestamp: $lastLocalTimestamp',
                );

                int newMessagesCount = 0;
                int skippedCount = 0;

                for (var doc in snapshot.docs) {
                  try {
                    final data = doc.data() as Map<String, dynamic>;
                    final remoteMessage = _createMessageFromFirestoreData(
                      data,
                      doc.id,
                    );

                    if (remoteMessage == null) {
                      skippedCount++;
                      AppLoggerHelper.logInfo(
                        'Skipping document ${doc.id} due to parsing error',
                      );
                      continue;
                    }

                    if (remoteMessage.timestamp > lastLocalTimestamp) {
                      final exists = localMessages.any(
                        (m) => m.id == remoteMessage.id,
                      );
                      if (!exists) {
                        await LocalDBService().insertMessage(remoteMessage);
                        newMessagesCount++;
                      }
                    }
                  } catch (e) {
                    skippedCount++;
                    AppLoggerHelper.logError(
                      'Error processing document ${doc.id}: $e',
                    );
                  }
                }

                if (newMessagesCount > 0) {
                  AppLoggerHelper.logInfo(
                    'Processed $newMessagesCount new messages',
                  );
                  await loadMessages(); // Reload local DB to reflect new additions
                }

                if (skippedCount > 0) {
                  AppLoggerHelper.logInfo(
                    'Skipped $skippedCount documents due to errors',
                  );
                }
              } catch (e) {
                AppLoggerHelper.logError('Error in Firestore listener: $e');
              }
            },
            onError: (error) {
              AppLoggerHelper.logError('Firestore listener error: $error');
            },
          );

      AppLoggerHelper.logInfo('Firestore listener started successfully');
    } catch (e) {
      AppLoggerHelper.logError('Failed to start Firestore listener: $e');
    }
  }

  // Sync Messages from Firestore
  Future<void> syncNewMessagesFromFirestore() async {
    try {
      AppLoggerHelper.logInfo('Starting Firestore sync...');

      final localMessages = await LocalDBService().getAllMessages();
      final lastLocalTs = localMessages.isNotEmpty
          ? localMessages
                .map((m) => m.createdAt)
                .reduce((a, b) => a > b ? a : b)
          : 0;

      AppLoggerHelper.logInfo('Syncing messages newer than: $lastLocalTs');

      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('ts', isGreaterThan: lastLocalTs)
          .orderBy('ts')
          .get();

      AppLoggerHelper.logInfo(
        'Found ${querySnapshot.docs.length} new messages to sync',
      );

      int syncedCount = 0;
      int skippedCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final message = _createMessageFromFirestoreData(data, doc.id);

          if (message != null) {
            await LocalDBService().insertChatMessage(message);
            syncedCount++;
          } else {
            skippedCount++;
          }
        } catch (e) {
          skippedCount++;
          AppLoggerHelper.logError('Error syncing message ${doc.id}: $e');
        }
      }

      _messages = await LocalDBService().getAllMessages();
      notifyListeners();

      AppLoggerHelper.logInfo(
        'Firestore sync completed. Synced $syncedCount messages',
      );
      if (skippedCount > 0) {
        AppLoggerHelper.logInfo('Skipped $skippedCount messages due to errors');
      }
    } catch (e) {
      AppLoggerHelper.logError('Firestore sync failed: $e');
    }
  }

  // ==== STREAM PAGINATION SUPPORT ====

  // Method to get real-time messages stream for pagination
  Stream<List<ChatMessageModel>> getMessagesStream({int limit = 20}) {
    return FirebaseFirestore.instance
        .collection('chats')
        .orderBy('ts', descending: true)
        .limit(limit)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _createMessageFromFirestoreData(data, doc.id);
      }).where((message) => message != null).cast<ChatMessageModel>().toList();
    });
  }

  // Method to get paginated messages with document tracking
  Future<Map<String, dynamic>> getPaginatedMessagesWithDocs({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('chats')
          .orderBy('ts', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      
      final messages = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _createMessageFromFirestoreData(data, doc.id);
      }).where((message) => message != null).cast<ChatMessageModel>().toList();

      return {
        'messages': messages,
        'documents': querySnapshot.docs,
        'hasMore': querySnapshot.docs.length >= limit,
      };
    } catch (e) {
      AppLoggerHelper.logError('Error getting paginated messages: $e');
      return {
        'messages': <ChatMessageModel>[],
        'documents': <DocumentSnapshot>[],
        'hasMore': false,
      };
    }
  }

  // Method to get paginated messages
  Future<List<ChatMessageModel>> getPaginatedMessages({
    DocumentSnapshot? startAfter,
    int limit = 20,
  }) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('chats')
          .orderBy('ts', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _createMessageFromFirestoreData(data, doc.id);
      }).where((message) => message != null).cast<ChatMessageModel>().toList();
    } catch (e) {
      AppLoggerHelper.logError('Error getting paginated messages: $e');
      return [];
    }
  }

  // Method to add message and sync with Firestore
  Future<void> sendMessage(ChatMessageModel message) async {
    try {
      AppLoggerHelper.logInfo('Sending message: ${message.metadata?.text}');
      
      // Add to local storage first
      await addMessage(message);
      
      // Add to Firestore
      await FirebaseFirestore.instance
          .collection('chats')
          .add(message.toJson());
      
      AppLoggerHelper.logInfo('Message sent successfully');
    } catch (e) {
      AppLoggerHelper.logError('Error sending message: $e');
    }
  }

  // Method to get document by message data
  Future<DocumentSnapshot?> getDocumentByMessage(ChatMessageModel message) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('ts', isEqualTo: message.createdAt)
          .where('id', isEqualTo: message.senderId)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty ? querySnapshot.docs.first : null;
    } catch (e) {
      AppLoggerHelper.logError('Error getting document by message: $e');
      return null;
    }
  }

  @override
  void dispose() {
    AppLoggerHelper.logInfo('Disposing ChatProvider...');

    try {
      _sharingIntentSubscription?.cancel();
      _firestoreSubscription?.cancel();
      messageController.dispose();

      AppLoggerHelper.logInfo('ChatProvider disposed successfully');
    } catch (e) {
      AppLoggerHelper.logError('Error during dispose: $e');
    }

    super.dispose();
  }
}
