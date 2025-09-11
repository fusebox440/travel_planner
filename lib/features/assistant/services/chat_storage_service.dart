import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatStorageService {
  static const String _sessionBoxName = 'chat_sessions';
  static const String _messageBoxName = 'chat_messages';

  late Box<ChatSession> _sessionBox;
  late Box<ChatMessage> _messageBox;

  Future<void> initialize() async {
    _sessionBox = await Hive.openBox<ChatSession>(_sessionBoxName);
    _messageBox = await Hive.openBox<ChatMessage>(_messageBoxName);
  }

  // Session operations
  Future<ChatSession> createSession({
    String? title,
    String? contextTripId,
  }) async {
    final session = ChatSession(
      title: title,
      contextTripId: contextTripId,
    );

    await _sessionBox.put(session.id, session);
    return session;
  }

  Future<void> deleteSession(String sessionId) async {
    final session = _sessionBox.get(sessionId);
    if (session != null) {
      // Delete all messages in the session
      for (final message in session.messages) {
        await _messageBox.delete(message.id);
      }
      await _sessionBox.delete(sessionId);
    }
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final session = _sessionBox.get(sessionId);
    if (session != null) {
      session.updateTitle(newTitle);
      await _sessionBox.put(sessionId, session);
    }
  }

  Future<List<ChatSession>> listSessions() async {
    final sessions = _sessionBox.values.toList();
    sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sessions;
  }

  // Message operations
  Future<void> appendMessage(String sessionId, ChatMessage message) async {
    final session = _sessionBox.get(sessionId);
    if (session != null) {
      await _messageBox.put(message.id, message);
      session.addMessage(message);
      await _sessionBox.put(sessionId, session);
    }
  }

  Future<void> deleteMessage(String sessionId, String messageId) async {
    final session = _sessionBox.get(sessionId);
    if (session != null) {
      session.removeMessage(messageId);
      await _sessionBox.put(sessionId, session);
      await _messageBox.delete(messageId);
    }
  }

  Future<void> clearAllSessions() async {
    await _sessionBox.clear();
    await _messageBox.clear();
  }

  // Helper methods
  Future<ChatSession?> getSession(String sessionId) async {
    return _sessionBox.get(sessionId);
  }

  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    return session.messages;
  }

  Stream<List<ChatSession>> watchSessions() {
    return _sessionBox.watch().map((_) {
      final sessions = _sessionBox.values.toList();
      sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      return sessions;
    });
  }

  Stream<ChatSession?> watchSession(String sessionId) {
    return _sessionBox.watch(key: sessionId).map((_) {
      return _sessionBox.get(sessionId);
    });
  }

  // Export/Import for backup
  Future<Map<String, dynamic>> exportData() async {
    return {
      'sessions': _sessionBox.values.map((s) => s.toJson()).toList(),
      'messages': _messageBox.values.map((m) => m.toJson()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await clearAllSessions();

      final messages = (data['messages'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList();
      final sessions = (data['sessions'] as List)
          .map((s) => ChatSession.fromJson(s))
          .toList();

      for (final message in messages) {
        await _messageBox.put(message.id, message);
      }

      for (final session in sessions) {
        await _sessionBox.put(session.id, session);
      }
    } catch (e) {
      debugPrint('Error importing data: $e');
      rethrow;
    }
  }

  // Cleanup
  Future<void> dispose() async {
    await _sessionBox.compact();
    await _messageBox.compact();
    await _sessionBox.close();
    await _messageBox.close();
  }
}
