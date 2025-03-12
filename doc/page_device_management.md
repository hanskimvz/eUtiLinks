# 장치 관리 모듈

## 목차
- [개요](#개요)
- [파일 구조](#파일-구조)
- [주요 기능](#주요-기능)
- [구성 파일](#구성-파일)
  - [device_management_page.dart](#device_management_pagedart)
  - [device_info_page.dart](#device_info_pagedart)
- [데이터 모델 및 서비스](#데이터-모델-및-서비스)
  - [데이터 모델](#데이터-모델)
  - [서비스](#서비스)
- [UI 컴포넌트](#ui-컴포넌트)
  - [통계 카드](#통계-카드)
  - [데이터 테이블](#데이터-테이블)
  - [페이지네이션](#페이지네이션)
- [API 연동](#api-연동)
  - [API 엔드포인트](#api-엔드포인트)
  - [API 호출 예시](#api-호출-예시)
  - [오류 처리](#오류-처리)
- [기능 구현](#기능-구현)
  - [엑셀 내보내기](#엑셀-내보내기)
  - [장치 일괄 등록](#장치-일괄-등록)
- [국제화 (i18n)](#국제화-i18n)
- [성능 최적화](#성능-최적화)
- [향후 개선 방향](#향후-개선-방향)

## 개요

장치 관리 모듈은 시스템에 등록된 모든 장치를 관리하는 기능을 제공합니다. 관리자는 이 모듈을 통해 장치 목록을 조회하고, 검색하고, 정렬하고, 새 장치를 등록하고, 장치 정보를 엑셀로 내보낼 수 있습니다. 또한 장치의 상태와 배터리 수준을 시각적으로 확인할 수 있어 효율적인 장치 관리가 가능합니다.

## 파일 구조

```
lib/features/settings/presentation/
├── pages/
│   ├── device_management_page.dart    # 장치 관리 메인 페이지
│   └── device_info_page.dart          # 장치 상세 정보 페이지
```

## 주요 기능

1. **장치 목록 조회**: 시스템에 등록된 모든 장치 목록을 조회합니다.
2. **장치 검색**: 장치 UID, 고객명, 고객번호, 미터기 ID, 주소 등으로 장치를 검색합니다.
3. **장치 정렬**: 모든 열을 기준으로 오름차순/내림차순 정렬이 가능합니다.
4. **장치 통계**: 전체 장치 수, 활성 장치 수, 비활성 장치 수, 주의가 필요한 장치 수를 시각적으로 표시합니다.
5. **장치 일괄 등록**: 여러 장치를 한 번에 등록할 수 있습니다.
6. **엑셀 내보내기**: 장치 목록을 엑셀 파일로 내보낼 수 있습니다.
7. **페이지네이션**: 대량의 장치 데이터를 효율적으로 표시하기 위한 페이지네이션을 제공합니다.

## 구성 파일

### `device_management_page.dart`

장치 관리 메인 페이지로, 장치 목록과 관리 기능을 제공합니다.

**파일 크기**: 약 30KB (800줄 이상)

**클래스 구조**:
- `DeviceManagementPage`: StatefulWidget 클래스
- `_DeviceManagementPageState`: 상태 관리 클래스

**주요 메서드**:
- `_loadDevices()`: 서버에서 장치 목록을 로드합니다.
- `_filterDevices()`: 검색어에 따라 장치 목록을 필터링합니다.
- `_sort()`: 특정 필드를 기준으로 장치 목록을 정렬합니다.
- `_getPaginatedData()`: 페이지네이션을 위해 현재 페이지의 데이터를 반환합니다.
- `_exportToExcel()`: 장치 목록을 엑셀 파일로 내보냅니다.
- `_showBulkAddDeviceDialog()`: 장치 일괄 등록 다이얼로그를 표시합니다.
- `_getStatusColor()`: 장치 상태에 따른 색상을 반환합니다.
- `_getBatteryLevelColor()`: 배터리 수준에 따른 색상을 반환합니다.
- `_getBatteryIcon()`: 배터리 수준에 따른 아이콘을 반환합니다.
- `_getFormattedAddress()`: 장치의 주소 정보를 포맷팅합니다.

**주요 기능**:
- 장치 목록 로드 및 표시
- 장치 검색 및 필터링
- 장치 정렬
- 장치 통계 표시
- 장치 일괄 등록
- 엑셀 내보내기
- 페이지네이션

**주요 컴포넌트**:
- 검색 필드
- 통계 카드
- 데이터 테이블
- 페이지네이션 컨트롤
- 일괄 등록 버튼
- 엑셀 내보내기 버튼

**의존성**:
- `DeviceService`: 장치 정보 API 호출
- `DeviceModel`: 장치 데이터 모델
- `excel`: 엑셀 파일 생성 및 조작
- `universal_html`: 웹 환경에서 파일 다운로드 처리

### `device_info_page.dart`

선택한 장치의 상세 정보를 표시하는 페이지입니다.

**주요 기능**:
- 장치 상세 정보 표시
- 장치 정보 수정
- 장치 상태 변경

## 데이터 모델 및 서비스

### 데이터 모델

#### `DeviceModel` (`lib/core/models/device_model.dart`)
장치 정보를 담는 데이터 모델입니다.

**주요 속성**:
- `deviceUid`: 장치 고유 식별자
- `customerName`: 고객명
- `customerNo`: 고객번호
- `addrProv`: 주소(도/시)
- `addrCity`: 주소(시/군/구)
- `addrDist`: 주소(동/읍/면)
- `addrDong`: 주소(동)
- `addrDetail`: 상세 주소
- `addrApt`: 아파트/건물명
- `meterId`: 미터기 ID
- `lastCount`: 마지막 검침값
- `lastAccess`: 마지막 통신 시간
- `flag`: 장치 상태 (active, inactive, warning, error 등)
- `battery`: 배터리 수준 (%)
- `releaseDate`: 출고일자
- `installerId`: 설치자 ID

### 서비스

#### `DeviceService` (`lib/core/services/device_service.dart`)
장치 관련 API 호출을 담당하는 서비스 클래스입니다.

**주요 메서드**:
- `getDevices()`: 모든 장치 목록을 조회합니다.
- `getDeviceById()`: 장치 ID로 장치 정보를 조회합니다.
- `addDevice()`: 새 장치를 등록합니다.
- `updateDevice()`: 장치 정보를 업데이트합니다.

## UI 컴포넌트

### 통계 카드

장치 관련 주요 통계를 시각적으로 표시하는 카드 컴포넌트입니다.

```dart
Widget _buildStatCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Column(
    children: [
      Icon(icon, color: color, size: 32),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );
}
```

### 데이터 테이블

장치 목록을 표시하는 데이터 테이블 컴포넌트입니다. 각 열은 정렬이 가능하며, 행을 클릭하면 해당 장치의 상세 정보 페이지로 이동합니다.

### 페이지네이션

대량의 장치 데이터를 효율적으로 표시하기 위한 페이지네이션 컴포넌트입니다.

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Row(
      children: [
        Text('${localizations.rowsPerPage}: '),
        DropdownButton<int>(
          value: _rowsPerPage,
          items: const [10, 20, 50, 100].map((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _rowsPerPage = value!;
              _currentPage = 0; // 페이지 리셋
            });
          },
        ),
      ],
    ),
    Row(
      children: [
        IconButton(
          icon: const Icon(Icons.first_page),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage = 0;
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        Text(
          '${_currentPage + 1} / ${(_filteredDevices.length / _rowsPerPage).ceil()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _currentPage <
                  (_filteredDevices.length / _rowsPerPage).ceil() - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.last_page),
          onPressed: _currentPage <
                  (_filteredDevices.length / _rowsPerPage).ceil() - 1
              ? () {
                  setState(() {
                    _currentPage = (_filteredDevices.length / _rowsPerPage).ceil() - 1;
                  });
                }
              : null,
        ),
      ],
    ),
  ],
)
```

## API 연동

장치 관리 모듈은 백엔드 서버와의 통신을 위해 RESTful API를 사용합니다. 모든 API 요청은 `ApiConstants.serverUrl`을 기본 URL로 사용합니다.

### API 엔드포인트

#### 장치 관련 API

1. **장치 목록 조회**
   - **URL**: `/api/devices`
   - **Method**: GET
   - **응답**: 장치 목록 (DeviceModel 배열)

2. **장치 상세 정보 조회**
   - **URL**: `/api/devices/{deviceUid}`
   - **Method**: GET
   - **응답**: 장치 상세 정보 (DeviceModel)

3. **장치 등록**
   - **URL**: `/api/devices`
   - **Method**: POST
   - **Body**: DeviceModel 객체
   - **응답**: 등록된 장치 정보 및 성공 여부

4. **장치 정보 업데이트**
   - **URL**: `/api/devices/{deviceUid}`
   - **Method**: PUT
   - **Body**: DeviceModel 객체
   - **응답**: 업데이트된 장치 정보 및 성공 여부

### API 호출 예시

#### 장치 목록 조회

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

#### 장치 등록

```dart
Future<void> _addDevice(DeviceModel device) async {
  try {
    await _deviceService.addDevice(device);
    await _loadDevices(); // 목록 새로고침
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장치가 성공적으로 등록되었습니다.')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('장치 등록 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

## 기능 구현

### 엑셀 내보내기

장치 목록을 엑셀 파일로 내보내는 기능입니다. 웹 환경에서만 지원됩니다.

```dart
Future<void> _exportToExcel() async {
  final localizations = AppLocalizations.of(context)!;

  // 웹 환경이 아닌 경우 메시지 표시 후 종료
  if (!kIsWeb) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이 기능은 웹 환경에서만 사용 가능합니다.'),
        backgroundColor: Colors.orange,
      ),
    );
    return;
  }

  try {
    // Excel 파일 생성
    final excel = excel_lib.Excel.createExcel();

    // 기본 시트 사용 (Sheet1)
    final defaultSheet = excel.sheets.keys.first;
    final sheet = excel[defaultSheet];

    // 헤더 추가
    sheet.appendRow([
      excel_lib.TextCellValue(localizations.deviceUid), // 단말기 UID
      excel_lib.TextCellValue(localizations.customerName), // 고객명
      excel_lib.TextCellValue(localizations.customerNo), // 고객번호
      excel_lib.TextCellValue(localizations.address), // 주소
      excel_lib.TextCellValue(localizations.meterId), // 미터기 ID
      excel_lib.TextCellValue(localizations.lastCount), // 마지막 검침
      excel_lib.TextCellValue(localizations.lastAccess), // 마지막 통신
      excel_lib.TextCellValue(localizations.status), // 상태
      excel_lib.TextCellValue(localizations.battery), // 배터리
    ]);

    // 데이터 추가
    for (var device in _filteredDevices) {
      sheet.appendRow([
        excel_lib.TextCellValue(device.deviceUid),
        excel_lib.TextCellValue(device.customerName ?? ''),
        excel_lib.TextCellValue(device.customerNo ?? ''),
        excel_lib.TextCellValue(_getFormattedAddress(device)),
        excel_lib.TextCellValue(device.meterId?.toString() ?? ''),
        excel_lib.TextCellValue(device.lastCount?.toString() ?? ''),
        excel_lib.TextCellValue(device.lastAccess ?? ''),
        excel_lib.TextCellValue(_getStatusText(device.flag)),
        excel_lib.TextCellValue(
          device.battery != null ? '${device.battery.toString()}%' : '',
        ),
      ]);
    }

    // 시트 이름 변경
    excel.rename(defaultSheet, localizations.deviceList); // 장치 목록

    // 파일 다운로드
    final fileName = '${localizations.deviceList}_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';
    final bytes = excel.encode()!;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.excelFileSaved))
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${localizations.excelFileSaveError}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 장치 일괄 등록

여러 장치를 한 번에 등록하는 기능입니다.

```dart
void _showBulkAddDeviceDialog() {
  final localizations = AppLocalizations.of(context)!;
  final deviceUidsController = TextEditingController();
  final releaseDateController = TextEditingController();
  final installerIdController = TextEditingController();
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.bulkDeviceRegistration),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.deviceUidListDescription,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deviceUidsController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: 'F68C057D\nA149490D\nB123456E',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: releaseDateController,
              decoration: InputDecoration(
                labelText: localizations.releaseDate,
                hintText: 'YYYY-MM-DD',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: installerIdController,
              decoration: InputDecoration(
                labelText: localizations.installerId,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final deviceUids = deviceUidsController.text
                  .split('\n')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();

              if (deviceUids.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.enterAtLeastOneDeviceUid),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (releaseDateController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.enterReleaseDate),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (installerIdController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.enterInstallerId),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();
              setState(() => _isLoading = true);

              for (final uid in deviceUids) {
                final newDevice = DeviceModel(
                  deviceUid: uid,
                  flag: 'active',
                  lastCount: 0,
                  battery: 100,
                  releaseDate: releaseDateController.text,
                  installerId: installerIdController.text,
                );

                await _deviceService.addDevice(newDevice);
              }

              await _loadDevices();

              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      localizations.devicesRegisteredSuccess(
                        deviceUids.length,
                      ),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              setState(() => _isLoading = false);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      '${localizations.deviceRegistrationFailed}: $e',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(localizations.register),
        ),
      ],
    ),
  );
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

## 성능 최적화

장치 관리 페이지는 다음과 같은 성능 최적화 기법을 적용하고 있습니다:

1. **페이지네이션**: 대량의 장치 데이터를 효율적으로 표시하기 위해 페이지네이션을 구현했습니다.
2. **지연 로딩**: 필요한 데이터만 로드하여 초기 로딩 시간을 단축했습니다.
3. **효율적인 상태 관리**: 필요한 경우에만 `setState()`를 호출하여 불필요한 리렌더링을 방지했습니다.
4. **메모리 관리**: 리소스를 적절히 해제하여 메모리 누수를 방지했습니다.
5. **조건부 렌더링**: 로딩 상태와 오류 상태에 따라 적절한 UI를 표시하여 사용자 경험을 향상시켰습니다.

## 향후 개선 방향

1. **실시간 업데이트**: WebSocket을 활용하여 장치 상태 변경 시 실시간으로 UI를 업데이트하는 기능 추가
2. **고급 필터링**: 다양한 조건으로 장치를 필터링할 수 있는 고급 필터링 기능 추가
3. **대시보드 통합**: 장치 관리 페이지와 대시보드를 통합하여 더 직관적인 UI 제공
4. **장치 그룹 관리**: 장치를 그룹으로 관리할 수 있는 기능 추가
5. **장치 이력 관리**: 장치의 상태 변경 이력을 조회할 수 있는 기능 추가
6. **지도 통합**: 장치 위치를 지도에서 확인할 수 있는 기능 추가
7. **배치 작업**: 여러 장치에 대한 배치 작업(상태 변경, 삭제 등) 기능 추가 