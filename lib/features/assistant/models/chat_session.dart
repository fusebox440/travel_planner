import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'chat_message.dart';

part 'chat_session.g.dart';

@HiveType(typeId: 17) // Feature models range 10-19
class ChatSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  List<ChatMessage> messages;

  @HiveField(4)
  DateTime lastUpdated;

  @HiveField(5)
  final String? contextTripId;

  ChatSession({
    String? id,
    String? title,
    DateTime? createdAt,
    List<ChatMessage>? messages,
    DateTime? lastUpdated,
    this.contextTripId,
  })  : id = id ?? const Uuid().v4(),
        title = title ?? 'New Chat',
        createdAt = createdAt ?? DateTime.now(),
        messages = messages ?? [],
        lastUpdated = lastUpdated ?? DateTime.now();

  void addMessage(ChatMessage message) {
    messages.add(message);
    lastUpdated = DateTime.now();
  }

  void removeMessage(String messageId) {
    messages.removeWhere((m) => m.id == messageId);
    lastUpdated = DateTime.now();
  }

  void updateTitle(String newTitle) {
    title = newTitle;
    lastUpdated = DateTime.now();
  }

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
      if (contextTripId != null) 'contextTripId': contextTripId,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      contextTripId: json['contextTripId'] as String?,
    );
  }
}
