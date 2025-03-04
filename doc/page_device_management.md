# 장치 관리 페이지 (Device Management Page)

## 개요

장치 관리 페이지는 시스템에 등록된 모든 장치를 관리하는 페이지입니다. 사용자는 이 페이지에서 장치 목록을 확인하고, 검색하고, 정렬하고, 새 장치를 등록하고, 장치 정보를 엑셀로 내보낼 수 있습니다.

## 스크린샷

(스크린샷 이미지 추가 필요)

## 기능

- 장치 목록 조회
- 장치 검색 (장치 UID, 고객명, 고객번호, 미터기 ID, 주소 기준)
- 장치 정렬 (모든 열 기준)
- 장치 상세 정보 보기
- 장치 일괄 등록
- 장치 목록 엑셀 내보내기
- 장치 통계 표시 (전체, 활성, 비활성, 주의 필요)

## 구현 방법

### 파일 구조

- `lib/features/settings/presentation/pages/device_management_page.dart`: 장치 관리 페이지 UI 및 로직
- `lib/core/models/device_model.dart`: 장치 모델 클래스
- `lib/core/services/device_service.dart`: 장치 관련 API 서비스
- `lib/features/settings/presentation/pages/device_info_page.dart`: 장치 상세 정보 페이지

### 주요 클래스 및 위젯

#### DeviceManagementPage

`StatefulWidget`을 상속받는 메인 페이지 클래스입니다.

#### _DeviceManagementPageState

`DeviceManagementPage`의 상태를 관리하는 클래스로, 다음과 같은 주요 상태를 포함합니다:

- `_devices`: 모든 장치 목록
- `_filteredDevices`: 검색 결과에 따른 필터링된 장치 목록
- `_isLoading`: 로딩 상태
- `_errorMessage`: 오류 메시지
- `_sortColumnIndex`: 정렬 기준 열 인덱스
- `_sortAscending`: 오름차순/내림차순 정렬 여부

### 주요 메서드

#### _loadDevices()

서버에서 장치 목록을 가져오는 비동기 메서드입니다.

