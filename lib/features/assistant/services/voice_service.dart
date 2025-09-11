import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

enum VoiceServiceStatus {
  idle,
  listening,
  processing,
  speaking,
  error,
}

class VoiceService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final _statusController =
      BehaviorSubject<VoiceServiceStatus>.seeded(VoiceServiceStatus.idle);
  final _transcriptionController = BehaviorSubject<String?>();
  final _soundLevelController = BehaviorSubject<double>();

  Stream<VoiceServiceStatus> get status => _statusController.stream;
  Stream<String?> get transcription => _transcriptionController.stream;
  Stream<double> get soundLevel => _soundLevelController.stream;

  bool _initialized = false;
  bool get isInitialized => _initialized;
  bool get isListening => _speech.isListening;

  VoiceService() {
    _configureTextToSpeech();
  }

  Future<void> initialize() async {
    if (!isInitialized) {
      final hasSpeechPermission = await _requestPermissions();
      if (!hasSpeechPermission) {
        _statusController.add(VoiceServiceStatus.error);
        throw Exception('Speech recognition permission denied');
      }

      final success = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech recognition error: $error');
          _statusController.add(VoiceServiceStatus.error);
        },
        debugLogging: kDebugMode,
      );

      if (!success) {
        _statusController.add(VoiceServiceStatus.error);
        throw Exception('Speech recognition initialization failed');
      }

      _initialized = true;
    }
  }

  Future<bool> _requestPermissions() async {
    if (kIsWeb) return true;

    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> _configureTextToSpeech() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(1.0);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _statusController.add(VoiceServiceStatus.speaking);
    });

    _tts.setCompletionHandler(() {
      _statusController.add(VoiceServiceStatus.idle);
    });

    _tts.setErrorHandler((message) {
      debugPrint('TTS error: $message');
      _statusController.add(VoiceServiceStatus.error);
    });
  }

  Future<void> startListening({
    String? locale,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!isInitialized) {
      await initialize();
    }

    if (isListening) {
      await stopListening();
    }

    _transcriptionController.add(null);

    final success = await _speech.listen(
      onResult: (result) {
        final text = result.finalResult ? result.recognizedWords : null;
        _transcriptionController.add(text);

        if (result.finalResult) {
          stopListening();
        }
      },
      localeId: locale,
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
      onSoundLevelChange: (level) {
        _soundLevelController.add(level);
      },
    );

    if (success) {
      _statusController.add(VoiceServiceStatus.listening);
    } else {
      _statusController.add(VoiceServiceStatus.error);
      throw Exception('Failed to start speech recognition');
    }
  }

  Future<void> stopListening() async {
    if (isListening) {
      _statusController.add(VoiceServiceStatus.processing);
      await _speech.stop();
      _statusController.add(VoiceServiceStatus.idle);
    }
  }

  Future<void> speak(String text) async {
    if (_statusController.value == VoiceServiceStatus.speaking) {
      await stop();
    }

    _statusController.add(VoiceServiceStatus.speaking);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (isListening) {
      await stopListening();
    }
    if (_statusController.value == VoiceServiceStatus.speaking) {
      await _tts.stop();
    }
    _statusController.add(VoiceServiceStatus.idle);
  }

  Future<void> dispose() async {
    await stop();
    await _tts.stop();
    await Future.wait([
      _statusController.close(),
      _transcriptionController.close(),
      _soundLevelController.close(),
    ]);
  }

  // Voice options management
  Future<List<String>> getAvailableVoices() async {
    final voices = await _tts.getVoices as List<dynamic>;
    return voices.map((voice) => voice.toString()).toList();
  }

  Future<void> setVoice(String voice) async {
    await _tts.setVoice({'name': voice});
  }

  Future<List<dynamic>> getLanguages() async {
    return await _tts.getLanguages;
  }

  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  Future<void> setRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }
}
