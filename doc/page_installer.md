# Installer 모듈

## 목차
- [개요](#개요)
- [파일 구조](#파일-구조)
- [주요 기능](#주요-기능)
- [구성 파일](#구성-파일)
  - [1. installer_page.dart](#1-installer_pagedart)
  - [2. installer_device_info.dart](#2-installer_device_infodart)
  - [3. installation_confirm_page.dart](#3-installation_confirm_pagedart)
  - [4. qr_scanner_page.dart](#4-qr_scanner_pagedart)
- [데이터 모델 및 서비스](#데이터-모델-및-서비스)
  - [데이터 모델](#데이터-모델)
  - [서비스](#서비스)
- [API 연동](#api-연동)
  - [API 엔드포인트](#api-엔드포인트)
  - [API 호출 예시](#api-호출-예시)
  - [오류 처리](#오류-처리)
- [사용 흐름](#사용-흐름)
- [코드 개선사항](#코드-개선사항)
- [향후 개선 방향](#향후-개선-방향)

## 개요

Installer 모듈은 가스 계량기 설치 기사가 사용하는 모바일 애플리케이션 모듈입니다. 이 모듈은 설치 기사가 현장에서 장치를 설치하고, 설치 상태를 확인하며, QR 코드를 스캔하여 장치를 식별하는 기능을 제공합니다.

## 파일 구조

```
lib/features/installer/
├── presentation/
│   └── pages/
│       ├── installer_page.dart          # 설치 기사 메인 페이지
│       ├── installer_device_info.dart   # 장치 상세 정보 및 설치 페이지
│       ├── installation_confirm_page.dart # 설치 확인 페이지
│       └── qr_scanner_page.dart         # QR 코드 스캐너 페이지
```

## 주요 기능

1. **장치 목록 조회**: 설치 기사에게 할당된 장치 목록을 조회합니다.
2. **장치 검색**: 장치 ID 또는 QR 코드를 통해 특정 장치를 검색합니다.
3. **장치 상세 정보 조회**: 선택한 장치의 상세 정보를 확인합니다.
4. **장치 설치**: 장치를 설치하고 초기 설정을 진행합니다.
5. **설치 확인**: 설치 후 장치와의 통신 상태를 확인합니다.

## 구성 파일

### 1. `installer_page.dart`

메인 설치 기사 페이지로, 설치 기사에게 할당된 장치 목록을 표시합니다.

**파일 크기**: 약 19KB (521줄)

**클래스 구조**:
- `InstallerPage`: StatefulWidget 클래스
- `_InstallerPageState`: 상태 관리 클래스

**주요 메서드**:
- `_checkLoginStatus()`: 로그인 상태 확인 및 자동 로그인 처리
- `_loadDevices()`: 설치 기사에게 할당된 장치 목록 로드
- `_filterDevices()`: 검색어에 따라 장치 목록 필터링
- `_navigateToDeviceInfo()`: 선택한 장치의 상세 정보 페이지로 이동
- `_sort()`: 장치 목록 정렬
- `_openCamera()`: QR 코드 스캔 카메라 열기

**주요 기능**:
- 자동 로그인 처리
- 장치 목록 로드 및 표시
- 장치 검색 (텍스트 및 QR 코드 스캔)
- 장치 정렬 및 필터링
- 장치 상세 정보 페이지로 이동

**주요 컴포넌트**:
- 검색 필드
- QR 코드 스캔 버튼
- 장치 목록 테이블 (장치 ID, 출시일, 미터기 ID, 상태 표시)

**의존성**:
- `DeviceService`: 장치 정보 API 호출
- `AuthService`: 인증 관련 기능
- `ScannerUtils`: QR 코드 스캔 유틸리티

### 2. `installer_device_info.dart`

선택한 장치의 상세 정보를 표시하고 설치 작업을 진행하는 페이지입니다.

**파일 크기**: 약 43KB (1033줄)

**클래스 구조**:
- `InstallerDeviceInfoPage`: StatefulWidget 클래스
- `_InstallerDeviceInfoPageState`: 상태 관리 클래스

**주요 메서드**:
- `_loadDeviceInfo()`: 장치 상세 정보 로드
- `_fetchCustomerInfo()`: 미터기 ID로 가입자 정보 조회
- `_onMeterIdChanged()`: 미터기 ID 변경 감지 및 처리
- `_showDatePicker()`: 설치 날짜 선택 다이얼로그 표시
- `_completeInstallation()`: 설치 완료 처리
- `_openCamera()`: QR 코드 스캔 카메라 열기

**주요 기능**:
- 장치 상세 정보 표시
- 미터기 ID 입력 및 가입자 정보 자동 조회
- 초기 계량값 설정
- 설치 날짜 및 시간 설정
- 통신 간격 설정
- 설치 확인 페이지로 이동

**주요 컴포넌트**:
- 장치 정보 카드
- 미터기 ID 입력 필드
- 가입자 정보 표시 영역
- 초기 계량값 입력 필드
- 설치 날짜 선택기
- 통신 간격 선택기
- 설치 확인 버튼

**의존성**:
- `DeviceService`: 장치 정보 API 호출
- `SubscriberService`: 가입자 정보 API 호출
- `ScannerUtils`: QR 코드 스캔 유틸리티

### 3. `installation_confirm_page.dart`

장치 설치 후 통신 상태를 확인하는 페이지입니다.

**파일 크기**: 약 15KB (439줄)

**클래스 구조**:
- `InstallationConfirmPage`: StatefulWidget 클래스
- `_InstallationConfirmPageState`: 상태 관리 클래스

**주요 메서드**:
- `_startCountdown()`: 카운트다운 타이머 시작
- `_startPolling()`: 통신 상태 확인 폴링 시작
- `_stopPolling()`: 폴링 중지
- `_pollDeviceStatus()`: 장치 통신 상태 확인
- `_disconnectDevice()`: 장치 연결 해제

**주요 기능**:
- 설치 후 장치와의 통신 상태 확인
- 통신 상태 실시간 폴링
- 장치 연결 해제 기능

**주요 컴포넌트**:
- 설치 안내 카드
- 통신 상태 표시
- 카운트다운 타이머
- 완료 및 취소 버튼

**의존성**:
- `DeviceService`: 장치 정보 및 통신 상태 API 호출

### 4. `qr_scanner_page.dart`

QR 코드를 스캔하여 장치를 식별하는 페이지입니다.

**파일 크기**: 약 3.8KB (132줄)

**클래스 구조**:
- `QRScannerPage`: StatefulWidget 클래스
- `_QRScannerPageState`: 상태 관리 클래스

**주요 메서드**:
- `_handleScan()`: 스캔 결과 처리

**주요 기능**:
- 카메라를 통한 QR 코드 스캔
- 플래시 토글
- 전/후면 카메라 전환
- 스캔 결과 처리

**주요 컴포넌트**:
- 카메라 뷰
- 플래시 토글 버튼
- 카메라 전환 버튼
- 스캔 안내 텍스트

**의존성**:
- `mobile_scanner`: QR 코드 스캔 라이브러리

## 데이터 모델 및 서비스

### 데이터 모델

#### `DeviceModel` (`lib/core/models/device_model.dart`)
장치 정보를 담는 데이터 모델입니다.

**주요 속성**:
- `deviceUid`: 장치 고유 식별자
- `meterId`: 미터기 ID
- `releaseDate`: 출고일자
- `installDate`: 설치일자
- `flag`: 장치 상태 (active, inactive, warning, error 등)
- `lastCount`: 마지막 검침값
- `lastAccess`: 마지막 통신 시간
- `refInterval`: 데이터 전송주기 (분 단위)
- `installerId`: 설치자 ID
- `customerName`: 고객 이름
- `customerNo`: 고객 번호

#### `SubscriberModel` (`lib/core/models/subscriber_model.dart`)
가입자 정보를 담는 데이터 모델입니다.

**주요 속성**:
- `customerName`: 고객 이름
- `customerNo`: 고객 번호
- `subscriberNo`: 가입자 번호
- `addrProv`: 주소(도/시)
- `addrCity`: 주소(시/군/구)
- `addrDist`: 주소(동/읍/면)
- `addrDetail`: 상세 주소
- `addrApt`: 아파트/건물명
- `meterId`: 미터기 ID

### 서비스

#### `DeviceService` (`lib/core/services/device_service.dart`)
장치 관련 API 호출을 담당하는 서비스 클래스입니다.

**주요 메서드**:
- `getDevicesWithFilter()`: 필터 조건에 맞는 장치 목록 조회
- `getDeviceById()`: 장치 ID로 장치 정보 조회
- `bindDeviceInstallation()`: 장치 설치 정보 업데이트
- `updateDevice()`: 장치 정보 업데이트

#### `SubscriberService` (`lib/core/services/subscriber_service.dart`)
가입자 정보 관련 API 호출을 담당하는 서비스 클래스입니다.

**주요 메서드**:
- `getSubscriberByMeterId()`: 미터기 ID로 가입자 정보 조회

#### `ScannerUtils` (`lib/core/utils/scanner_utils.dart`)
QR 코드 스캔 관련 유틸리티 클래스입니다.

**주요 메서드**:
- `scanQRCode()`: QR 코드 스캔 페이지 열기 및 결과 반환

## API 연동

Installer 모듈은 백엔드 서버와의 통신을 위해 RESTful API를 사용합니다. 모든 API 요청은 `ApiConstants.serverUrl`을 기본 URL로 사용합니다.

### API 엔드포인트

#### 장치 관련 API

1. **장치 목록 조회**
   - **URL**: `/api/devices`
   - **Method**: GET
   - **Query Parameters**:
     - `fields`: 조회할 필드 목록 (쉼표로 구분)
     - `filter`: JSON 형식의 필터 조건
   - **응답**: 장치 목록 (DeviceModel 배열)

2. **장치 상세 정보 조회**
   - **URL**: `/api/devices/{deviceUid}`
   - **Method**: GET
   - **응답**: 장치 상세 정보 (DeviceModel)

3. **장치 설치 정보 업데이트**
   - **URL**: `/api/devices/bind`
   - **Method**: POST
   - **Body**:
     ```json
     {
       "action": "bind",
       "data": {
         "device_uid": "장치 ID",
         "meter_id": "미터기 ID",
         "install_date": "설치일자",
         "initial_value": "초기값",
         "ref_interval": "통신 간격(분)",
         "flag": "상태",
         "comment": "코멘트"
       }
     }
     ```
   - **응답**: 성공 여부 및 메시지

4. **장치 연결 해제**
   - **URL**: `/api/devices/bind`
   - **Method**: POST
   - **Body**:
     ```json
     {
       "action": "unbind",
       "data": {
         "device_uid": "장치 ID",
         "meter_id": "미터기 ID",
         "customer_name": "고객명",
         "customer_no": "고객번호"
       }
     }
     ```
   - **응답**: 성공 여부 및 메시지

#### 가입자 관련 API

1. **미터기 ID로 가입자 정보 조회**
   - **URL**: `/api/subscribers/meter/{meterId}`
   - **Method**: GET
   - **응답**: 가입자 정보 (SubscriberModel)

### API 호출 예시

#### 설치 기사에게 할당된 장치 목록 조회

```dart
Future<void> _loadDevices() async {
  try {
    // 로그인한 사용자 정보 가져오기
    final currentUser = await AuthService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('로그인 정보를 찾을 수 없습니다.');
    }

    final loginId = currentUser['id'];

    // installer_id 필터를 적용하여 장치 목록 가져오기
    final devices = await _deviceService.getDevicesWithFilter(
      fields: [
        'device_uid',
        'meter_id',
        'customer_name',
        'customer_no',
        'flag',
        'release_date',
      ],
      filter: {'installer_id': loginId},
    );

    setState(() {
      _devices = devices;
      _filteredDevices = devices;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
  }
}
```

#### 장치 설치 정보 업데이트

```dart
Future<void> _completeInstallation() async {
  try {
    // 설치 정보 준비
    final Map<String, dynamic> requestData = {
      'action': 'bind',
      'data': {
        'device_uid': widget.deviceUid,
        'meter_id': _meterIdController.text,
        'install_date': DateFormat('yyyy-MM-dd').format(_installDate!),
        'initial_value': _initialValueController.text,
        'ref_interval': _selectedInterval.toString(),
        'flag': _isActive ? 'active' : 'inactive',
        'comment': _commentController.text,
      },
    };

    // API 호출
    await _deviceService.bindDeviceInstallation(requestData);

    // 설치 확인 페이지로 이동
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InstallationConfirmPage(
            deviceUid: widget.deviceUid,
          ),
        ),
      );
    }
  } catch (e) {
    // 오류 처리
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('설치 완료 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

#### 미터기 ID로 가입자 정보 조회

```dart
Future<void> _fetchCustomerInfo(String meterId) async {
  if (meterId.isEmpty) {
    setState(() {
      _customerName = null;
      _customerNo = null;
      _subscriberNo = null;
      _address = null;
    });
    return;
  }

  setState(() {
    _isLoadingCustomer = true;
  });

  try {
    // 가입자 정보 조회 API 호출
    final subscriber = await _subscriberService.getSubscriberByMeterId(meterId);

    if (!mounted) return;

    setState(() {
      if (subscriber.customerName != null ||
          subscriber.customerNo != null ||
          subscriber.subscriberNo != null) {
        _customerName = subscriber.customerName;
        _customerNo = subscriber.customerNo;
        _subscriberNo = subscriber.subscriberNo;

        // 주소 조합
        final addressParts = [
          subscriber.addrProv,
          subscriber.addrCity,
          subscriber.addrDist,
          subscriber.addrDetail,
          subscriber.addrApt,
        ].where((part) => part != null && part.isNotEmpty).toList();

        _address = addressParts.isNotEmpty ? addressParts.join(' ') : null;
      } else {
        _customerName = null;
        _customerNo = null;
        _subscriberNo = null;
        _address = null;
      }
      _isLoadingCustomer = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _customerName = null;
      _customerNo = null;
      _subscriberNo = null;
      _address = null;
      _isLoadingCustomer = false;
    });
  }
}
```

### 오류 처리

API 호출 시 발생할 수 있는 오류는 다음과 같이 처리합니다:

1. **네트워크 오류**: 네트워크 연결 문제로 인한 오류
2. **서버 오류**: 서버 내부 오류 (500 에러)
3. **인증 오류**: 인증 실패 또는 권한 부족 (401, 403 에러)
4. **요청 오류**: 잘못된 요청 형식 (400 에러)
5. **리소스 없음**: 요청한 리소스가 없음 (404 에러)

모든 API 호출은 try-catch 블록으로 감싸서 오류를 처리하고, 사용자에게 적절한 오류 메시지를 표시합니다.

## 사용 흐름

1. 설치 기사가 `InstallerPage`에서 장치 목록을 확인합니다.
2. 설치할 장치를 검색하거나 목록에서 선택합니다.
3. `InstallerDeviceInfoPage`에서 장치 상세 정보를 확인하고 설치 정보를 입력합니다.
4. 설치 정보 입력 후 설치 확인 버튼을 클릭합니다.
5. `InstallationConfirmPage`에서 장치와의 통신 상태를 확인합니다.
6. 통신이 정상적으로 이루어지면 설치 완료 처리를 합니다.

## 코드 개선사항

1. **로그아웃 기능 중앙화**: 다른 페이지들과 마찬가지로 `InstallerPage`에서도 중복된 `_logout()` 메서드를 제거하고 `AuthService.showLogoutDialog(context)`를 사용하도록 변경했습니다.

2. **디바운스 처리**: `InstallerDeviceInfoPage`에서 미터기 ID 입력 시 디바운스 처리를 통해 불필요한 API 호출을 줄였습니다.

3. **스낵바 중복 방지**: 스낵바 표시 시 이전 스낵바가 있으면 닫고 새로운 스낵바를 표시하도록 처리했습니다.

4. **타이머 관리**: 페이지 dispose 시 모든 타이머를 취소하여 메모리 누수를 방지했습니다.

## 향후 개선 방향

1. **오프라인 지원**: 네트워크 연결이 불안정한 환경에서도 작업할 수 있도록 오프라인 모드 지원
2. **설치 이력 관리**: 설치 기사별 설치 이력 및 통계 제공
3. **사진 첨부 기능**: 설치 현장 사진을 첨부할 수 있는 기능 추가
4. **지도 통합**: 설치 위치를 지도에서 확인할 수 있는 기능 추가
5. **푸시 알림**: 새로운 설치 작업 할당 시 푸시 알림 제공 