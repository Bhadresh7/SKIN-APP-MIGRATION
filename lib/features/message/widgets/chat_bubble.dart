import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:skin_app_migration/core/extensions/provider_extensions.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';
import 'package:skin_app_migration/features/message/models/chat_message_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessageModel chatMessage;

  const ChatBubble({super.key, required this.chatMessage});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  Metadata? metadata;
  String? avatar;

  @override
  void initState() {
    super.initState();
    final senderDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.chatMessage.senderId)
        .get()
        .then((value) {
          if (mounted && value.exists) {
            setState(() {
              avatar = value.data()!['imageUrl'];
            });
          }
        });

    if (isUrl) {
      MetadataFetch.extract(widget.chatMessage.metadata!.url!).then((value) {
        if (mounted && value != null) {
          setState(() {
            metadata = value;
          });
        }
      });
    }
  }

  bool get isImage => widget.chatMessage.metadata?.img != null;

  bool get isUrl => widget.chatMessage.metadata?.url != null;

  bool get isSender =>
      widget.chatMessage.senderId == context.readAuthProvider.user!.uid;

  BorderRadius getBubbleRadius() {
    if (isSender) {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(0),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomRight: Radius.circular(16),
        bottomLeft: Radius.circular(0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isSender ? AppStyles.primary : Colors.grey[300];
    final textColor = isSender ? Colors.white : Colors.black;
    final maxWidth = MediaQuery.of(context).size.width * 0.6;

    Widget content;

    if (isImage) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.chatMessage.metadata!.img!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              height: 100,
              width: 100,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image),
        ),
      );
    } else if (isUrl && metadata != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (metadata!.image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                metadata!.image!,
                height: 0.6.sw,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 6),
          if (metadata!.title != null)
            Text(
              metadata!.title!,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (metadata!.description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                metadata!.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: textColor.withOpacity(0.8)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse(widget.chatMessage.metadata!.url!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  print("Can launch url");
                }
              },
              child: Text(
                widget.chatMessage.metadata!.url!,
                style: TextStyle(
                  color: AppStyles.links,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: AppStyles.links,
                  wordSpacing: 2.0,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (isUrl) {
      content = Text(
        widget.chatMessage.metadata!.url!,
        style: TextStyle(color: textColor, fontSize: 16),
      );
    } else {
      content = Text(
        widget.chatMessage.metadata!.text ?? "",
        style: TextStyle(color: textColor, fontSize: 16),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: isSender
          ? Row(
              mainAxisAlignment: isSender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: isImage || isUrl
                        ? const EdgeInsets.all(6)
                        : const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: getBubbleRadius(),
                    ),
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: content,
                  ),
                ),
                const SizedBox(width: 10),
                avatar == null
                    ? CircleAvatar(
                        radius: 12,
                        child: Text(widget.chatMessage.name[0]),
                      )
                    : CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(avatar!),
                      ),
              ],
            )
          : Row(
              mainAxisAlignment: isSender
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                avatar == null
                    ? CircleAvatar(
                        radius: 12,
                        child: Text(widget.chatMessage.name[0]),
                      )
                    : CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(avatar!),
                      ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: isImage || isUrl
                        ? const EdgeInsets.all(6)
                        : const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: getBubbleRadius(),
                    ),
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: content,
                  ),
                ),
              ],
            ),
    );
  }
}
