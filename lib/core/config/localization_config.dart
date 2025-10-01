import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';

class LanguageModel {
  final String language;
  final String code;
  final Locale locale;

  LanguageModel({
    required this.language,
    required this.code,
    required this.locale,
  });
}

class LocalizationConfig {
  static LocalizationConfig instance = LocalizationConfig._();

  factory LocalizationConfig() {
    return instance;
  }

  LocalizationConfig._();

  Future<void> initialize() async {
    await EasyLocalization.ensureInitialized();
  }

  List<LanguageModel> languages = [
    LanguageModel(
      language: "English",
      code: "English",
      locale: Locale("en", "US"),
    ),
    LanguageModel(
      language: "Afrikaans",
      code: "Afrikaans",
      locale: Locale("af", "ZA"),
    ),
    LanguageModel(
      language: "Hindi",
      code: "हिन्दी",
      locale: Locale("hi", "IN"),
    ),
    LanguageModel(
      language: "Portuguese",
      code: "Português",
      locale: Locale("pt", "PT"),
    ),
    LanguageModel(
      language: "Indonesian",
      code: "Indonesia",
      locale: Locale("id", "ID"),
    ),
    LanguageModel(
      language: "Italian",
      code: "Italiano",
      locale: Locale("it", "IT"),
    ),
    LanguageModel(
      language: "French",
      code: "Français",
      locale: Locale("fr", "FR"),
    ),
    LanguageModel(language: "Urdu", code: "اردو", locale: Locale("ur", "PK")),
  ];

  List<Locale> get supportedLocales =>
      languages.map((language) => language.locale).toList();

  String languageTitle(String code) {
    return languages
        .firstWhere((element) => element.locale.languageCode == code)
        .language;
  }
}
