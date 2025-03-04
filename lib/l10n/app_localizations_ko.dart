// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '세진테크 가스 검침 관리 플랫폼';

  @override
  String get logout => '로그아웃';

  @override
  String get login => '로그인';

  @override
  String get username => '아이디';

  @override
  String get password => '비밀번호';

  @override
  String get rememberMe => '로그인 상태 유지';

  @override
  String get forgotPassword => '비밀번호 찾기';

  @override
  String get usernameRequired => '아이디를 입력하세요';

  @override
  String get passwordRequired => '비밀번호를 입력하세요';

  @override
  String get invalidCredentials => '아이디 또는 비밀번호가 올바르지 않습니다.';

  @override
  String serverConnectionError(String error) {
    return '서버 연결 오류: $error';
  }

  @override
  String get forgotPasswordTitle => '비밀번호 찾기';

  @override
  String get forgotPasswordMessage => '관리자에게 문의하세요.';

  @override
  String get confirm => '확인';

  @override
  String get infoManagement => '정보관리';

  @override
  String get statistics => '현황집계';

  @override
  String get settings => '설정';

  @override
  String get deviceQuery => '단말기 조회';

  @override
  String get receivedDataQuery => '수신데이터 조회';

  @override
  String get usageQuery => '사용량 조회';

  @override
  String get abnormalMeterQuery => '이상 검침 조회/해제';

  @override
  String get dailyStatistics => '일일 현황';

  @override
  String get monthlyStatistics => '월별 현황';

  @override
  String get yearlyStatistics => '연간 현황';

  @override
  String get subscriberStatistics => '가입자별 현황';

  @override
  String get systemSettings => '시스템 설정';

  @override
  String get permissionManagement => '권한 관리';

  @override
  String get userManagement => '사용자 관리';

  @override
  String get locationManagement => '위치 관리';

  @override
  String get deviceManagement => '단말기 관리';

  @override
  String get subscriberManagement => '가입자 관리';

  @override
  String get eventManagement => '이벤트 관리';

  @override
  String get dailyDataManagement => '일일 데이터 관리';
}
