import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

import '../services/assistant_service.dart';
import '../services/chat_storage_service.dart';
import '../services/nlu_service.dart';
import '../services/suggestion_service.dart';
import '../services/voice_service.dart';

class ChatState {
  final ChatSession? currentSession;
  final List<ChatSession> sessions;
  final bool isListening;
  final bool isThinking;
  final bool isOffline;
  final List<String> suggestions;
  final String? error;

  const ChatState({
    this.currentSession,
    this.sessions = const [],
    this.isListening = false,
    this.isThinking = false,
    this.isOffline = false,
    this.suggestions = const [],
    this.error,
  });

  ChatState copyWith({
    ChatSession? currentSession,
    List<ChatSession>? sessions,
    bool? isListening,
    bool? isThinking,
    bool? isOffline,
    List<String>? suggestions,
    String? error,
  }) {
    return ChatState(
      currentSession: currentSession ?? this.currentSession,
      sessions: sessions ?? this.sessions,
      isListening: isListening ?? this.isListening,
      isThinking: isThinking ?? this.isThinking,
      isOffline: isOffline ?? this.isOffline,
      suggestions: suggestions ?? this.suggestions,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends AsyncNotifier<ChatState> {
  late final AssistantService _assistantService;
  late final ChatStorageService _storageService;
  late final VoiceService _voiceService;

  StreamSubscription? _voiceSubscription;

  @override
  Future<ChatState> build() async {
    _assistantService = ref.read(assistantServiceProvider);
    _storageService = ref.read(chatStorageServiceProvider);
    _voiceService = ref.read(voiceServiceProvider);

    await _storageService.initialize();
    final sessions = await _storageService.listSessions();

    return ChatState(sessions: sessions);
  }

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    state = AsyncData(state.value!.copyWith(isThinking: true));

    try {
      final session = state.value!.currentSession ?? await _createNewSession();

      final userMessage = ChatMessage(
        sender: MessageSender.user,
        text: text,
      );

      await _storageService.appendMessage(session.id, userMessage);

      final response = await _assistantService.processMessage(
        text,
        null, // locale
        _getAppState(),
        session.messages,
      );

      await _storageService.appendMessage(session.id, response.message);

      if (response.actions != null) {
        await _handleActions(response.actions!);
      }

      final updatedSession = await _storageService.getSession(session.id);
      final sessions = await _storageService.listSessions();

      state = AsyncData(ChatState(
        currentSession: updatedSession,
        sessions: sessions,
        suggestions: response.suggestions.map((s) => s.text).toList(),
      ));
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        isThinking: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> startVoice() async {
    if (state.value!.isListening) return;

    try {
      state = AsyncData(state.value!.copyWith(isListening: true));

      _voiceSubscription = _voiceService.transcription.listen((text) {
        if (text != null) {
          sendUserMessage(text);
        }
      });

      await _voiceService.startListening();
    } catch (e) {
      state = AsyncData(state.value!.copyWith(
        isListening: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> stopVoice() async {
    if (!state.value!.isListening) return;

    await _voiceService.stopListening();
    await _voiceSubscription?.cancel();
    _voiceSubscription = null;

    state = AsyncData(state.value!.copyWith(isListening: false));
  }

  Future<void> newSession({String? contextTripId}) async {
    final session = await _createNewSession(contextTripId: contextTripId);
    final sessions = await _storageService.listSessions();

    state = AsyncData(ChatState(
      currentSession: session,
      sessions: sessions,
    ));
  }

  Future<void> switchSession(String sessionId) async {
    final session = await _storageService.getSession(sessionId);
    if (session == null) return;

    state = AsyncData(state.value!.copyWith(currentSession: session));
  }

  Future<void> deleteSession(String sessionId) async {
    await _storageService.deleteSession(sessionId);
    final sessions = await _storageService.listSessions();

    state = AsyncData(state.value!.copyWith(
      currentSession: state.value!.currentSession?.id == sessionId
          ? null
          : state.value!.currentSession,
      sessions: sessions,
    ));
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    await _storageService.renameSession(sessionId, newTitle);
    final sessions = await _storageService.listSessions();
    final currentSession = state.value!.currentSession?.id == sessionId
        ? await _storageService.getSession(sessionId)
        : state.value!.currentSession;

    state = AsyncData(state.value!.copyWith(
      currentSession: currentSession,
      sessions: sessions,
    ));
  }

  Future<void> readAloudLastResponse() async {
    final session = state.value!.currentSession;
    if (session == null) return;

    final lastAssistantMessage = session.messages.lastWhere(
      (m) => m.isAssistant,
      orElse: () => throw Exception('No assistant message found'),
    );

    await _voiceService.speak(lastAssistantMessage.text);
  }

  Future<ChatSession> _createNewSession({String? contextTripId}) async {
    return await _storageService.createSession(
      title: 'New Chat',
      contextTripId: contextTripId,
    );
  }

  Map<String, dynamic> _getAppState() {
    // TODO: Implement this to provide current app state to the assistant
    return {};
  }

  Future<void> _handleActions(Map<String, dynamic> actions) async {
    // TODO: Implement this to handle assistant actions
    // e.g., showing flight results, updating itinerary, etc.
  }

  void dispose() {
    _voiceSubscription?.cancel();
  }
}

final chatStorageServiceProvider = Provider<ChatStorageService>((ref) {
  return ChatStorageService();
});

final voiceServiceProvider = Provider<VoiceService>((ref) {
  return VoiceService();
});

final suggestionServiceProvider = Provider<SuggestionService>((ref) {
  return SuggestionService();
});

final nluServiceProvider = Provider<NluService>((ref) {
  return LocalNluService();
});

final assistantServiceProvider = Provider<AssistantService>((ref) {
  return AssistantService(
    nluService: ref.read(nluServiceProvider),
    suggestionService: ref.read(suggestionServiceProvider),
    currencyService: StubCurrencyService(),
    weatherService: StubWeatherService(),
    bookingService: StubBookingService(),
    packingListService: StubPackingListService(),
  );
});

final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>(() {
  return ChatNotifier();
});
