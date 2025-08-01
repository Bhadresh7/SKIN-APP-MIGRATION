import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_app_migration/core/constants/app_assets.dart';
import 'package:skin_app_migration/core/widgets/k_background_scaffold.dart';
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
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  return ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsetsGeometry.all(20),
                        child: Container(
                          height: 50,
                          width: 100,
                          color: Colors.blue,
                        ),
                      );
                    },
                    itemCount: 10,
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
