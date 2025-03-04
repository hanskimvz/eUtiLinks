import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko');
  Locale get locale => _locale;

  // 지원하는 언어 목록
  static const List<Locale> supportedLocales = [
    Locale('ko'), // 한국어
    Locale('en'), // 영어
  ];

  // 언어 이름 맵핑
  static const Map<String, String> localeNames = {
    'ko': '한국어',
    'en': 'English',
  };

  // 초기화 메서드
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    
    if (savedLocale != null) {
      _locale = Locale(savedLocale);
    }
    notifyListeners();
  }

  // 언어 변경 메서드
  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
    notifyListeners();
  }
} 