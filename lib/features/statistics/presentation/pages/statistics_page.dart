import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/constants/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/main_layout.dart';
import 'daily_statistics_page.dart';
import 'monthly_statistics_page.dart';
import 'yearly_statistics_page.dart';
import 'subscriber_statistics_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int _selectedSubMenuIndex = 0;

  Future<void> _logout() async {
    final localizations = AppLocalizations.of(context)!;
    // 로그아웃 확인 다이얼로그 표시
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logoutTitle),
        content: Text(localizations.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(localizations.logout),
          ),
        ],
      ),
    ) ?? false;
    
    if (shouldLogout) {
      await AuthService.logout();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: MenuConstants.statistics,
      selectedMainMenuIndex: 1,
      selectedSubMenuIndex: _selectedSubMenuIndex,
      onSubMenuSelected: (index) {
        setState(() {
          _selectedSubMenuIndex = index;
        });
      },
      onLogout: _logout,
      child: _buildSelectedPage(),
    );
  }

  Widget _buildSelectedPage() {
    switch (_selectedSubMenuIndex) {
      case 0:
        return const DailyStatisticsPage();
      case 1:
        return const MonthlyStatisticsPage();
      case 2:
        return const YearlyStatisticsPage();
      case 3:
        return const SubscriberStatisticsPage();
      default:
        return const Center(
          child: Text('현황집계 페이지 내용이 여기에 표시됩니다.'),
        );
    }
  }
} 