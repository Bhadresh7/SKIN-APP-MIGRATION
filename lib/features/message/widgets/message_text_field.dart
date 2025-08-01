import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skin_app_migration/core/theme/app_styles.dart';

class MessageTextField extends StatefulWidget {
  final TextEditingController messageController;

  const MessageTextField({super.key, required this.messageController});

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  // late NotificationService service;
  int? maxLines;

  @override
  void initState() {
    super.initState();
    // service = NotificationService();
    // Initialize maxLines
    maxLines = widget.messageController.text.trim().isEmpty ? null : 2;
  }

  // Fixed _updateMaxLines method
  void _updateMaxLines() {
    if (mounted) {
      setState(() {
        maxLines = widget.messageController.text.trim().isEmpty ? null : 2;
      });
    }
  }

  String? extractFirstUrl(String text) {
    final urlRegex = RegExp(
      r'(?:(?:https?|ftp)://)?(?:[\w-]+\.)+[a-z]{2,}(?:/\S*)?',
      caseSensitive: false,
    );

    final match = urlRegex.firstMatch(text);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppStyles.primary,
              borderRadius: BorderRadius.circular(50),
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.attach_file, color: AppStyles.smoke),
                  // onPressed: _handleAttachmentPressed,
                ),

                // Text field
                Expanded(
                  child: TextField(
                    autofocus: false,
                    onChanged: (values) {
                      _updateMaxLines();
                    },
                    controller: widget.messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      hintStyle: TextStyle(color: AppStyles.smoke),
                    ),
                    style: TextStyle(color: AppStyles.smoke),
                    cursorColor: AppStyles.smoke,
                    maxLines: maxLines,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),

                const SizedBox(width: 8),
                // Send button
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.send, color: AppStyles.smoke),
                  // onPressed: _handleSendPressed,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
