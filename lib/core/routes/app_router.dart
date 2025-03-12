import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../features/auth/presentation/pages/login_page.dart';
// import '../../features/home/presentation/pages/home_page.dart';
import '../../features/info_management/presentation/pages/info_management_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/installer/presentation/pages/installer_page.dart';
import '../../features/info_management/presentation/pages/device_info_view_page.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/';
  static const String infoManagement = '/info-management';
  static const String statistics = '/statistics';
  static const String configure = '/configure';
  static const String installer = '/installer';
  static const String deviceInfo = '/device-info';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final String? routeName = settings.name;

    developer.log('요청된 경로: $routeName', name: 'AppRouter');

    if (routeName == login) {
      return MaterialPageRoute(builder: (_) => const LoginPage());
    } else if (routeName == home) {
      return MaterialPageRoute(builder: (_) => const InfoManagementPage());
    } else if (routeName == infoManagement) {
      return MaterialPageRoute(builder: (_) => const InfoManagementPage());
    } else if (routeName == statistics) {
      return MaterialPageRoute(builder: (_) => const StatisticsPage());
    } else if (routeName == configure) {
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    } else if (routeName == installer) {
      return MaterialPageRoute(builder: (_) => const InstallerPage());
    } else if (routeName == deviceInfo) {
      final args = settings.arguments as Map<String, dynamic>;
      final deviceUid = args['deviceUid'] as String;
      return MaterialPageRoute(
        builder: (_) => DeviceInfoViewPage(deviceUid: deviceUid),
      );
    } else {
      developer.log('정의되지 않은 경로: $routeName', name: 'AppRouter');

      return MaterialPageRoute(
        builder:
            (_) => Scaffold(
              body: Center(
                child: Text('No route defined for ${routeName ?? "unknown"}'),
              ),
            ),
      );
    }
  }

}
