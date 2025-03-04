import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'core/localization/locale_provider.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/server_config.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();
  
  // 로케일 초기화
  final localeProvider = LocaleProvider();
  await localeProvider.init();
  
  // 저장된 서버 설정 로드
  await ServerConfig.loadSavedConfig();
  
  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 모바일 기기인지 확인하는 메서드
  bool get _isMobileDevice {
    if (kIsWeb) {
      // 웹에서는 화면 크기로 판단
      final windowWidth = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;
      final windowHeight = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height;
      final devicePixelRatio = WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
      
      final logicalWidth = windowWidth / devicePixelRatio;
      
      // 화면 너비가 768px 미만이면 모바일로 간주
      return logicalWidth < 768;
    }
    // 모바일 플랫폼인 경우
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    // 모바일 기기인 경우 installer 페이지로, 그렇지 않으면 로그인 페이지로 이동
    final String initialRoute = _isMobileDevice ? AppRouter.installer : AppRouter.login;
    
    return MaterialApp(
      title: 'GAS 인스톨러',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.generateRoute,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,
    );
  }
}
