import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    
    return MaterialApp(
      title: 'GAS 인스톨러',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.login,
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
