import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Says hello by name, once each time the app is opened.
class VoiceGreeting {
  VoiceGreeting._();
  static final instance = VoiceGreeting._();

  FlutterTts? _tts;
  bool _greeted = false;

  /// Speaks "Hi Sam! Good morning." the first time it's called per launch.
  Future<void> greetOnce({required String name, required String greeting}) {
    if (_greeted) return Future.value();
    _greeted = true;
    return say('Hi $name! $greeting.');
  }

  Future<void> say(String text) async {
    try {
      final tts = _tts ??= FlutterTts();
      await tts.setSpeechRate(0.48);
      await tts.setPitch(1.05);
      await tts.speak(text);
    } catch (e) {
      // Voice is a nicety: no TTS engine, unsupported platform or tests.
      debugPrint('Voice greeting skipped: $e');
    }
  }
}
