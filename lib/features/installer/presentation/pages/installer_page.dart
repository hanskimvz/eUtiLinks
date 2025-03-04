import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/constants/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/main_layout.dart';

class InstallerPage extends StatefulWidget {
  const InstallerPage({super.key});

  @override
  State<InstallerPage> createState() => _InstallerPageState();
}

class _InstallerPageState extends State<InstallerPage> {
  int _selectedSubMenuIndex = 0;

  void _onSubMenuSelected(int index) {
    setState(() {
      _selectedSubMenuIndex = index;
    });
  }

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
    final localizations = AppLocalizations.of(context)!;
    
    return MainLayout(
      title: MenuConstants.getInstaller(context),
      selectedMainMenuIndex: 3,
      selectedSubMenuIndex: _selectedSubMenuIndex,
      onSubMenuSelected: _onSubMenuSelected,
      onLogout: _logout,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.installerMenu,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '설치자 관련 기능을 이용할 수 있습니다.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  '설치자 기능 준비 중입니다.',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 