# 설치자 페이지 문서

이 문서는 가스 미터기 설치 앱의 설치자 관련 페이지들에 대한 설명입니다. 설치자 페이지는 장치 목록 조회, 장치 정보 확인 및 설치, 설치 확인 등의 기능을 제공합니다.

## 파일 구조

```
lib/features/installer/presentation/pages/
├── installer_page.dart          # 설치자 메인 페이지 (장치 목록)
├── installer_device_info.dart   # 장치 정보 및 설치 페이지
├── installation_confirm_page.dart # 설치 확인 페이지
└── qr_scanner_page.dart         # QR/바코드 스캐너 페이지
```

## 페이지 설명

### 1. 설치자 메인 페이지 (installer_page.dart)

설치자가 담당하는 장치 목록을 조회하고 관리하는 페이지입니다.

#### 주요 기능
- 설치자에게 할당된 장치 목록 조회
- 장치 검색 (장치 UID, 미터기 ID, 출고일자, 상태 등으로 필터링)
- QR/바코드 스캔을 통한 장치 검색
- 장치 목록 정렬 (장치 UID, 출고일자, 미터기 ID, 상태별)
- 장치 선택 시 상세 정보 페이지로 이동
- 로그아웃 기능

#### 사용 방법
1. 페이지 상단의 검색창을 통해 장치를 검색할 수 있습니다.
2. 카메라 아이콘을 클릭하여 QR/바코드를 스캔할 수 있습니다.
3. 새로고침 아이콘을 클릭하여 장치 목록을 갱신할 수 있습니다.
4. 장치 목록의 헤더를 클릭하여 정렬 기준을 변경할 수 있습니다.
5. 장치 항목을 클릭하여 해당 장치의 상세 정보 페이지로 이동할 수 있습니다.

### 2. 장치 정보 및 설치 페이지 (installer_device_info.dart)

선택한 장치의 상세 정보를 확인하고 설치 정보를 입력하는 페이지입니다.

#### 주요 기능
- 장치 기본 정보 표시 (장치 UID, 출고일자, 설치자 ID 등)
- 미터기 ID 입력 및 QR/바코드 스캔
- 미터기 ID 입력 시 자동으로 가입자 정보 조회 및 표시
- 설치일자 선택
- 계량기 초기값 입력
- 데이터 전송주기 설정
- 장치 상태 설정 (활성/비활성)
- 코멘트 입력
- 설치 완료 또는 해제 완료 처리

#### 사용 방법
1. 미터기 ID를 입력하거나 카메라 아이콘을 클릭하여 QR/바코드를 스캔합니다.
2. 미터기 ID 입력 시 자동으로 가입자 정보가 조회됩니다.
3. 설치일자를 선택합니다.
4. 계량기 초기값을 입력합니다 (활성 상태일 때 필수).
5. 데이터 전송주기를 선택합니다.
6. 장치 상태를 설정합니다 (활성/비활성).
7. 필요한 경우 코멘트를 입력합니다.
8. '설치 완료' 또는 '해제 완료' 버튼을 클릭하여 설치를 완료합니다.
   - 활성 상태일 때는 미터기 ID, 계량기 초기값, 가입자 정보가 필요합니다.
   - 비활성 상태일 때는 제약 조건이 없습니다.

### 3. 설치 확인 페이지 (installation_confirm_page.dart)

장치 설치 후 서버와의 통신 상태를 확인하는 페이지입니다.

#### 주요 기능
- 장치와 서버 간 통신 상태 확인
- 10초 카운트다운 후 자동으로 통신 상태 확인 시작
- 5초마다 통신 상태 폴링
- 마지막 통신 시간 표시
- 통신 성공/실패 상태 표시
- 다른 장비 연결 기능
- 장비 연결 해제 기능

#### 사용 방법
1. 페이지 로드 후 10초 카운트다운이 시작됩니다.
2. 카운트다운이 끝나면 자동으로 통신 상태 확인이 시작됩니다.
3. 장치의 버튼을 5초간 눌러 E1 메시지가 나타나면 통신이 시작됩니다.
4. 통신 상태에 따라 화면에 성공/실패 메시지가 표시됩니다.
5. '다른 장비 연결' 버튼을 클릭하여 장비 목록 페이지로 이동할 수 있습니다.
6. '장비 연결 해제' 버튼을 클릭하여 장비 연결을 해제할 수 있습니다.

### 4. QR/바코드 스캐너 페이지 (qr_scanner_page.dart)

QR 코드나 바코드를 스캔하는 페이지입니다.

#### 주요 기능
- QR 코드 및 바코드 스캔
- 플래시 켜기/끄기
- 전면/후면 카메라 전환
- 스캔 결과 자동 반환 또는 콜백 함수 호출

#### 사용 방법
1. 카메라를 QR 코드나 바코드에 향하게 합니다.
2. 스캔이 성공하면 자동으로 결과가 반환됩니다.
3. 필요한 경우 상단 메뉴에서 플래시를 켜거나 카메라를 전환할 수 있습니다.

## 데이터 흐름

1. 설치자 로그인 → 설치자 메인 페이지 (장치 목록)
2. 장치 선택 → 장치 정보 및 설치 페이지
3. 설치 정보 입력 및 설치 완료 → 설치 확인 페이지
4. 통신 확인 후 → 설치자 메인 페이지 (다른 장치 설치) 또는 장치 연결 해제

## 주요 클래스 및 위젯

### InstallerPage
- `_InstallerPageState`: 설치자 메인 페이지의 상태 관리
- 주요 메서드:
  - `_loadDevices()`: 장치 목록 로드
  - `_filterDevices()`: 장치 검색 및 필터링
  - `_navigateToDeviceInfo()`: 장치 정보 페이지로 이동
  - `_openCamera()`: QR/바코드 스캔 카메라 열기

