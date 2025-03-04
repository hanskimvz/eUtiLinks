import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int selectedMainMenuIndex;
  final int? selectedSubMenuIndex;
  final Function(int)? onSubMenuSelected;
  final VoidCallback? onLogout;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedMainMenuIndex,
    this.selectedSubMenuIndex,
    this.onSubMenuSelected,
    this.onLogout,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedMainMenuIndex;
  late int _selectedSubMenuIndex;

  @override
  void initState() {
    super.initState();
    _selectedMainMenuIndex = widget.selectedMainMenuIndex;
    _selectedSubMenuIndex = widget.selectedSubMenuIndex ?? 0;
  }

  List<String> _getSubMenuItems() {
    switch (_selectedMainMenuIndex) {
      case 0:
        return MenuConstants.getInfoManagementSubmenus(context);
      case 1:
        return MenuConstants.getStatisticsSubmenus(context);
      case 2:
        return MenuConstants.getSettingsSubmenus(context);
      case 3:
        return MenuConstants.getInstallerSubmenus(context);
      default:
        return [];
    }
  }

  String _getMainMenuTitle() {
    switch (_selectedMainMenuIndex) {
      case 0:
        return MenuConstants.getInfoManagement(context);
      case 1:
        return MenuConstants.getStatistics(context);
      case 2:
        return MenuConstants.getSettings(context);
      case 3:
        return MenuConstants.getInstaller(context);
      default:
        return '';
    }
  }

  void _onMainMenuTap(int index) {
    if (_selectedMainMenuIndex == index) return;
    
    setState(() {
      _selectedMainMenuIndex = index;
      _selectedSubMenuIndex = 0;
    });
    
    // 페이지 이동 로직
    switch (index) {
      case 0:
        developer.log('정보관리 탭 클릭: ${AppRouter.infoManagement}', name: 'MainLayout');
        Navigator.pushReplacementNamed(context, AppRouter.infoManagement);
        break;
      case 1:
        developer.log('현황집계 탭 클릭: ${AppRouter.statistics}', name: 'MainLayout');
        Navigator.pushReplacementNamed(context, AppRouter.statistics);
        break;
      case 2:
        developer.log('설정 탭 클릭: ${AppRouter.configure}', name: 'MainLayout');
        Navigator.pushReplacementNamed(context, AppRouter.configure);
        break;
      case 3:
        developer.log('설치자 탭 클릭: ${AppRouter.installer}', name: 'MainLayout');
        Navigator.pushReplacementNamed(context, AppRouter.installer);
        break;
    }
  }

  void _onSubMenuTap(int index) {
    setState(() {
      _selectedSubMenuIndex = index;
    });
    
    // 서브메뉴 선택 콜백 호출
    if (widget.onSubMenuSelected != null) {
      widget.onSubMenuSelected!(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> subMenuItems = _getSubMenuItems();
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // 자동 뒤로가기 버튼 제거
        title: Row(
          children: [
            // 타이틀
            Text(
              localizations?.appTitle ?? '세진테크 가스 검침 관리 플랫폼',
              style: const TextStyle(
                color: AppTheme.brandColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            // 가운데 정렬을 위한 Spacer
            const Spacer(),
            // 메뉴 탭
            _buildMainMenuTab(0, MenuConstants.getInfoManagement(context)),
            _buildMainMenuTab(1, MenuConstants.getStatistics(context)),
            _buildMainMenuTab(2, MenuConstants.getSettings(context)),
            _buildMainMenuTab(3, MenuConstants.getInstaller(context)),
            // 가운데 정렬을 위한 Spacer
            const Spacer(),
            // 로그아웃 버튼
            TextButton(
              onPressed: widget.onLogout,
              child: Text(
                localizations?.logout ?? '로그아웃',
                style: const TextStyle(color: AppTheme.brandColor),
              ),
            ),
          ],
        ),
        titleSpacing: 16,
      ),
      body: Row(
        children: [
          // 서브메뉴 패널
          Container(
            width: 200,
            color: const Color(0xFFF5F5F5), // 아주 약한 회색 배경색 적용
            child: Column(
              children: [
                Container(
                  color: AppTheme.brandColor,
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: Text(
                    _getMainMenuTitle(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.subtitleFontSize,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: subMenuItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 20.0, right: 16.0), // 왼쪽에 5픽셀 추가 여백
                        title: Text(subMenuItems[index]),
                        selected: _selectedSubMenuIndex == index,
                        selectedTileColor: Colors.grey[200],
                        selectedColor: AppTheme.brandColor,
                        onTap: () => _onSubMenuTap(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // 메인 콘텐츠 영역
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenuTab(int index, String title) {
    final bool isSelected = _selectedMainMenuIndex == index;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => _onMainMenuTap(index),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: isSelected ? Colors.grey[100] : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.brandColor : AppTheme.inactiveColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
} 