import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceEngine {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  bool _speaking = false;

  bool get isListening => _speech.isListening;
  bool get isSpeaking => _speaking;

  Future<bool> listen({
    required void Function(String) onText,
    required void Function(bool) onListeningChanged,
  }) async {
    if (!_speech.isAvailable) {
      final available = await _speech.initialize(
        onStatus: (status) => onListeningChanged(status == 'listening'),
        onError: (_) => onListeningChanged(false),
      );
      if (!available) return false;
    }
    await _speech.listen(
      localeId: 'pt_BR',
      onResult: (result) => onText(result.recognizedWords),
    );
    onListeningChanged(_speech.isListening);
    return _speech.isListening;
  }

  Future<void> stopListening() async {
    if (_speech.isListening) await _speech.stop();
  }

  Future<void> speak(String text) async {
    await stopSpeaking();
    if (!_configured) {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.48);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(true);
      _configured = true;
    }
    _speaking = true;
    try {
      await _tts.speak(text);
    } finally {
      _speaking = false;
    }
  }

  Future<void> stopSpeaking() async {
    if (_speaking) {
      await _tts.stop();
      _speaking = false;
    }
  }

  Future<void> dispose() async {
    await stopListening();
    await _tts.stop();
  }
}
