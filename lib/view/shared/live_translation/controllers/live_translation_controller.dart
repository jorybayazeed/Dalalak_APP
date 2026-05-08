import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:tour_app/services/live_translation_service.dart';

class LiveTranslationController extends GetxController {
  final LiveTranslationService _service = LiveTranslationService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();

  final RxBool isSpeechReady = false.obs;
  final RxBool isListening = false.obs;
  final RxBool isTranslating = false.obs;

  final RxString sourceLang = 'ar'.obs;
  final RxString targetLang = 'en'.obs;

  final RxString liveText = ''.obs;
  final RxString translatedText = ''.obs;

  final RxList<Map<String, String>> history = <Map<String, String>>[].obs;

  Timer? _translateDebounce;

  List<SupportedLanguage> get languages =>
      LiveTranslationService.supportedLanguages;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (status.toLowerCase().contains('notlistening')) {
            isListening.value = false;
          }
        },
        onError: (_) {
          isListening.value = false;
        },
      );
      isSpeechReady.value = available;
    } catch (_) {
      isSpeechReady.value = false;
    }
  }

  Future<void> _initTts() async {
    try {
      await _tts.setSpeechRate(0.45);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (_) {}
  }

  Future<void> startListening() async {
    if (!isSpeechReady.value) {
      await _initSpeech();
      if (!isSpeechReady.value) {
        Get.snackbar('Microphone', 'Speech recognition is not available.');
        return;
      }
    }

    try {
      await _speech.listen(
        localeId: sourceLang.value,
        listenMode: stt.ListenMode.dictation,
        onResult: (result) {
          liveText.value = result.recognizedWords.trim();
          if (liveText.value.isNotEmpty) {
            _scheduleTranslate();
          }
        },
      );
      isListening.value = true;
    } catch (_) {
      isListening.value = false;
      Get.snackbar('Microphone', 'Failed to start listening.');
    }
  }

  Future<void> stopListening() async {
    try {
      await _speech.stop();
    } catch (_) {}
    isListening.value = false;

    if (liveText.value.trim().isNotEmpty) {
      await translateNow();
      _addToHistory();
    }
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  void setSourceLang(String value) {
    sourceLang.value = value;
    if (sourceLang.value == targetLang.value) {
      _autoPickDifferentTarget();
    }
  }

  void setTargetLang(String value) {
    targetLang.value = value;
    if (sourceLang.value == targetLang.value) {
      _autoPickDifferentSource();
    }
  }

  void _autoPickDifferentTarget() {
    for (final lang in languages) {
      if (lang.code != sourceLang.value) {
        targetLang.value = lang.code;
        break;
      }
    }
  }

  void _autoPickDifferentSource() {
    for (final lang in languages) {
      if (lang.code != targetLang.value) {
        sourceLang.value = lang.code;
        break;
      }
    }
  }

  void _scheduleTranslate() {
    _translateDebounce?.cancel();
    _translateDebounce = Timer(const Duration(milliseconds: 450), () {
      translateNow();
    });
  }

  Future<void> translateNow() async {
    final original = liveText.value.trim();
    if (original.isEmpty) {
      translatedText.value = '';
      return;
    }

    isTranslating.value = true;
    try {
      final result = await _service.translateWithTourismContext(
        text: original,
        sourceLang: sourceLang.value,
        targetLang: targetLang.value,
      );
      translatedText.value = result.translated;
    } catch (_) {
      translatedText.value = original;
    } finally {
      isTranslating.value = false;
    }
  }

  Future<void> speakTranslation() async {
    final text = translatedText.value.trim();
    if (text.isEmpty) return;

    try {
      await _tts.setLanguage(_ttsLangFor(targetLang.value));
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      Get.snackbar('Voice Output', 'Text-to-speech is not available now.');
    }
  }

  String _ttsLangFor(String code) {
    switch (code) {
      case 'ar':
        return 'ar-SA';
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      case 'zh-CN':
        return 'zh-CN';
      default:
        return 'en-US';
    }
  }

  void clearCurrent() {
    liveText.value = '';
    translatedText.value = '';
  }

  void _addToHistory() {
    final original = liveText.value.trim();
    final translated = translatedText.value.trim();
    if (original.isEmpty || translated.isEmpty) return;

    history.insert(0, {
      'original': original,
      'translated': translated,
    });

    if (history.length > 20) {
      history.removeRange(20, history.length);
    }
  }

  List<String> quickPhrases(String role) {
    if (role == 'guide') {
      return const <String>[
        'Welcome to this historic site.',
        'Please stay with the group.',
        'We will move to the next stop in 10 minutes.',
      ];
    }

    return const <String>[
      'Is photography allowed here?',
      'Where is the restroom?',
      'How long will this tour take?',
    ];
  }

  Future<void> useQuickPhrase(String phrase) async {
    liveText.value = phrase;
    await translateNow();
    _addToHistory();
  }

  @override
  void onClose() {
    _translateDebounce?.cancel();
    try {
      _speech.stop();
    } catch (_) {}
    try {
      _tts.stop();
    } catch (_) {}
    super.onClose();
  }
}
