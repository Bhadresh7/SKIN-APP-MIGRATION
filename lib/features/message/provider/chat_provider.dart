import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("chats");

  ValueNotifier<double?> uploadProgressNotifier = ValueNotifier(null);

  // Message notifier - always represents local storage state
  StreamSubscription? _messageSubscription;

  // 📄 Pagination state
  bool _isLoadingOlderMessages = false;
  bool _hasMoreMessages = true;
  final int _messagesPerPage = 30;

  // 🆕 Session tracking for real-time listening
  int? _realtimeSessionStartTs;
  bool _isListening = false;

  // Getters for pagination state
  bool get isLoadingOlderMessages => _isLoadingOlderMessages;

  bool get hasMoreMessages => _hasMoreMessages;

  Future<void> startRealtimeListener() async {
    if (_isListening) return; // Prevent multiple listeners
    _isListening = true;

    await _messageSubscription?.cancel();

    //  Set session start timestamp to NOW when starting listener
    // _realtimeSessionStartTs = await HiveService.getLastSavedTimestamp();

    /// This handles when the user initially login
    /// The user will not be having the last timestamp
    if (_realtimeSessionStartTs == 0) {
      return;
    }
    print(
      "🕐 Real-time session started at timestamp: $_realtimeSessionStartTs",
    );

    _messageSubscription = _databaseRef
        .orderByChild("ts")
        .startAfter(_realtimeSessionStartTs!)
        .onChildAdded
        .listen(
          (event) => _handleSingleNewMessage(event.snapshot),
          onError: (error) {
            print("❌ Real-time listener error: $error");
            Future.delayed(Duration(seconds: 5), () {
              _isListening = false;
              startRealtimeListener();
            });
          },
          cancelOnError: false,
        );

    _messageSubscription = _databaseRef.onChildRemoved.listen(
      (event) {
        final deletedId = event.snapshot.key;
        if (deletedId != null) {
          print("Message deleted $deletedId");
          removeMessageFromNotifier(deletedId);
          notifyListeners();
        }
      },
      onError: (error) {
        print(error.toString());
      },
    );
  }

  void _handleSingleNewMessage(DataSnapshot snapshot) {
    final data = snapshot.value;
    if (data is! Map || data.isEmpty) {
      print("📭 No message data");
      return;
    }

    // ✅ Process single message (not multiple)
    final messageId = snapshot.key;
    if (messageId == null) return;

    final messageTimestamp =
        data["ts"] ?? DateTime.now().millisecondsSinceEpoch;

    // 🔧 KEY FIX: Only process messages that are truly newer than session start
    if (_realtimeSessionStartTs != null &&
        messageTimestamp <= _realtimeSessionStartTs!) {
      print("⏰ Skipping message from before session start: $messageId");
      return;
    }

    final author = types.User(
      id: data["id"]?.toString() ?? '',
      firstName: data["name"]?.toString() ?? "k",
    );

    final metadata = data["metadata"];

    if (metadata is! Map) return;

    final newMessage = types.CustomMessage(
      id: messageId,
      author: author,
      createdAt: messageTimestamp,
      metadata: {
        "text": metadata["text"],
        "url": metadata["url"],
        "img": metadata["img"],
      },
    );

    print(
      "🔥 New real-time message received: ${metadata["text"] ?? 'No text'}",
    );

    // ✅ Process single message and update UI
    _processSingleNewMessage(newMessage);
  }

  void removeMessageFromNotifier(String messageId) {
    final updatedMessages = messageNotifier.value
        .where((message) => message.id != messageId)
        .toList();

    messageNotifier.value = updatedMessages;
    notifyListeners();
  }
}
