import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/services/auth_service.dart';
// import '../../../auth/presentation/pages/login_page.dart';
import '../../../home/presentation/widgets/main_layout.dart';
import 'device_query_page.dart';
import 'received_data_query_page.dart';
import 'usage_query_page.dart';
import 'anomaly_query_page.dart';
import 'db_viewer_page.dart';

class InfoManagementPage extends StatefulWidget {
  const InfoManagementPage({super.key});

  @override
  State<InfoManagementPage> createState() => _InfoManagementPageState();
}

class _InfoManagementPageState extends State<InfoManagementPage> {
  int _selectedSubMenuIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: MenuConstants.infoManagement,
      selectedMainMenuIndex: 0,
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
        return const DeviceQueryPage();
      case 1:
        return const ReceivedDataQueryPage();
      case 2:
        return const UsageQueryPage();
      case 3:
        return const AnomalyQueryPage();
      case 4:
        return const DbViewerPage();
      default:
        return const DeviceQueryPage();
    }
  }
}
