import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 브랜드 색상
  static const Color brandColor = Color(0xFF1E88E5); // 파란색
  static const Color secondaryColor = Color(0xFF43A047); // 녹색
  static const Color backgroundColor = Color(0xFFFFFFFF); // 흰색
  static const Color textColor = Color(0xFF212121); // 검정색
  static const Color warningColor = Color(0xFFE53935); // 빨간색

  // 상태별 색상
  static const Color activeColor = Color(0xFF1E88E5); // 파란색
  static const Color inactiveColor = Color(0xFF9E9E9E); // 회색
  static const Color successColor = Color(0xFF43A047); // 녹색
  static const Color cautionColor = Color(0xFFFFA000); // 주황색
  static const Color errorColor = Color(0xFFE53935); // 빨간색

  // 폰트 크기
  static const double titleFontSize = 22.0;
  static const double subtitleFontSize = 18.0;
  static const double bodyFontSize = 15.0;
  static const double smallFontSize = 14.0;
  static const double largeTitleFontSize = 26.0;

  static ThemeData get lightTheme {
    // 추천 한국어 폰트 옵션:
    // 1. IBM Plex Sans KR: 깔끔하고 현대적인 디자인, 가독성이 좋음
    // 2. Nanum Gothic: 널리 사용되는 한글 폰트, 다양한 굵기 지원
    // 3. Spoqa Han Sans Neo: 깔끔하고 현대적인 디자인, 웹에 최적화
    // 4. Pretendard: 최신 한글 폰트, 선명하고 가독성이 뛰어남
    
    // 원하는 폰트로 변경하려면 아래 코드에서 'ibmPlexSansKr'를 
    // 'nanumGothic', 'blackHanSans', 'doHyeon' 등으로 변경하세요.
    
    // IBM Plex Sans KR 폰트 사용 (선명하고 가독성이 좋은 한국어 폰트)
    
    final TextTheme textTheme = GoogleFonts.ibmPlexSansKrTextTheme().copyWith(
      bodyLarge: GoogleFonts.ibmPlexSansKr(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
        letterSpacing: -0.1, // 자간 조정으로 가독성 향상
      ),
      bodyMedium: GoogleFonts.ibmPlexSansKr(
        fontSize: smallFontSize,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
        letterSpacing: -0.1,
      ),
      headlineLarge: GoogleFonts.ibmPlexSansKr(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.ibmPlexSansKr(
        fontSize: subtitleFontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
        letterSpacing: -0.2,
      ),
    );
    
    // Nanum Gothic 폰트 사용 예시 (주석 해제하여 사용)
    /*
    final TextTheme textTheme = GoogleFonts.nanumGothicTextTheme().copyWith(
      bodyLarge: GoogleFonts.nanumGothic(
        fontSize: bodyFontSize,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
        letterSpacing: -0.1,
      ),
      bodyMedium: GoogleFonts.nanumGothic(
        fontSize: smallFontSize,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
        letterSpacing: -0.1,
      ),
      headlineLarge: GoogleFonts.nanumGothic(
        fontSize: titleFontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.nanumGothic(
        fontSize: subtitleFontSize,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
        letterSpacing: -0.2,
      ),
    );
    */
    
    return ThemeData(
      primaryColor: brandColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brandColor,
        primary: brandColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white, // 배경색을 하얀색으로 변경
        foregroundColor: brandColor, // 전경색을 브랜드 색상으로 변경
        elevation: 0,
        titleTextStyle: TextStyle(
          color: brandColor,
          fontWeight: FontWeight.bold,
          fontSize: largeTitleFontSize,
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: brandColor,
        unselectedLabelColor: inactiveColor,
        indicatorColor: brandColor,
      ),
      textTheme: textTheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: brandColor,
          side: const BorderSide(color: brandColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: inactiveColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: brandColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: inactiveColor),
        ),
      ),
    );
  }
} 