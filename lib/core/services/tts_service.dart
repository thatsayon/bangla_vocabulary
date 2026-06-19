import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setVolume(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speakEnglish(String text) async {
    await init();
    await _tts.setLanguage('en-US');
    await _tts.speak(text);
  }

  Future<void> speakBangla(String text) async {
    await init();
    await _tts.setLanguage('bn-BD');
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