```dart
Future<void> _loadDevices() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final devices = await _deviceService.getDevices();
    
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

#### _filterDevices(String query)

검색어에 따라 장치 목록을 필터링하는 메서드입니다.

```dart
void _filterDevices(String query) {
  setState(() {
    if (query.isEmpty) {
      _filteredDevices = _devices;
    } else {
      _filteredDevices = _devices.where((device) {
        final searchFields = [
          device.deviceUid,
          device.customerName ?? '',
          device.customerNo ?? '',
          device.meterId ?? '',
          _getFormattedAddress(device),
        ].map((s) => s.toLowerCase());
        
        return searchFields.any((field) => field.contains(query.toLowerCase()));
      }).toList();
    }
  });
}
```

#### _sort<T>(Comparable<T> Function(DeviceModel device) getField, int columnIndex, bool ascending)

특정 필드를 기준으로 장치 목록을 정렬하는 메서드입니다.

```dart
void _sort<T>(Comparable<T> Function(DeviceModel device) getField, int columnIndex, bool ascending) {
  _filteredDevices.sort((a, b) {
    final aValue = getField(a);
    final bValue = getField(b);
    
    return ascending
        ? Comparable.compare(aValue, bValue)
        : Comparable.compare(bValue, aValue);
  });
  
  setState(() {
    _sortColumnIndex = columnIndex;
    _sortAscending = ascending;
  });
}
```

#### _exportToExcel()

장치 목록을 엑셀 파일로 내보내는 메서드입니다.

#### _showBulkAddDeviceDialog()

여러 장치를 일괄 등록하는 다이얼로그를 표시하는 메서드입니다.

### UI 구현

#### 고정 헤더가 있는 데이터 테이블

장치 목록을 표시하는 데이터 테이블은 헤더가 고정되고 데이터 부분만 스크롤되도록 구현되었습니다. 이를 위해 두 개의 `DataTable`을 사용합니다:

1. 헤더 테이블: 열 제목만 표시하고 데이터 행은 표시하지 않음
2. 데이터 테이블: 헤더 행은 표시하지 않고 데이터 행만 표시

```dart
Column(
  children: [
    // 헤더 부분 (고정)
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 64,
        ),
        child: DataTable(
          showCheckboxColumn: false,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          headingRowHeight: 56,
          dataRowHeight: 0,
          dividerThickness: 1,
          columnSpacing: 56.0,
          columns: [
            // 열 정의
          ],
          rows: const [],
        ),
      ),
    ),
    
    // 데이터 부분 (스크롤)
    Expanded(
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width - 64,
            ),
            child: DataTable(
              showCheckboxColumn: false,
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              headingRowHeight: 0,
              columnSpacing: 56.0,
              columns: [
                // 빈 열 정의
              ],
              rows: _filteredDevices.map((device) {
                // 행 정의
              }).toList(),
            ),
          ),
        ),
      ),
    ),
  ],
)
```

## 디자인 시트

### 색상

- 배경색: 흰색
- 카드 배경색: 흰색
- 헤더 배경색: `Colors.grey[100]`
- 활성 상태 색상: `Colors.green`
- 비활성 상태 색상: `Colors.grey`
- 배터리 레벨 색상:
  - 70% 이상: `Colors.green`
  - 30% ~ 70%: `Colors.orange`
  - 30% 미만: `Colors.red`
- 호버 상태 색상: `Colors.blue.withAlpha(0.1 * 255)`

### 텍스트 스타일

- 페이지 제목: 24px, 굵게
- 페이지 설명: 16px, 회색
- 테이블 헤더: 굵게, 검은색
- 테이블 데이터: 일반, 검은색 (87%)
- 통계 카드 값: 24px, 굵게, 색상별
- 통계 카드 제목: 14px, 회색

### 아이콘

- 새로고침: `Icons.refresh`
- 엑셀 내보내기: `Icons.file_download`
- 장치 추가: `Icons.add`
- 전체 장치: `Icons.devices`
- 활성 장치: `Icons.check_circle`
- 비활성 장치: `Icons.cancel`
- 주의 필요: `Icons.warning`

## API 요청 및 응답

### 장치 목록 조회

#### 요청

```
GET /api/devices
```

#### 응답

```json
[
  {
    "deviceUid": "B2626CAE",
    "customerName": "김홍장",
    "customerNo": "532649718",
    "addrProv": "서울",
    "addrCity": "강남구",
    "addrDist": "",
    "addrDong": "",
    "addrDetail": "",
    "addrApt": "",
    "meterId": "365478965183",
    "lastCount": 0,
    "lastAccess": "2023-05-15 14:30:22",
    "flag": true,
    "battery": 85,
    "releaseDate": "2023-01-01",
    "installerId": "admin"
  },
  {
    "deviceUid": "B6D27E91",
    "customerName": null,
    "customerNo": null,
    "addrProv": null,
    "addrCity": null,
    "addrDist": null,
    "addrDong": null,
    "addrDetail": null,
    "addrApt": null,
    "meterId": null,
    "lastCount": null,
    "lastAccess": null,
    "flag": false,
    "battery": null,
    "releaseDate": "2023-01-01",
    "installerId": "admin"
  }
]
```

### 장치 추가

#### 요청

```
POST /api/devices
Content-Type: application/json

{
  "deviceUid": "F68C057D",
  "flag": true,
  "lastCount": 0,
  "battery": 100,
  "releaseDate": "2023-06-01",
  "installerId": "admin"
}
```

#### 응답

```json
{
  "success": true,
  "message": "Device added successfully",
  "device": {
    "deviceUid": "F68C057D",
    "flag": true,
    "lastCount": 0,
    "battery": 100,
    "releaseDate": "2023-06-01",
    "installerId": "admin"
  }
}
```

## 모델 클래스

### DeviceModel

```dart
class DeviceModel {
  final String deviceUid;
  final String? customerName;
  final String? customerNo;
  final String? addrProv;
  final String? addrCity;
  final String? addrDist;
  final String? addrDong;
  final String? addrDetail;
  final String? addrApt;
  final String? meterId;
  final int? lastCount;
  final String? lastAccess;
  final bool flag;
  final int? battery;
  final String? releaseDate;
  final String? installerId;

