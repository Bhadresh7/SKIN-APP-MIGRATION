class ChatMessageModel {
  final String messageId;
  final Map<String, dynamic> authorJson;
  final int createdAt;

  ChatMessageModel({
    required this.messageId,
    required this.authorJson,
    required this.createdAt,
  });

  /// Create from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageId: json['id'] as String,
      authorJson: json['author'] as Map<String, dynamic>,
      createdAt:
          json['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': messageId, 'author': authorJson, 'createdAt': createdAt};
  }

  @override
  String toString() {
    return 'ChatMessageModel{id: $messageId, authorJson: $authorJson, createdAt: $createdAt}';
  }
}
