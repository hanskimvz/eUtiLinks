# Installer 모듈 문서

## 개요
Installer 모듈은 가스 미터기 설치자가 사용하는 기능을 제공합니다. 이 모듈은 장치 목록 조회, 장치 정보 확인 및 수정, QR 코드/바코드 스캔 등의 기능을 포함합니다.

## 페이지 구조

### 1. InstallerPage
- **파일 위치**: `lib/features/installer/presentation/pages/installer_page.dart`
- **주요 기능**:
  - 설치자에게 할당된 장치 목록 조회
  - 장치 검색 및 필터링
  - QR 코드/바코드 스캔을 통한 장치 검색
  - 장치 상세 정보 페이지로 이동
- **주요 위젯**:
  - 검색 필드와 카메라 버튼
  - 장치 목록 테이블 (장치 UID, 출고일자, 미터기 ID, 상태 표시)
  - 정렬 기능이 있는 테이블 헤더

### 2. InstallerDeviceInfoPage
- **파일 위치**: `lib/features/installer/presentation/pages/installer_device_info.dart`
- **주요 기능**:
  - 장치 상세 정보 표시
  - 미터기 ID 입력 및 QR 코드 스캔
  - 설치일자 선택
  - 계량기 초기값 입력
  - 데이터 전송주기 설정
  - 장치 상태 설정 (활성/비활성)
  - 설치 관련 코멘트 입력
  - 설치 완료 처리
- **주요 위젯**:
  - 장치 정보 카드
  - 날짜 선택기
  - 드롭다운 메뉴 (데이터 전송주기)
  - 텍스트 입력 필드
  - 상태 토글 스위치

### 3. QRScannerPage
- **파일 위치**: `lib/features/installer/presentation/pages/qr_scanner_page.dart`
- **주요 기능**:
  - QR 코드 및 바코드 스캔
  - 플래시 켜기/끄기
  - 카메라 전환 (전면/후면)
- **주요 위젯**:
  - 모바일 스캐너
  - 플래시 및 카메라 전환 버튼
  - 스캔 안내 텍스트

## 유틸리티 클래스

### ScannerUtils
- **파일 위치**: `lib/core/utils/scanner_utils.dart`
- **주요 기능**:
  - QR 코드/바코드 스캔 기능 제공
  - 카메라 권한 요청 및 관리
  - 스캔 결과 처리
- **주요 메서드**:
  - `scanQRCode`: QR 코드/바코드 스캔 실행 및 결과 반환

## API 연동

### DeviceService
- **파일 위치**: `lib/core/services/device_service.dart`
- **주요 기능**:
  - 장치 목록 조회
  - 장치 상세 정보 조회
  - 장치 정보 업데이트
- **주요 API 엔드포인트**:
  - `GET /devices`: 장치 목록 조회
  - `GET /devices/{deviceUid}`: 장치 상세 정보 조회
  - `PUT /devices/{deviceUid}`: 장치 정보 업데이트
  - `POST /devices/installation`: 장치 설치 정보 등록

### API 요청 예시

#### 1. 장치 목록 조회
```dart
// 설치자 ID로 필터링된 장치 목록 조회
final devices = await _deviceService.getDevicesWithFilter(
  filter: {'installer_id': loginId},
);
```

#### 2. 장치 상세 정보 조회
```dart
// 장치 UID로 장치 정보 조회
final devices = await _deviceService.getDevicesWithFilter(
  filter: {'device_uid': deviceUid},
);
```

#### 3. 장치 설치 정보 업데이트
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

## 데이터 모델

### DeviceModel
- **파일 위치**: `lib/core/models/device_model.dart`
- **주요 속성**:
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

## 다국어 지원
Installer 모듈은 다국어를 지원하며, 다음 파일에서 관련 문자열을 정의합니다:
- `lib/l10n/app_en.arb`: 영어 문자열
- `lib/l10n/app_ko.arb`: 한국어 문자열

주요 다국어 키:
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

## 권한 관리
Installer 모듈은 다음 권한을 사용합니다:
- `camera`: QR 코드/바코드 스캔을 위한 카메라 접근 권한

권한 요청 및 관리는 `permission_handler` 패키지를 사용하여 구현되었습니다.

## 사용 시나리오

### 1. 장치 목록 조회 및 검색
1. 설치자가 InstallerPage에 접속
2. 시스템은 설치자에게 할당된 장치 목록을 표시
3. 설치자는 검색 필드를 사용하여 장치를 검색하거나 카메라 버튼을 눌러 QR 코드/바코드 스캔

### 2. 장치 설치 정보 입력
1. 설치자가 장치 목록에서 장치를 선택하여 InstallerDeviceInfoPage로 이동
2. 미터기 ID 입력 (직접 입력 또는 QR 코드 스캔)
3. 설치일자 선택
4. 계량기 초기값 입력
5. 데이터 전송주기 설정
6. 장치 상태 설정
7. 설치 관련 코멘트 입력
8. '설치 완료' 버튼을 눌러 설치 정보 저장

### 3. QR 코드/바코드 스캔
1. 설치자가 카메라 버튼을 클릭
2. 시스템이 카메라 권한 요청
3. QRScannerPage가 열리고 카메라가 활성화됨
4. 설치자가 QR 코드/바코드를 스캔
5. 스캔 결과가 해당 입력 필드에 자동으로 입력됨 