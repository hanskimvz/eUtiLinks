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
  String get logoutTitle => '로그아웃';

  @override
  String get logoutConfirmation => '정말 로그아웃 하시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get login => '로그인';

  @override
  String get username => '사용자 이름';

  @override
  String get password => '비밀번호';

  @override
  String get rememberMe => '로그인 상태 유지';

  @override
  String get forgotPassword => '비밀번호 찾기';

  @override
  String get usernameRequired => '사용자 이름을 입력해주세요';

  @override
  String get passwordRequired => '비밀번호를 입력해주세요';

  @override
  String get invalidCredentials => '잘못된 사용자 이름 또는 비밀번호입니다';

  @override
  String serverConnectionError(Object error) {
    return '서버 연결 오류: $error';
  }

  @override
  String get forgotPasswordTitle => '비밀번호 찾기';

  @override
  String get forgotPasswordMessage => '관리자에게 문의해주세요.';

  @override
  String get confirm => '확인';

  @override
  String get infoManagement => '정보 관리';

  @override
  String get statistics => '통계';

  @override
  String get settings => '설정';

  @override
  String get installerMenu => '설치자';

  @override
  String get deviceQuery => '단말기 조회';

  @override
  String get receivedDataQuery => '수신 데이터 조회';

  @override
  String get usageQuery => '사용량 조회';

  @override
  String get abnormalMeterQuery => '비정상 계량기 조회/해제';

  @override
  String get dailyStatistics => '일일 통계';

  @override
  String get monthlyStatistics => '월간 통계';

  @override
  String get yearlyStatistics => '연간 통계';

  @override
  String get subscriberStatistics => '가입자 통계';

  @override
  String get systemSettings => '시스템 설정';

  @override
  String get systemSettingsDescription => '시스템 설정을 관리합니다.';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get serverSettings => '서버 설정';

  @override
  String get serverSettingsDescription => '애플리케이션이 연결할 서버를 설정합니다.';

  @override
  String get selectServerEnvironment => '서버 환경 선택';

  @override
  String get devServer => '개발 서버';

  @override
  String get prodServer => '운영 서버';

  @override
  String get address => '주소';

  @override
  String get useCustomServer => '사용자 정의 서버 사용';

  @override
  String get serverAddress => '서버 주소';

  @override
  String get serverAddressHint => '예: 192.168.1.100';

  @override
  String get serverPort => '서버 포트';

  @override
  String get serverPortHint => '예: 5100';

  @override
  String get reset => '초기화';

  @override
  String get serverAddressRequired => '서버 주소를 입력해주세요.';

  @override
  String get validPortRequired => '유효한 포트 번호를 입력해주세요 (1-65535).';

  @override
  String get serverSettingsSaved => '서버 설정이 저장되었습니다.';

  @override
  String get serverSettingsReset => '서버 설정이 초기화되었습니다.';

  @override
  String get error => '오류';

  @override
  String get permissionManagement => '권한 관리';

  @override
  String get userManagement => '사용자 관리';

  @override
  String get locationManagement => '위치 관리';

  @override
  String get locationManagementDescription => '단말기 및 가입자의 위치를 관리합니다';

  @override
  String get deviceManagement => '단말기 관리';

  @override
  String get deviceManagementDescription => '단말기를 관리하고 상태를 모니터링합니다.';

  @override
  String get searchDevice => '단말기 검색';

  @override
  String get searchDeviceHint => '단말기 ID, 이름, 위치 등으로 검색';

  @override
  String get addDevice => '단말기 추가';

  @override
  String get editDevice => '단말기 수정';

  @override
  String get deleteDevice => '단말기 삭제';

  @override
  String deleteDeviceConfirm(Object name) {
    return '$name 단말기를 삭제하시겠습니까?';
  }

  @override
  String get deviceAddedSuccess => '단말기가 추가되었습니다.';

  @override
  String get deviceEditedSuccess => '단말기 정보가 수정되었습니다.';

  @override
  String get deviceDeletedSuccess => '단말기가 삭제되었습니다.';

  @override
  String get deviceId => '단말기 ID';

  @override
  String get deviceName => '단말기 이름';

  @override
  String get deviceNameHint => '예: 가스 계량기 1';

  @override
  String get type => '유형';

  @override
  String get location => '위치';

  @override
  String get locationHint => '예: 서울시 강남구';

  @override
  String get installDate => '설치일자';

  @override
  String get lastCommunication => '마지막 통신';

  @override
  String get subscriberId => '가입자 ID';

  @override
  String get subscriberNo => '가입자 번호';

  @override
  String get subscriberName => '가입자 이름';

  @override
  String get subscriberNameHint => '예: 홍길동';

  @override
  String get batteryLevel => '배터리 레벨';

  @override
  String get totalDevices => '전체 단말기';

  @override
  String get activeDevices => '활성 단말기';

  @override
  String get inactiveDevices => '비활성 단말기';

  @override
  String get needsAttention => '점검 필요';

  @override
  String get subscriberManagement => '가입자 관리';

  @override
  String get subscriberManagementDescription => '가입자 정보를 관리합니다.';

  @override
  String get searchSubscriber => '가입자 검색';

  @override
  String get searchSubscriberHint => 'ID, 이름, 전화번호, 이메일 등으로 검색';

  @override
  String get addSubscriber => '가입자 추가';

  @override
  String get editSubscriber => '가입자 수정';

  @override
  String get deleteSubscriber => '가입자 삭제';

  @override
  String deleteSubscriberConfirm(Object name) {
    return '$name 가입자를 삭제하시겠습니까?';
  }

  @override
  String get subscriberAddedSuccess => '가입자가 추가되었습니다.';

  @override
  String get subscriberEditedSuccess => '가입자 정보가 수정되었습니다.';

  @override
  String get subscriberDeletedSuccess => '가입자가 삭제되었습니다.';

  @override
  String get phoneNumber => '전화번호';

  @override
  String get phoneNumberHint => '예: 010-1234-5678';

  @override
  String get email => '이메일';

  @override
  String get emailHint => '예: example@email.com';

  @override
  String get contractType => '계약 유형';

  @override
  String get contractTypeHint => '예: 일반, 프리미엄';

  @override
  String get registrationDate => '등록일';

  @override
  String get lastPaymentDate => '마지막 결제일';

  @override
  String get deviceCount => '단말기 수';

  @override
  String get memo => '메모';

  @override
  String get memoHint => '가입자에 대한 추가 정보';

  @override
  String get totalSubscribers => '전체 가입자';

  @override
  String get activeSubscribers => '활성 가입자';

  @override
  String get inactiveSubscribers => '비활성 가입자';

  @override
  String get exportSubscribersToExcel => '엑셀로 내보내기';

  @override
  String get subscriberList => '가입자 목록';

  @override
  String get rowsPerPage => '페이지당 행 수';

  @override
  String get status => '상태';

  @override
  String get actions => '작업';

  @override
  String get eventManagement => '이벤트 관리';

  @override
  String get dailyDataManagement => '일일 데이터 관리';

  @override
  String get userManagementDescription => '시스템 사용자를 관리하고 권한을 할당합니다.';

  @override
  String get searchUser => '사용자 검색';

  @override
  String get searchUserHint => '이름, 이메일, 역할 등으로 검색';

  @override
  String get addUser => '사용자 추가';

  @override
  String get refresh => '새로고침';

  @override
  String get code => '코드';

  @override
  String get id => 'ID';

  @override
  String get name => '이름';

  @override
  String get language => '언어';

  @override
  String get role => '역할';

  @override
  String get korean => '한국어';

  @override
  String get english => '영어';

  @override
  String get chinese => '중국어';

  @override
  String get admin => '관리자';

  @override
  String get operator => '운영자';

  @override
  String get user => '일반 사용자';

  @override
  String get installer => '설치자';

  @override
  String get active => '활성';

  @override
  String get inactive => '비활성';

  @override
  String get edit => '수정';

  @override
  String get delete => '삭제';

  @override
  String get activate => '활성화';

  @override
  String get deactivate => '비활성화';

  @override
  String get editUser => '사용자 수정';

  @override
  String get deleteUser => '사용자 삭제';

  @override
  String get deleteUserConfirmation => '이 사용자를 삭제하시겠습니까?';

  @override
  String deleteUserConfirm(Object name) {
    return '$name 사용자를 삭제하시겠습니까?';
  }

  @override
  String get save => '저장';

  @override
  String get userAdded => '사용자가 추가되었습니다.';

  @override
  String get userAddedSuccess => '사용자가 추가되었습니다.';

  @override
  String get userEditedSuccess => '사용자 정보가 수정되었습니다.';

  @override
  String get userDeletedSuccess => '사용자가 삭제되었습니다.';

  @override
  String userStatusChangedSuccess(Object name, Object status) {
    return '$name 사용자가 $status되었습니다.';
  }

  @override
  String get bulkDeviceRegistration => '단말기 일괄 등록';

  @override
  String get deviceUidListDescription => '단말기 UID 목록\n(한 줄에 하나의 UID를 입력하세요)';

  @override
  String get releaseDate => '출고일자';

  @override
  String get installerId => '설치자 ID';

  @override
  String get enterAtLeastOneDeviceUid => '단말기 UID를 하나 이상 입력해주세요.';

  @override
  String get enterReleaseDate => '출고일을 입력해주세요.';

  @override
  String get enterInstallerId => '설치자 ID를 입력해주세요.';

  @override
  String devicesRegisteredSuccess(Object count) {
    return '$count개의 단말기가 등록되었습니다.';
  }

  @override
  String get deviceRegistrationFailed => '단말기 등록 실패';

  @override
  String get register => '등록';

  @override
  String get exportToExcel => '엑셀 파일로 내보내기';

  @override
  String get deviceUid => '단말기 UID';

  @override
  String get customerName => '고객명';

  @override
  String get customerNo => '고객번호';

  @override
  String get meterId => '미터기 ID';

  @override
  String get lastCount => '마지막 검침';

  @override
  String get lastAccess => '마지막 통신';

  @override
  String get battery => '배터리';

  @override
  String get deviceInfo => '장치 정보';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get customerInfo => '고객 정보';

  @override
  String get deviceNotFound => '단말기를 찾을 수 없습니다';

  @override
  String get welcome => '환영합니다';

  @override
  String get excelFileSaved => '엑셀 파일이 저장되었습니다.';

  @override
  String excelFileSaveError(Object error) {
    return '엑셀 파일 저장 중 오류 발생: $error';
  }

  @override
  String get shareHouse => '공동주택';

  @override
  String get category => '용도';

  @override
  String get subscriberClass => '등급';

  @override
  String get inOutdoor => '실내/실외';

  @override
  String get bindDeviceId => '장치 ID';

  @override
  String get bindDate => '연결 날짜';

  @override
  String get deviceList => '디바이스 목록';

  @override
  String get installerPageDescription => '설치자 관련 기능을 이용할 수 있습니다.';

  @override
  String get deviceSearch => '장치 검색';

  @override
  String get deviceSearchHint => '장치 UID, 미터기 ID 등으로 검색';

  @override
  String get statusUnknown => '알 수 없음';

  @override
  String get statusNormal => '정상';

  @override
  String get statusInactive => '비활성';

  @override
  String get statusWarning => '주의';

  @override
  String get statusError => '오류';

  @override
  String get scanWithCamera => '카메라로 스캔';

  @override
  String imageCaptured(Object path) {
    return '이미지가 촬영되었습니다: $path';
  }

  @override
  String cameraError(Object error) {
    return '카메라 오류: $error';
  }

  @override
  String get cameraPermissionDenied => '카메라 권한이 필요합니다.';

  @override
  String get cameraPermissionPermanentlyDenied => '카메라 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.';

  @override
  String get initialValue => '계량기 초기값';

  @override
  String get dataInterval => '데이터 전송주기';

  @override
  String get comment => '코멘트';

  @override
  String get completeInstallation => '설치 완료';

  @override
  String get completeUninstallation => '해제 완료';

  @override
  String get installationCompleted => '설치가 완료되었습니다.';

  @override
  String get selectDate => '날짜 선택';

  @override
  String get enterComment => '설치 관련 코멘트를 입력하세요';

  @override
  String get r1hour => '1시간';

  @override
  String get r2hours => '2시간';

  @override
  String get r3hours => '3시간';

  @override
  String get r6hours => '6시간';

  @override
  String get r12hours => '12시간';

  @override
  String get r1day => '1일';

  @override
  String get selectInterval => '주기 선택';

  @override
  String scanCompleted(Object code) {
    return '코드 스캔 완료: $code';
  }

  @override
  String get qrScanTitle => 'QR/바코드 스캔';

  @override
  String get toggleFlash => '플래시 켜기/끄기';

  @override
  String get switchCamera => '카메라 전환';

  @override
  String get scanInstructions => '바코드나 QR 코드를 스캔하세요';

  @override
  String get subscriberInfo => '가입자 정보';

  @override
  String get retry => '다시 시도';

  @override
  String get subscriberNotFound => '가입자를 찾을 수 없습니다';

  @override
  String get addressInfo => '주소 정보';

  @override
  String get contactInfo => '연락처 정보';

  @override
  String get contractInfo => '계약 정보';

  @override
  String get fullAddress => '전체 주소';

  @override
  String get province => '도/시';

  @override
  String get city => '시/군';

  @override
  String get district => '구/동';

  @override
  String get detailAddress => '상세 주소';

  @override
  String get apartment => '아파트';

  @override
  String get dbViewer => 'DB Viewer(for developing)';

  @override
  String get dbViewerDescription => '데이터베이스 테이블의 내용을 조회합니다. 개발 및 디버깅 용도로만 사용하세요.';

  @override
  String get installationConfirmation => '설치 확인';

  @override
  String get pressButtonForFiveSeconds => '버튼을 5초간 누르세요. 액정에 E1메시지가 나타나면 통신을 시작합니다';

  @override
  String get communicationWillStartAfterTenSeconds => '페이지 로드 후 10초 후에 서버와의 통신 상태 확인이 시작됩니다.\n장치와 서버 간 통신이 시작되면 아래에 상태가 표시됩니다.';

  @override
  String get secondsBeforeCommunication => '초 후 통신을 시작합니다...';

  @override
  String get lastCommunicationTime => '마지막 통신 시간';

  @override
  String get null_value => 'NULL';

  @override
  String get checkingCommunicationStatus => '통신 상태 확인 중...';

  @override
  String get waitingForCommunication => '통신 시작 대기 중';

  @override
  String get seconds => '초';

  @override
  String get deviceCommunicatingSuccessfully => '장치와 서버가 성공적으로 통신하고 있습니다!';

  @override
  String get deviceCommunicationProblem => '장치와 서버 간 통신이 원활하지 않습니다. 장치 상태를 확인해주세요.';

  @override
  String get invalidCommunicationTimeInfo => '유효한 통신 시간 정보가 없습니다.';

  @override
  String get cannotGetDeviceInfo => '장치 정보를 가져올 수 없습니다.';

  @override
  String get communicationError => '서버 통신 중 오류가 발생했습니다';

  @override
  String get connectAnotherDevice => '다른 장비 연결';

  @override
  String get disconnectDevice => '장비 연결 해제';

  @override
  String get disconnectingDevice => '장비 연결 해제 중...';

  @override
  String get deviceDisconnectedSuccessfully => '장비 연결이 성공적으로 해제되었습니다';

  @override
  String get deviceDisconnectionError => '장비 연결 해제 중 오류 발생';

  @override
  String get pendingUserApproval => '미승인 사용자 목록';

  @override
  String get noPendingUsers => '미승인 사용자가 없습니다.';

  @override
  String get dbName => 'DB 이름';

  @override
  String get enterUserDbName => '사용자의 데이터베이스 이름을 입력하세요';

  @override
  String get activationStatus => '활성화 상태';

  @override
  String get userApproved => '사용자가 승인되었습니다.';

  @override
  String get approve => '승인';
}
