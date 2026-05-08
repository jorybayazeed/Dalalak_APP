import 'dart:convert';

import 'package:http/http.dart' as http;

class SupportedLanguage {
  final String code;
  final String label;

  const SupportedLanguage({
    required this.code,
    required this.label,
  });
}

class LiveTranslationResult {
  final String original;
  final String translated;

  const LiveTranslationResult({
    required this.original,
    required this.translated,
  });
}

class LiveTranslationService {
  static const List<SupportedLanguage> supportedLanguages = <SupportedLanguage>[
    SupportedLanguage(code: 'ar', label: 'Arabic'),
    SupportedLanguage(code: 'en', label: 'English'),
    SupportedLanguage(code: 'zh-CN', label: 'Chinese'),
    SupportedLanguage(code: 'fr', label: 'French'),
  ];

  static String normalizeCodeForApi(String code) {
    if (code == 'zh-CN') return 'zh';
    return code;
  }

  Future<LiveTranslationResult> translateWithTourismContext({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return const LiveTranslationResult(original: '', translated: '');
    }

    final translated = await _translateViaPublicApi(
      text: trimmed,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    final contextual = _applyTourismContext(
      text: translated.isEmpty ? trimmed : translated,
      sourceLang: sourceLang,
      targetLang: targetLang,
    );

    return LiveTranslationResult(
      original: trimmed,
      translated: contextual,
    );
  }

  Future<String> _translateViaPublicApi({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    final source = normalizeCodeForApi(sourceLang);
    final target = normalizeCodeForApi(targetLang);

    if (source == target) return text;

    try {
      final uri = Uri.https('api.mymemory.translated.net', '/get', {
        'q': text,
        'langpair': '$source|$target',
      });

      final response = await http.get(
        uri,
        headers: const {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return text;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return text;

      final data = decoded['responseData'];
      if (data is! Map<String, dynamic>) return text;

      final translatedText = (data['translatedText'] ?? '').toString().trim();
      if (translatedText.isEmpty) return text;
      return translatedText;
    } catch (_) {
      return text;
    }
  }

  String _applyTourismContext({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) {
    var out = text;

    if (targetLang == 'en') {
      out = out
          .replaceAll('place', 'site')
          .replaceAll('old market', 'historic market')
          .replaceAll('tour', 'guided tour');
    }

    if (targetLang == 'ar') {
      out = out
          .replaceAll('site', 'الموقع')
          .replaceAll('historic', 'تاريخي')
          .replaceAll('guided tour', 'جولة إرشادية');
    }

    if (targetLang == 'fr') {
      out = out
          .replaceAll('site', 'site touristique')
          .replaceAll('guided tour', 'visite guidee');
    }

    if (targetLang == 'zh-CN') {
      out = out
          .replaceAll('site', '景点')
          .replaceAll('guided tour', '导览行程');
    }

    return out;
  }
}
