import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/constants/app_status.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/provider/internet_provider.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/message/models/chat_message_model.dart';
import 'package:skin_app_migration/features/message/widgets/chat_bubble.dart';
import 'package:skin_app_migration/features/message/widgets/message_text_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();

    final chatProvider = context.readChatProvider;
    final internetProvider = context.readInternetProvider;

    chatProvider.loadMessages();

    internetProvider.onReconnected = () async {
      await chatProvider.syncFirestoreToLocal();
    };

    // Optional: Immediate sync if already online
    if (internetProvider.connectionStatus == AppStatus.kConnected) {
      chatProvider.syncFirestoreToLocal();
    }
  }

  @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            Expanded(
              child: Consumer<InternetProvider>(
                builder: (context, internetProvider, _) {
                  // Is Online
                  final isOnline =
                      internetProvider.connectionStatus == AppStatus.kConnected;

                  if (isOnline) {
                    // ONLINE: Use Firestore stream
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .orderBy('ts', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('No messages yet.'));
                        }

                        final chatDocs = snapshot.data!.docs;

                        return ListView.builder(
                          reverse: true,
                          itemCount: chatDocs.length,
                          itemBuilder: (context, index) {
                            final data =
                                chatDocs[index].data() as Map<String, dynamic>;

                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ChatBubble(
                                chatMessage: ChatMessageModel.fromJson(data),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else {
                    // OFFLINE: Use local DB
                    final messages = context.watchChatProvider.messages;

                    if (messages.isEmpty) {
                      return const Center(child: Text('No offline messages.'));
                    }

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ChatBubble(chatMessage: message),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            MessageTextField(
              messageController: context.readChatProvider.messageController,
            ),
          ],
        ),
      ),
    );
  }
}