  DeviceModel({
    required this.deviceUid,
    this.customerName,
    this.customerNo,
    this.addrProv,
    this.addrCity,
    this.addrDist,
    this.addrDong,
    this.addrDetail,
    this.addrApt,
    this.meterId,
    this.lastCount,
    this.lastAccess,
    required this.flag,
    this.battery,
    this.releaseDate,
    this.installerId,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      deviceUid: json['deviceUid'],
      customerName: json['customerName'],
      customerNo: json['customerNo'],
      addrProv: json['addrProv'],
      addrCity: json['addrCity'],
      addrDist: json['addrDist'],
      addrDong: json['addrDong'],
      addrDetail: json['addrDetail'],
      addrApt: json['addrApt'],
      meterId: json['meterId'],
      lastCount: json['lastCount'],
      lastAccess: json['lastAccess'],
      flag: json['flag'] ?? false,
      battery: json['battery'],
      releaseDate: json['releaseDate'],
      installerId: json['installerId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceUid': deviceUid,
      'customerName': customerName,
      'customerNo': customerNo,
      'addrProv': addrProv,
      'addrCity': addrCity,
      'addrDist': addrDist,
      'addrDong': addrDong,
      'addrDetail': addrDetail,
      'addrApt': addrApt,
      'meterId': meterId,
      'lastCount': lastCount,
      'lastAccess': lastAccess,
      'flag': flag,
      'battery': battery,
      'releaseDate': releaseDate,
      'installerId': installerId,
    };
  }
}
```

## 서비스 클래스

### DeviceService

```dart
class DeviceService {
  final String baseUrl;
  final http.Client _client = http.Client();

  DeviceService({required this.baseUrl});

  Future<List<DeviceModel>> getDevices() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/devices'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DeviceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load devices: $e');
    }
  }

  Future<DeviceModel> addDevice(DeviceModel device) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/api/devices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(device.toJson()),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return DeviceModel.fromJson(jsonResponse['device']);
      } else {
        throw Exception('Failed to add device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to add device: $e');
    }
  }
}
```

## 국제화 (i18n)

장치 관리 페이지는 `AppLocalizations` 클래스를 통해 다국어를 지원합니다. 주요 번역 키는 다음과 같습니다:

- `deviceManagement`: 장치 관리
- `deviceManagementDescription`: 장치 관리 페이지 설명
- `searchDevice`: 장치 검색
- `searchDeviceHint`: 장치 검색 힌트
- `bulkDeviceRegistration`: 장치 일괄 등록
- `refresh`: 새로고침
- `exportToExcel`: 엑셀로 내보내기
- `totalDevices`: 전체 장치
- `activeDevices`: 활성 장치
- `inactiveDevices`: 비활성 장치
- `needsAttention`: 주의 필요
- `deviceUid`: 장치 UID
- `customerName`: 고객명
- `customerNo`: 고객번호
- `address`: 주소
- `meterId`: 미터기 ID
- `lastCount`: 마지막 검침
- `lastAccess`: 마지막 통신
- `status`: 상태
- `battery`: 배터리
- `active`: 활성
- `inactive`: 비활성
- `excelFileSaved`: 엑셀 파일 저장 완료
- `excelFileSaveError`: 엑셀 파일 저장 오류
- `deviceUidListDescription`: 장치 UID 목록 설명
- `releaseDate`: 출고일
- `installerId`: 설치자 ID
- `cancel`: 취소
- `register`: 등록
- `enterAtLeastOneDeviceUid`: 최소 하나의 장치 UID를 입력하세요
- `enterReleaseDate`: 출고일을 입력하세요
- `enterInstallerId`: 설치자 ID를 입력하세요
- `devicesRegisteredSuccess`: 장치 등록 성공
- `deviceRegistrationFailed`: 장치 등록 실패

## 성능 최적화

- 장치 목록이 많을 경우를 대비하여 스크롤 가능한 데이터 테이블 구현
- 검색 기능을 통한 빠른 장치 찾기
- 정렬 기능을 통한 효율적인 데이터 탐색
- 로딩 상태 표시로 사용자 경험 향상
- 오류 처리 및 표시

## 향후 개선 사항

- 페이지네이션 구현으로 대량의 장치 데이터 처리 최적화
- 장치 상태 필터링 기능 추가
- 장치 정보 수정 기능 추가
- 장치 삭제 기능 추가
- 장치 상태 변경 기능 추가
- 실시간 데이터 업데이트 기능 추가 