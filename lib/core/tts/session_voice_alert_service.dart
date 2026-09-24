// core/tts/session_voice_alert_service.dart
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract class SessionVoiceAlertService {
  Future<void> initialize();

  Future<void> announce(String message);

  Future<void> stop();
}

class AndroidSessionVoiceAlertService implements SessionVoiceAlertService {
  AndroidSessionVoiceAlertService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    await _flutterTts.awaitSpeakCompletion(false);
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage(_languageTagForLocale());

    _isInitialized = true;
  }

  @override
  Future<void> announce(String message) async {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    if (!_isInitialized) {
      await initialize();
    }

    if (!_isInitialized) {
      return;
    }

    try {
      await _flutterTts.setLanguage(_languageTagForLocale());
      await _flutterTts.speak(trimmed);
    } on Object {
      // Swallow platform/plugin errors so timing flow is never blocked by TTS.
    }
  }

  @override
  Future<void> stop() async {
    if (!_isInitialized) {
      return;
    }

    await _flutterTts.stop();
  }

  String _languageTagForLocale() {
    final Locale locale = PlatformDispatcher.instance.locale;
    if (locale.languageCode.toLowerCase() == 'zh') {
      return 'zh-TW';
    }

    return 'en-US';
  }
}

class NoopSessionVoiceAlertService implements SessionVoiceAlertService {
  const NoopSessionVoiceAlertService();

  @override
  Future<void> announce(String message) async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> stop() async {}
}

final Provider<SessionVoiceAlertService> sessionVoiceAlertServiceProvider =
    Provider<SessionVoiceAlertService>((Ref ref) {
      return const NoopSessionVoiceAlertService();
    });
