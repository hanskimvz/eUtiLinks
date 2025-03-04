import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ko'),
    Locale('en')
  ];

  /// 앱 타이틀
  ///
  /// In ko, this message translates to:
  /// **'세진테크 가스 검침 관리 플랫폼'**
  String get appTitle;

  /// 로그아웃 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// 로그인 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// 사용자 아이디 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'아이디'**
  String get username;

  /// 비밀번호 입력 필드 라벨
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// 로그인 상태 유지 체크박스 라벨
  ///
  /// In ko, this message translates to:
  /// **'로그인 상태 유지'**
  String get rememberMe;

  /// 비밀번호 찾기 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 찾기'**
  String get forgotPassword;

  /// 아이디 입력 필드 유효성 검사 메시지
  ///
  /// In ko, this message translates to:
  /// **'아이디를 입력하세요'**
  String get usernameRequired;

  /// 비밀번호 입력 필드 유효성 검사 메시지
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 입력하세요'**
  String get passwordRequired;

  /// 로그인 실패 시 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'아이디 또는 비밀번호가 올바르지 않습니다.'**
  String get invalidCredentials;

  /// 서버 연결 실패 시 오류 메시지
  ///
  /// In ko, this message translates to:
  /// **'서버 연결 오류: {error}'**
  String serverConnectionError(String error);

  /// 비밀번호 찾기 대화상자 제목
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 찾기'**
  String get forgotPasswordTitle;

  /// 비밀번호 찾기 대화상자 메시지
  ///
  /// In ko, this message translates to:
  /// **'관리자에게 문의하세요.'**
  String get forgotPasswordMessage;

  /// 확인 버튼 텍스트
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// 정보관리 메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'정보관리'**
  String get infoManagement;

  /// 현황집계 메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'현황집계'**
  String get statistics;

  /// 설정 메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// 단말기 조회 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'단말기 조회'**
  String get deviceQuery;

  /// 수신데이터 조회 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'수신데이터 조회'**
  String get receivedDataQuery;

  /// 사용량 조회 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'사용량 조회'**
  String get usageQuery;

  /// 이상 검침 조회/해제 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'이상 검침 조회/해제'**
  String get abnormalMeterQuery;

  /// 일일 현황 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'일일 현황'**
  String get dailyStatistics;

  /// 월별 현황 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'월별 현황'**
  String get monthlyStatistics;

  /// 연간 현황 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'연간 현황'**
  String get yearlyStatistics;

  /// 가입자별 현황 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'가입자별 현황'**
  String get subscriberStatistics;

  /// 시스템 설정 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정'**
  String get systemSettings;

  /// 권한 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'권한 관리'**
  String get permissionManagement;

  /// 사용자 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'사용자 관리'**
  String get userManagement;

  /// 위치 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'위치 관리'**
  String get locationManagement;

  /// 단말기 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'단말기 관리'**
  String get deviceManagement;

  /// 가입자 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'가입자 관리'**
  String get subscriberManagement;

  /// 이벤트 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'이벤트 관리'**
  String get eventManagement;

  /// 일일 데이터 관리 서브메뉴 이름
  ///
  /// In ko, this message translates to:
  /// **'일일 데이터 관리'**
  String get dailyDataManagement;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ko', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ko': return AppLocalizationsKo();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
