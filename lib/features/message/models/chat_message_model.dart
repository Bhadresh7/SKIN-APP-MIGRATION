class ChatMessageModel {
  final String id;

  final Map<String, dynamic> authorJson;

  // final MetaModel metaModel;

  final int createdAt;

  // FirebaseFirestore.instance.collection("chats").add()

  ChatMessageModel({
    required this.id,
    required types.User author,
    // required this.metaModel,
    required this.createdAt,
  })

  types.User get author => types.User.fromJson(authorJson);

  /// Create from a Flutter Chat `CustomMessage`
  factory ChatMessageModel.fromCustomMessage(types.CustomMessage msg) {
    return ChatMessageModel(
      id: msg.id,
      author: msg.author,
      metaModel: MetaModel.fromJson(msg.metadata ?? {}),
      createdAt: msg.createdAt ?? DateTime
          .now()
          .millisecondsSinceEpoch,
    );
  }

  /// Convert to JSON for storage or debug
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': authorJson,
      'metadata': metaModel.toJson(),
      'createdAt': createdAt,
    };
  }

  /// Load from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      author: types.User.fromJson(json['author'] as Map<String, dynamic>),
      metaModel: MetaModel.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
      createdAt:
      json['createdAt'] as int? ?? DateTime
          .now()
          .millisecondsSinceEpoch,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel{id: $id, authorJson: $authorJson, metaModel: $metaModel, createdAt: $createdAt}';
  }
}