### InstallerDeviceInfoPage
- `_InstallerDeviceInfoPageState`: 장치 정보 페이지의 상태 관리
- 주요 메서드:
  - `_loadDeviceInfo()`: 장치 정보 로드
  - `_fetchCustomerInfo()`: 미터기 ID로 가입자 정보 조회
  - `_completeInstallation()`: 설치 완료 처리
  - `_openCamera()`: QR/바코드 스캔 카메라 열기

### InstallationConfirmPage
- `_InstallationConfirmPageState`: 설치 확인 페이지의 상태 관리
- 주요 메서드:
  - `_startCountdown()`: 카운트다운 시작
  - `_startPolling()`: 통신 상태 확인 시작
  - `_pollDeviceStatus()`: 장치 상태 폴링
  - `_disconnectDevice()`: 장치 연결 해제

### QRScannerPage
- `_QRScannerPageState`: QR/바코드 스캐너 페이지의 상태 관리
- 주요 메서드:
  - `_handleScan()`: 스캔 결과 처리

## API 연동

설치자 모듈은 다음과 같은 API 서비스를 사용합니다:

### DeviceService
- 장치 관련 API 호출을 담당하는 서비스 클래스
- 주요 메서드:
  - `getDevicesWithFilter()`: 필터 조건에 맞는 장치 목록 조회
  - `getDeviceById()`: 장치 ID로 장치 정보 조회
  - `updateDeviceInstallation()`: 장치 설치 정보 업데이트
  - `getDeviceStatus()`: 장치 통신 상태 조회

### SubscriberService
- 가입자 정보 관련 API 호출을 담당하는 서비스 클래스
- 주요 메서드:
  - `getSubscriberByMeterId()`: 미터기 ID로 가입자 정보 조회

### API 요청 예시

#### 장치 목록 조회
```dart
// 설치자 ID로 필터링된 장치 목록 조회
final devices = await _deviceService.getDevicesWithFilter(
  filter: {'installer_id': loginId},
);
```

#### 장치 설치 정보 업데이트
```dart
// 설치 정보 업데이트를 위한 데이터 준비
final Map<String, dynamic> updateData = {
  'device_uid': deviceUid,
  'meter_id': meterIdValue,
  'install_date': installDateFormatted,
  'initial_value': initialValue,
  'ref_interval': intervalMinutes,
  'flag': isActive ? 'active' : 'inactive',
  'comment': commentText,
};

// API 호출
await _deviceService.updateDeviceInstallation(updateData);
```

#### 장치 통신 상태 확인
```dart
// 장치 상태 폴링
final deviceStatus = await _deviceService.getDeviceStatus(deviceUid);
if (deviceStatus != null && deviceStatus.lastAccess != null) {
  // 마지막 통신 시간 업데이트
  setState(() {
    _lastAccessTime = deviceStatus.lastAccess;
    _isConnected = true;
  });
}
```

## 데이터 모델

### DeviceModel
- 장치 정보를 담는 데이터 모델
- 주요 속성:
  - `deviceUid`: 장치 고유 식별자
  - `meterId`: 미터기 ID
  - `releaseDate`: 출고일자
  - `installDate`: 설치일자
  - `flag`: 장치 상태 (active, inactive, warning, error 등)
  - `lastCount`: 마지막 검침값
  - `lastAccess`: 마지막 통신 시간
  - `refInterval`: 데이터 전송주기 (분 단위)
  - `installerId`: 설치자 ID
  - `comment`: 설치 관련 코멘트

### SubscriberModel
- 가입자 정보를 담는 데이터 모델
- 주요 속성:
  - `customerName`: 고객 이름
  - `customerNo`: 고객 번호
  - `subscriberNo`: 가입자 번호
  - `address`: 주소
  - `meterId`: 미터기 ID

## 다국어 지원

모든 페이지는 `AppLocalizations`를 통해 다국어를 지원합니다. 주요 문자열은 다음 파일에 정의되어 있습니다:
- `lib/l10n/app_en.arb`: 영어 리소스
- `lib/l10n/app_ko.arb`: 한국어 리소스

### 주요 다국어 키
- `deviceInfo`: 장치 정보
- `meterId`: 미터기 ID
- `installDate`: 설치일자
- `initialValue`: 계량기 초기값
- `dataInterval`: 데이터 전송주기
- `status`: 상태
- `comment`: 코멘트
- `completeInstallation`: 설치 완료
- `scanWithCamera`: 카메라로 스캔
- `qrScanTitle`: QR/바코드 스캔
- `secondsBeforeCommunication`: 초 후 통신을 시작합니다
- `connectAnotherDevice`: 다른 장비 연결
- `disconnectDevice`: 장비 연결 해제

## 권한 관리

설치자 모듈은 다음 권한을 사용합니다:
- `camera`: QR 코드/바코드 스캔을 위한 카메라 접근 권한

권한 요청 및 관리는 `permission_handler` 패키지를 사용하여 구현되었습니다.

## 주의사항

1. 활성 상태로 설치 완료하려면 미터기 ID, 계량기 초기값, 가입자 정보가 필요합니다.
2. 비활성 상태(해제)로 설치 완료하는 경우 제약 조건이 없습니다.
3. 설치 확인 페이지에서는 장치와 서버 간 통신이 5분 이내에 이루어졌는지 확인합니다.
4. QR/바코드 스캔 기능은 모바일 환경에서만 정상 작동합니다.
5. 설치 확인 페이지에서 페이지를 나갈 때는 반드시 통신 폴링과 타이머를 중지해야 메모리 누수를 방지할 수 있습니다. 