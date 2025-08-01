import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/auth/providers/my_auth_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // late NotificationService service;
  // late TextEditingController messageController;
  // late AutoScrollController _scrollController;
  // late bool isBlockedStatus;
  //
  // int? maxLines;
  // bool _hasHandledSharedFile = false;
  // bool _hasFetchedLinkMetadata = false;
  // bool _hasShownBlockDialog = false;

  // Fixed initState method
  // @override
  // void initState() {
  //   super.initState();
  //
  //   // ✅ Initialize ScrollController first
  //   _scrollController = AutoScrollController();
  //
  //   final FlutterLocalNotificationsPlugin plugin =
  //       FlutterLocalNotificationsPlugin();
  //   plugin.cancelAll();
  //   final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //   chatProvider.startRealtimeListener();
  //   chatProvider.initMessageStream();
  //   print("Hey there init Called");
  //   messageController = TextEditingController();
  //   service = NotificationService();
  //
  //   isBlockedStatus = HiveService.getCurrentUser()?.isBlocked ?? false;
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (mounted) {
  //       final initialMessages = chatProvider.getAllMessagesFromLocalStorage();
  //       chatProvider.messageNotifier.value = initialMessages;
  //     }
  //   });
  //
  //   _scrollController.addListener(_onScroll);
  // }

  //  scroll listener method
  // void _onScroll() {
  //   final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //
  //   // Check if we have messages and can load more
  //   if (!chatProvider.hasMoreMessages || chatProvider.isLoadingOlderMessages) {
  //     return;
  //   }
  //
  //   // Get current messages from the notifier
  //   final messages = chatProvider.messageNotifier.value;
  //   if (messages.isEmpty) return;
  //
  //   // Use AutoScrollController to check if the oldest message is visible
  //   // The key here is to check if we're near the end of the list (oldest messages)
  //   final scrollPosition = _scrollController.position;
  //
  //   // Check if we're at the maximum scroll extent (most reliable)
  //   if (scrollPosition.pixels >= scrollPosition.maxScrollExtent - 50) {
  //     print(
  //       "🔝 User reached the first/oldest message, fetching older messages...",
  //     );
  //     chatProvider.fetchOlderMessages();
  //     return;
  //   }
  // }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //
  //   final shareIntentProvider = Provider.of<ShareIntentProvider>(
  //     context,
  //     listen: false,
  //   );
  //   final chatProvider = Provider.of<ChatProvider>(context, listen: false);
  //   final authProvider = Provider.of<MyAuthProvider>(context, listen: false);
  //   final shareContentProvider = Provider.of<SharedContentProvider>(
  //     context,
  //     listen: false,
  //   );
  //   final sharedFiles = shareIntentProvider.sharedFiles;
  //
  //   print("==============================");
  //   print("SHARED FILES ==>$sharedFiles");
  //   print("_hasHandledSharedFile: $_hasHandledSharedFile");
  //   print("_hasFetchedLinkMetadata: $_hasFetchedLinkMetadata");
  //   print("==============================");
  //
  //   // Only process shared content if we haven't handled it yet and there's actual content
  //   if (authProvider.currentUser?.canPost ?? false) {
  //     if (!_hasHandledSharedFile &&
  //         sharedFiles != null &&
  //         sharedFiles.isNotEmpty) {
  //       final sendingContent = sharedFiles[0];
  //       final isUrl = sendingContent.type == SharedMediaType.URL;
  //
  //       print("url$isUrl--$sendingContent");
  //
  //       if (!isUrl) {
  //         // Mark as handled to prevent multiple dialogs/actions
  //         _hasHandledSharedFile = true;
  //
  //         // Handle image sharing with ImagePreviewScreen
  //         WidgetsBinding.instance.addPostFrameCallback((_) {
  //           final imgFile = File(sendingContent.value ?? "");
  //
  //           // Get initial text from multiple possible sources
  //           String initialText = "";
  //
  //           // Fallback to imageMetadata if no direct text
  //           if (shareContentProvider.imageMetadata != null &&
  //               shareContentProvider.imageMetadata!.isNotEmpty) {
  //             initialText = shareContentProvider.imageMetadata ?? "";
  //           }
  //
  //           print("Initial text for image: '$initialText'");
  //
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => ImagePreviewScreen(
  //                 image: imgFile,
  //                 initialText: initialText.toString(),
  //                 onSend: (caption) async {
  //                   // Handle the image with or without caption
  //                   if (caption.isNotEmpty) {
  //                     // await chatProvider.startRealtimeListener();
  //                     chatProvider.handleImageWithTextMessage(
  //                       authProvider,
  //                       imgFile,
  //                       caption,
  //                     );
  //                   } else {
  //                     // await chatProvider.startRealtimeListener();
  //                     chatProvider.handleImageMessage(authProvider, imgFile);
  //                   }
  //                   // Clean up
  //                   shareIntentProvider.clear();
  //
  //                   // Reset flag after successful send with delay
  //                   Future.delayed(Duration(milliseconds: 300), () {
  //                     if (mounted) {
  //                       _hasHandledSharedFile = false;
  //                       print("🔄 Image shared file flag reset after send");
  //                     }
  //                   });
  //                 },
  //               ),
  //             ),
  //           ).then((_) {
  //             // Handle case where user cancels without sending
  //             shareIntentProvider.clear();
  //
  //             // Reset flag after navigation closes with delay
  //             Future.delayed(Duration(milliseconds: 300), () {
  //               if (mounted) {
  //                 _hasHandledSharedFile = false;
  //                 print("🔄 Image shared file flag reset after cancel");
  //               }
  //             });
  //           });
  //         });
  //       } else {
  //         // Handle URL sharing - FIXED VERSION
  //         if (!_hasFetchedLinkMetadata) {
  //           final url = sendingContent.value!;
  //
  //           // Only mark URL metadata as handled, not the shared file
  //           _hasFetchedLinkMetadata = true;
  //
  //           print("controller int - $messageController");
  //           print("url555555555555555555555555${url}");
  //
  //           // Use postFrameCallback to ensure controller is ready
  //           WidgetsBinding.instance.addPostFrameCallback((_) {
  //             if (mounted && messageController.text != url) {
  //               messageController.text = url;
  //               print("✅ URL set in controller: ${messageController.text}");
  //             }
  //           });
  //
  //           // Clear the share intent after processing URL
  //           shareIntentProvider.clear();
  //           print("✅ Share intent cleared after URL processing");
  //
  //           // Reset the URL metadata flag immediately since we only needed it
  //           // to prevent duplicate URL processing, not to prevent new URL shares
  //           Future.delayed(Duration(milliseconds: 100), () {
  //             if (mounted) {
  //               _hasFetchedLinkMetadata = false;
  //               print("🔄 URL metadata flag reset");
  //             }
  //           });
  //         }
  //       }
  //     }
  //   } else {
  //     // shareContentProvider.clear();
  //     // shareIntentProvider.clear();
  //     return;
  //   }
  // }

  // Add this method to reset URL flags after message is sent
  // void _resetUrlFlags() {
  //   _hasHandledSharedFile = false;
  //   _hasFetchedLinkMetadata = false;
  //   print("🔄 URL flags reset after message sent");
  // }

  // Fixed dispose method
  // @override
  // void dispose() {
  //   _scrollController.dispose(); // ✅ Dispose ScrollController
  //   messageController.dispose();
  //   super.dispose();
  // }

  // String? extractFirstUrl(String text) {
  //   final urlRegex = RegExp(
  //     r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
  //     caseSensitive: false,
  //   );
  //
  //   final match = urlRegex.firstMatch(text);
  //   return match?.group(0);
  // }

  // Future<void> _handleSendMessage(
  //   String messageText,
  //   MyAuthProvider authProvider,
  //   ChatProvider chatProvider,
  //   NotificationService service,
  //   ShareIntentProvider shareIntentProvider,
  //   SharedContentProvider shareContentProvider,
  //   ImagePickerProvider imagePickerProvider,
  // ) async {
  //   if (messageText.isEmpty) return;
  //
  //   final url = extractFirstUrl(messageText);
  //
  //   final metaModel = MetaModel(img: null, url: url, text: messageText);
  //
  //   final newMessage = ChatMessageModel(
  //     id: const Uuid().v4(),
  //     author: types.User(
  //       id: authProvider.uid,
  //       firstName: HiveService.getCurrentUser()?.username,
  //     ),
  //     metaModel: metaModel,
  //     createdAt: DateTime.now().millisecondsSinceEpoch,
  //   );
  //
  //   // Add message to ValueNotifier
  //   final chatMessage = CustomMapper.mapCustomMessageModalToChatMessage(
  //     userId: authProvider.uid,
  //     newMessage,
  //   );
  //
  //   // Clear controller first
  //   if (mounted) {
  //     messageController.clear();
  //     print("✅ Controller cleared in handleSendMessage");
  //   }
  //
  //   chatProvider.addMessageToNotifier(chatMessage);
  //
  //   try {
  //     // await chatProvider.startRealtimeListener();
  //     await chatProvider.sendMessage(newMessage);
  //
  //     // Clear all providers
  //     shareIntentProvider.clear();
  //     shareContentProvider.clear();
  //     imagePickerProvider.clear();
  //
  //     // Reset URL flags after successful send
  //     _resetUrlFlags();
  //
  //     print("✅ Message sent and all providers cleared");
  //   } catch (e) {
  //     print("❌ Error sending message: $e");
  //     // Don't reset flags on error so user can retry
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    /// Providers
    
    final authProvider = Provider.of<MyAuthProvider>(context);
    // final imagePickerProvider = Provider.of<ImagePickerProvider>(context);
    // final shareIntentProvider = Provider.of<ShareIntentProvider>(context);
    // final shareContentProvider = Provider.of<SharedContentProvider>(context);
    // final userService = UserService();

    return PopScope(
      canPop: false,
      child: KBackgroundScaffold(
        margin: const EdgeInsets.all(0),
        showDrawer: true,
        appBar: AppBar(
          toolbarHeight: 0.09.sh,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CircleAvatar(radius: 0.03.sh, child: Image.asset(AppAssets.logo)),
              SizedBox(width: 0.02.sw),
            ],
          ),
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('chats').snapshots(),
          builder: (context, asyncSnapshot) {
            ChatModel
            return ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: EdgeInsetsGeometry.all(20),
                  child: Container(height: 50, width: 100, color: Colors.blue),
                );
              },
              itemCount: 10,
            );
          }
        ),
      ),
    );
  }
}
