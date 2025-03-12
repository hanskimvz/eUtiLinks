import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/services/auth_service.dart';
// import '../../../auth/presentation/pages/login_page.dart';
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
      onLogout: () => AuthService.showLogoutDialog(context),
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
        return const Center(child: Text('현황집계 페이지 내용이 여기에 표시됩니다.'));
    }
  }
}
