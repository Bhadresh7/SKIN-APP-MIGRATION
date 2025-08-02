import 'package:skin_app_migration/features/message/models/meta_model.dart';

class ChatMessageModel {
  final String senderId;
  final int createdAt;
  final String name;
  final MetaModel? metadata;
  ChatMessageModel({
    required this.metadata,
    required this.senderId,
    required this.createdAt,
    required this.name,
  });

  /// Create from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      metadata: MetaModel.fromJson(json['metadata']),
      senderId: json['id'] as String,
      name: json['name'] as String,
      createdAt: json['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': senderId,
      'ts': createdAt,
      'name': name,
      'metadata': metadata?.toJson(),
    };
  }

  @override
  String toString() {
    return 'ChatMessageModel{ createdAt: $createdAt}';
  }
}
