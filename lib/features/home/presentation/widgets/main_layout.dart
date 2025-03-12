import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../../../../core/constants/menu_constants.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../l10n/app_localizations.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final int selectedMainMenuIndex;
  final int? selectedSubMenuIndex;
  final Function(int)? onSubMenuSelected;
  final VoidCallback? onLogout;
  final bool hideSidebar;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    required this.selectedMainMenuIndex,
    this.selectedSubMenuIndex,
    this.onSubMenuSelected,
    this.onLogout,
    this.hideSidebar = false,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedMainMenuIndex;
  late int _selectedSubMenuIndex;
  bool _isMenuOpen = false;

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
      _isMenuOpen = false;
    });

    // 페이지 이동 로직
    switch (index) {
      case 0:
        developer.log(
          '정보관리 탭 클릭: ${AppRouter.infoManagement}',
          name: 'MainLayout',
        );
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

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> subMenuItems = _getSubMenuItems();
    final localizations = AppLocalizations.of(context);
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // 자동 뒤로가기 버튼 제거
        title:
            isMobile
                ? GestureDetector(
                  onTap: _toggleMenu,
                  child: Row(
                    children: [
                      Text(
                        localizations?.appTitle ?? '세진테크 가스 검침 관리 플랫폼',
                        style: const TextStyle(
                          color: AppTheme.brandColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isMenuOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: AppTheme.brandColor,
                      ),
                    ],
                  ),
                )
                : Row(
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
        actions:
            isMobile
                ? [
                  TextButton(
                    onPressed: widget.onLogout,
                    child: Text(
                      localizations?.logout ?? '로그아웃',
                      style: const TextStyle(color: AppTheme.brandColor),
                    ),
                  ),
                ]
                : null,
      ),
      body: Column(
        children: [
          // 모바일에서 메뉴가 열려있을 때 표시되는 메인 메뉴
          if (isMobile && _isMenuOpen)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMobileMainMenuTab(
                    0,
                    MenuConstants.getInfoManagement(context),
                  ),
                  _buildMobileMainMenuTab(
                    1,
                    MenuConstants.getStatistics(context),
                  ),
                  _buildMobileMainMenuTab(
                    2,
                    MenuConstants.getSettings(context),
                  ),
                  _buildMobileMainMenuTab(
                    3,
                    MenuConstants.getInstaller(context),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Row(
              children: [
                // 서브메뉴 패널 - hideSidebar가 true이면 표시하지 않음
                if (!widget.hideSidebar && !isMobile)
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
                                contentPadding: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 16.0,
                                ), // 왼쪽에 5픽셀 추가 여백
                                leading: _getSubMenuIcon(widget.selectedMainMenuIndex, index),
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
          foregroundColor: isSelected ? AppTheme.brandColor : Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMainMenuTab(int index, String title) {
    final bool isSelected = _selectedMainMenuIndex == index;

    return InkWell(
      onTap: () => _onMainMenuTap(index),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        color: isSelected ? Colors.grey[200] : Colors.white,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.brandColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _getSubMenuIcon(int mainIndex, int subIndex) {
    // 메인 메뉴 인덱스에 따라 서브메뉴 아이콘 반환
    switch (mainIndex) {
      case 0: // 정보관리
        return _getInfoManagementIcon(subIndex);
      case 1: // 현황집계
        return _getStatisticsIcon(subIndex);
      case 2: // 설정
        return _getSettingsIcon(subIndex);
      case 3: // 설치자
        return const Icon(Icons.build, color: Colors.grey);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  Widget _getInfoManagementIcon(int subIndex) {
    switch (subIndex) {
      case 0: // 단말기 조회
        return const Icon(Icons.devices, color: Colors.blue);
      case 1: // 수신데이터 조회
        return const Icon(Icons.data_usage, color: Colors.green);
      case 2: // 사용량 조회
        return const Icon(Icons.show_chart, color: Colors.orange);
      case 3: // 이상 검침 조회/해제
        return const Icon(Icons.warning_amber_outlined, color: Colors.red);
      case 4: // DB 내용보기
        return const Icon(Icons.storage, color: Colors.purple);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  Widget _getStatisticsIcon(int subIndex) {
    switch (subIndex) {
      case 0: // 일일 현황
        return const Icon(Icons.today, color: Colors.blue);
      case 1: // 월별 현황
        return const Icon(Icons.calendar_month, color: Colors.green);
      case 2: // 연간 현황
        return const Icon(Icons.calendar_today, color: Colors.orange);
      case 3: // 가입자별 현황
        return const Icon(Icons.people, color: Colors.purple);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  Widget _getSettingsIcon(int subIndex) {
    switch (subIndex) {
      case 0: // 시스템 설정
        return const Icon(Icons.settings, color: Colors.blue);
      case 1: // 권한 관리
        return const Icon(Icons.security, color: Colors.red);
      case 2: // 사용자 관리
        return const Icon(Icons.person, color: Colors.green);
      case 3: // 위치 관리
        return const Icon(Icons.location_on, color: Colors.orange);
      case 4: // 단말기 관리
        return const Icon(Icons.devices, color: Colors.purple);
      case 5: // 가입자 관리
        return const Icon(Icons.people, color: Colors.indigo);
      case 6: // 이벤트 관리
        return const Icon(Icons.event, color: Colors.teal);
      case 7: // 일일 데이터 관리
        return const Icon(Icons.data_usage, color: Colors.brown);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }
}
