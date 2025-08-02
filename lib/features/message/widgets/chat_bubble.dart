import 'package:flutter/material.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;
  final String? avatarUrl;
  final String senderName;

   ChatBubble({
    super.key,
    required this.message,
    required this.isSender,
    required this.avatarUrl,
     required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: isSender?Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:  [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: AppStyles.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6,
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 10),
        avatarUrl==null ?CircleAvatar(radius: 12,child: Text(senderName[0]),):CircleAvatar(
          radius: 12,
          backgroundImage: NetworkImage(avatarUrl!),
        ),
      ]
        ,):Row(
        mainAxisAlignment: isSender
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:  [
          avatarUrl==null ?CircleAvatar(radius: 12,child: Text(senderName[0]),):CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(avatarUrl!),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
