import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
import 'package:skin_app_migration/features/message/models/chat_message_model.dart';
import 'package:skin_app_migration/features/message/models/meta_model.dart';
import 'package:skin_app_migration/features/message/widgets/chat_bubble.dart';
import 'package:skin_app_migration/features/message/widgets/message_text_field.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // late NotificationService service;
  late TextEditingController messageController;

  @override
  void initState() {
    messageController = TextEditingController();
    super.initState();
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .orderBy('ts', descending: true)
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!asyncSnapshot.hasData ||
                      asyncSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No messages yet.'));
                  }

                  final chatDocs = asyncSnapshot.data!.docs;

                  return ListView.builder(
                    reverse: true,
                    itemCount: chatDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      final messageData =
                          chatDocs[index].data() as Map<String, dynamic>;
                      final message = MetaModel.fromJson(
                        messageData['metadata'],
                      );

                      final senderId = messageData['id'];

                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ChatBubble(
                          chatMessage: ChatMessageModel(
                            metadata: message,
                            senderId: senderId,
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            name:
                                context.readAuthProvider.user!.displayName ??
                                context.readAuthProvider.userData!.username,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            MessageTextField(messageController: messageController),
          ],
        ),
      ),
    );
  }
}
