import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 25) // Enum range 20-29
enum MessageSender {
  @HiveField(0)
  user,
  @HiveField(1)
  assistant,
  @HiveField(2)
  system
}

@HiveType(typeId: 18) // Feature models range 10-19
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final MessageSender sender;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final List<String>? attachments;

  @HiveField(5)
  final String? intent;

  @HiveField(6)
  final Map<String, dynamic>? meta;

  ChatMessage({
    String? id,
    required this.sender,
    required this.text,
    DateTime? createdAt,
    this.attachments,
    this.intent,
    this.meta,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    MessageSender? sender,
    String? text,
    DateTime? createdAt,
    List<String>? attachments,
    String? intent,
    Map<String, dynamic>? meta,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      intent: intent ?? this.intent,
      meta: meta ?? this.meta,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toString(),
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (attachments != null) 'attachments': attachments,
      if (intent != null) 'intent': intent,
      if (meta != null) 'meta': meta,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == json['sender'],
      ),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      attachments: (json['attachments'] as List<dynamic>?)?.cast<String>(),
      intent: json['intent'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  bool get isUser => sender == MessageSender.user;
  bool get isAssistant => sender == MessageSender.assistant;
  bool get isSystem => sender == MessageSender.system;
}
