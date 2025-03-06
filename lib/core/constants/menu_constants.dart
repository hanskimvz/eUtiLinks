import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MenuConstants {
  // 메인 메뉴 항목 (정적 메서드로 변경)
  static String getInfoManagement(BuildContext context) {
    return AppLocalizations.of(context)?.infoManagement ?? '정보관리';
  }

  static String getStatistics(BuildContext context) {
    return AppLocalizations.of(context)?.statistics ?? '현황집계';
  }

  static String getSettings(BuildContext context) {
    return AppLocalizations.of(context)?.settings ?? '설정';
  }

  static String getInstaller(BuildContext context) {
    return AppLocalizations.of(context)?.installerMenu ?? '설치자';
  }

  // 정보관리 서브메뉴 항목
  static List<String> getInfoManagementSubmenus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return ['단말기 조회', '수신데이터 조회', '사용량 조회', '이상 검침 조회/해제', 'DB 내용보기'];
    }

    return [
      localizations.deviceQuery,
      localizations.receivedDataQuery,
      localizations.usageQuery,
      localizations.abnormalMeterQuery,
      localizations.dbViewer,
    ];
  }

  // 현황집계 서브메뉴 항목
  static List<String> getStatisticsSubmenus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return ['일일 현황', '월별 현황', '연간 현황', '가입자별 현황'];
    }

    return [
      localizations.dailyStatistics,
      localizations.monthlyStatistics,
      localizations.yearlyStatistics,
      localizations.subscriberStatistics,
    ];
  }

  // 설정 서브메뉴 항목
  static List<String> getSettingsSubmenus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return [
        '시스템 설정',
        '권한 관리',
        '사용자 관리',
        '위치 관리',
        '단말기 관리',
        '가입자 관리',
        '이벤트 관리',
        '일일 데이터 관리',
      ];
    }

    return [
      localizations.systemSettings,
      localizations.permissionManagement,
      localizations.userManagement,
      localizations.locationManagement,
      localizations.deviceManagement,
      localizations.subscriberManagement,
      localizations.eventManagement,
      localizations.dailyDataManagement,
    ];
  }

  static List<String> getInstallerSubmenus(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return [];
    }
    return [];
  }

  // 기존 상수 (하위 호환성 유지)
  static const String infoManagement = '정보관리';
  static const String statistics = '현황집계';
  static const String settings = '설정';

  static const List<String> infoManagementSubmenus = [
    '단말기 조회',
    '수신데이터 조회',
    '사용량 조회',
    '이상 검침 조회/해제',
    'DB 내용보기',
  ];

  static const List<String> statisticsSubmenus = [
    '일일 현황',
    '월별 현황',
    '연간 현황',
    '가입자별 현황',
  ];

  static const List<String> settingsSubmenus = [
    '시스템 설정',
    '권한 관리',
    '사용자 관리',
    '위치 관리',
    '단말기 관리',
    '가입자 관리',
    '이벤트 관리',
    '일일 데이터 관리',
  ];

  static String getDeviceManagement(BuildContext context) {
    return AppLocalizations.of(context)?.deviceManagement ?? '단말기 관리';
  }

  static String getSubscriberManagement(BuildContext context) {
    return AppLocalizations.of(context)?.subscriberManagement ?? '가입자 관리';
  }
}
