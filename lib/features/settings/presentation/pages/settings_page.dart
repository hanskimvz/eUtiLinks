import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/constants/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/main_layout.dart';
import 'system_settings_page.dart';
import 'permission_management_page.dart';
import 'user_management_page.dart';
import 'location_management_page.dart';
import 'device_management_page.dart';
import 'subscriber_management_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
    // final localizations = AppLocalizations.of(context);
    
    return MainLayout(
      title: MenuConstants.settings,
      selectedMainMenuIndex: 2,
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
        return const SystemSettingsPage();
      case 1:
        return const PermissionManagementPage();
      case 2:
        return const UserManagementPage();
      case 3:
        return const LocationManagementPage();
      case 4:
        return const DeviceManagementPage();
      case 5:
        return const SubscriberManagementPage();
      case 6:
        return _buildComingSoonPage('이벤트 관리');
      case 7:
        return _buildComingSoonPage('일일 데이터 관리');
      default:
        return const SystemSettingsPage();
    }
  }

  Widget _buildComingSoonPage(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            '$title 기능',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '준비 중인 기능입니다. 곧 제공될 예정입니다.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}