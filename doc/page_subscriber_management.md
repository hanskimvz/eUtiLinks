# 가입자 관리 모듈

## 목차
- [개요](#개요)
- [파일 구조](#파일-구조)
- [주요 기능](#주요-기능)
- [구성 파일](#구성-파일)
  - [subscriber_management_page.dart](#subscriber_management_pagedart)
  - [subscriber_info_page.dart](#subscriber_info_pagedart)
- [데이터 모델 및 서비스](#데이터-모델-및-서비스)
  - [데이터 모델](#데이터-모델)
  - [서비스](#서비스)
- [UI 컴포넌트](#ui-컴포넌트)
  - [데이터 테이블](#데이터-테이블)
  - [페이지네이션](#페이지네이션)
- [API 연동](#api-연동)
  - [API 엔드포인트](#api-엔드포인트)
  - [API 호출 예시](#api-호출-예시)
  - [오류 처리](#오류-처리)
- [기능 구현](#기능-구현)
  - [엑셀 내보내기](#엑셀-내보내기)
  - [가입자 추가](#가입자-추가)
- [국제화 (i18n)](#국제화-i18n)
- [성능 최적화](#성능-최적화)
- [향후 개선 방향](#향후-개선-방향)

## 개요

가입자 관리 모듈은 시스템에 등록된 모든 가입자를 관리하는 기능을 제공합니다. 관리자는 이 모듈을 통해 가입자 목록을 조회하고, 검색하고, 정렬하고, 새 가입자를 등록하고, 가입자 정보를 엑셀로 내보낼 수 있습니다. 또한 가입자의 상태와 연결된 장치 정보를 확인할 수 있어 효율적인 가입자 관리가 가능합니다.

## 파일 구조

```
lib/features/settings/presentation/
├── pages/
│   ├── subscriber_management_page.dart    # 가입자 관리 메인 페이지
│   └── subscriber_info_page.dart          # 가입자 상세 정보 페이지
```

## 주요 기능

1. **가입자 목록 조회**: 시스템에 등록된 모든 가입자 목록을 조회합니다.
2. **가입자 검색**: 고객명, 고객번호, 가입자번호, 미터기 ID, 주소 등으로 가입자를 검색합니다.
3. **가입자 정렬**: 모든 열을 기준으로 오름차순/내림차순 정렬이 가능합니다.
4. **가입자 추가**: 새로운 가입자를 시스템에 등록할 수 있습니다.
5. **엑셀 내보내기**: 가입자 목록을 엑셀 파일로 내보낼 수 있습니다.
6. **페이지네이션**: 대량의 가입자 데이터를 효율적으로 표시하기 위한 페이지네이션을 제공합니다.
7. **가입자 상세 정보 조회**: 가입자의 상세 정보를 조회하고 수정할 수 있습니다.

## 구성 파일

### `subscriber_management_page.dart`

가입자 관리 메인 페이지로, 가입자 목록과 관리 기능을 제공합니다.

**파일 크기**: 약 25KB (879줄)

**클래스 구조**:
- `SubscriberManagementPage`: StatefulWidget 클래스
- `_SubscriberManagementPageState`: 상태 관리 클래스

**주요 메서드**:
- `_loadSubscribers()`: 서버에서 가입자 목록을 로드합니다.
- `_filterSubscribers()`: 검색어에 따라 가입자 목록을 필터링합니다.
- `_sort()`: 특정 필드를 기준으로 가입자 목록을 정렬합니다.
- `_exportToExcel()`: 가입자 목록을 엑셀 파일로 내보냅니다.
- `_showAddSubscriberDialog()`: 가입자 추가 다이얼로그를 표시합니다.
- `_getFormattedAddress()`: 가입자의 주소 정보를 포맷팅합니다.
- `_getFormattedBindDate()`: 가입자의 바인딩 날짜를 포맷팅합니다.

**주요 기능**:
- 가입자 목록 로드 및 표시
- 가입자 검색 및 필터링
- 가입자 정렬
- 가입자 추가
- 엑셀 내보내기
- 페이지네이션

**주요 컴포넌트**:
- 검색 필드
- 데이터 테이블
- 페이지네이션 컨트롤
- 가입자 추가 버튼
- 엑셀 내보내기 버튼

**의존성**:
- `SubscriberService`: 가입자 정보 API 호출
- `SubscriberModel`: 가입자 데이터 모델
- `excel`: 엑셀 파일 생성 및 조작
- `universal_html`: 웹 환경에서 파일 다운로드 처리

### `subscriber_info_page.dart`

선택한 가입자의 상세 정보를 표시하는 페이지입니다.

**주요 기능**:
- 가입자 상세 정보 표시
- 가입자 정보 수정
- 가입자 상태 변경
- 연결된 장치 정보 표시

## 데이터 모델 및 서비스

### 데이터 모델

#### `SubscriberModel` (`lib/core/models/subscriber_model.dart`)
가입자 정보를 담는 데이터 모델입니다.

**주요 속성**:
- `subscriberId`: 가입자 고유 식별자
- `customerName`: 고객명
- `customerNo`: 고객번호
- `subscriberNo`: 가입자번호
- `meterId`: 미터기 ID
- `addrProv`: 주소(도/시)
- `addrCity`: 주소(시/군/구)
- `addrDist`: 주소(동/읍/면)
- `addrDetail`: 상세 주소
- `addrApt`: 아파트/건물명
- `isActive`: 활성 상태
- `phoneNumber`: 전화번호
- `email`: 이메일
- `registrationDate`: 등록일
- `contractType`: 계약 유형
- `deviceCount`: 연결된 장치 수
- `shareHouse`: 공동주택 여부
- `category`: 카테고리
- `subscriberClass`: 가입자 분류
- `inOutdoor`: 실내/실외 구분
- `bindDeviceId`: 연결된 장치 ID
- `bindDate`: 장치 연결 날짜

### 서비스

#### `SubscriberService` (`lib/core/services/subscriber_service.dart`)
가입자 관련 API 호출을 담당하는 서비스 클래스입니다.

**주요 메서드**:
- `getSubscribers()`: 모든 가입자 목록을 조회합니다.
- `getSubscriberByMeterId()`: 미터기 ID로 가입자 정보를 조회합니다.
- `addSubscriber()`: 새 가입자를 등록합니다.
- `updateSubscriber()`: 가입자 정보를 업데이트합니다.
- `deleteSubscriber()`: 가입자를 삭제합니다.
- `getSubscribersWithFilter()`: 필터 조건에 맞는 가입자 목록을 조회합니다.

## UI 컴포넌트

### 데이터 테이블

가입자 목록을 표시하는 데이터 테이블 컴포넌트입니다. 각 열은 정렬이 가능하며, 행을 클릭하면 해당 가입자의 상세 정보 페이지로 이동합니다.

```dart
DataTable(
  sortColumnIndex: _sortColumnIndex,
  sortAscending: _sortAscending,
  headingRowHeight: 36,
  dataRowMinHeight: 36,
  dataRowMaxHeight: 36,
  horizontalMargin: 20,
  columnSpacing: 30,
  showCheckboxColumn: false,
  columns: [
    DataColumn(
      label: Text(localizations.customerName),
      onSort: (columnIndex, ascending) {
        _sort<String>(
          (subscriber) => subscriber.customerName ?? '',
          columnIndex,
          ascending,
        );
      },
    ),
    DataColumn(
      label: Text(localizations.customerNo),
      onSort: (columnIndex, ascending) {
        _sort<String>(
          (subscriber) => subscriber.customerNo ?? '',
          columnIndex,
          ascending,
        );
      },
    ),
    // 추가 열 정의...
  ],
  rows: _getPaginatedData().map((subscriber) {
    final address = _getFormattedAddress(subscriber);
    
    return DataRow(
      onSelectChanged: (_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriberInfoPage(
              meterId: subscriber.meterId ?? '',
            ),
          ),
        );
      },
      cells: [
        DataCell(
          Text(
            subscriber.customerName ?? '-',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(
          Text(
            subscriber.customerNo ?? '-',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // 추가 셀 정의...
      ],
    );
  }).toList(),
)
```

### 페이지네이션

대량의 가입자 데이터를 효율적으로 표시하기 위한 페이지네이션 컴포넌트입니다.

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
        // 추가 페이지네이션 컨트롤...
      ],
    ),
  ],
)
```

## API 연동

가입자 관리 모듈은 백엔드 서버와의 통신을 위해 RESTful API를 사용합니다. 모든 API 요청은 `ApiConstants.serverUrl`을 기본 URL로 사용합니다.

### API 엔드포인트

#### 가입자 관련 API

1. **가입자 목록 조회**
   - **URL**: `/api/subscriber`
   - **Method**: POST
   - **Body**:
     ```json
     {
       "action": "list",
       "fields": [],
       "format": "json",
       ...AuthService.authData
     }
     ```
   - **응답**: 가입자 목록 (SubscriberModel 배열)

2. **가입자 상세 정보 조회**
   - **URL**: `/api/subscriber`
   - **Method**: POST
   - **Body**:
     ```json
     {
       "action": "view",
       "meter_id": "미터기 ID",
       "format": "json",
       ...AuthService.authData
     }
     ```
   - **응답**: 가입자 상세 정보 (SubscriberModel)

3. **가입자 등록**
   - **URL**: `/api/subscriber`
   - **Method**: POST
   - **Body**: 가입자 데이터와 인증 정보
   - **응답**: 등록 성공 여부

4. **가입자 정보 업데이트**
   - **URL**: `/api/subscriber`
   - **Method**: PUT
   - **Body**: 가입자 데이터와 인증 정보
   - **응답**: 업데이트 성공 여부

5. **가입자 삭제**
   - **URL**: `/api/subscriber`
   - **Method**: DELETE
   - **응답**: 삭제 성공 여부

### API 호출 예시

#### 가입자 목록 조회

```dart
Future<void> _loadSubscribers() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final subscribers = await _subscriberService.getSubscribers();

    setState(() {
      _subscribers = subscribers;
      _filteredSubscribers = subscribers;
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

#### 미터기 ID로 가입자 조회

```dart
Future<SubscriberModel> getSubscriberByMeterId(String meterId) async {
  try {
    // 인증 데이터가 비어있으면 초기화
    if (AuthService.authData.isEmpty) {
      await AuthService.initAuthData();
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/subscriber'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'action': 'view',
        'meter_id': meterId,
        'format': 'json',
        ...AuthService.authData,
      }),
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      return SubscriberModel.fromJson(data['data']);
    } else {
      throw Exception('Failed to load subscriber: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching subscriber: $e');
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

가입자 목록을 엑셀 파일로 내보내는 기능입니다. 웹 환경에서만 지원됩니다.

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
    final defaultSheet = excel.sheets.keys.first;
    final sheet = excel[defaultSheet];

    // 헤더 추가
    sheet.appendRow([
      excel_lib.TextCellValue(localizations.customerName), // 고객명
      excel_lib.TextCellValue(localizations.customerNo), // 고객번호
      excel_lib.TextCellValue(localizations.address), // 주소
      excel_lib.TextCellValue(localizations.shareHouse), // 공동주택
      excel_lib.TextCellValue(localizations.category), // 카테고리
      excel_lib.TextCellValue(localizations.subscriberNo), // 가입자번호
      excel_lib.TextCellValue(localizations.meterId), // 미터기 ID
      excel_lib.TextCellValue(localizations.subscriberClass), // 가입자 분류
      excel_lib.TextCellValue(localizations.inOutdoor), // 실내/실외
      excel_lib.TextCellValue(localizations.bindDeviceId), // 단말기 ID
      excel_lib.TextCellValue(localizations.bindDate), // 가입일
    ]);

    // 데이터 추가
    for (var subscriber in _filteredSubscribers) {
      sheet.appendRow([
        excel_lib.TextCellValue(subscriber.customerName ?? ''),
        excel_lib.TextCellValue(subscriber.customerNo ?? ''),
        excel_lib.TextCellValue(_getFormattedAddress(subscriber)),
        excel_lib.TextCellValue(subscriber.shareHouse ?? ''),
        excel_lib.TextCellValue(subscriber.category ?? ''),
        excel_lib.TextCellValue(subscriber.subscriberNo ?? ''),
        excel_lib.TextCellValue(subscriber.meterId ?? ''),
        excel_lib.TextCellValue(subscriber.subscriberClass ?? ''),
        excel_lib.TextCellValue(subscriber.inOutdoor ?? ''),
        excel_lib.TextCellValue(subscriber.bindDeviceId ?? ''),
        excel_lib.TextCellValue(_getFormattedBindDate(subscriber.bindDate)),
      ]);
    }

    // 파일 다운로드
    final fileName = '${localizations.subscriberList}_${DateTime.now().toString().split('.')[0].replaceAll(':', '-')}.xlsx';
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

### 가입자 추가

새로운 가입자를 등록하는 기능입니다.

```dart
void _showAddSubscriberDialog() {
  final localizations = AppLocalizations.of(context)!;
  final customerNameController = TextEditingController();
  final customerNoController = TextEditingController();
  final subscriberNoController = TextEditingController();
  final meterIdController = TextEditingController();
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.addSubscriber),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: customerNameController,
              decoration: InputDecoration(
                labelText: localizations.customerName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: customerNoController,
              decoration: InputDecoration(
                labelText: localizations.customerNo,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subscriberNoController,
              decoration: InputDecoration(
                labelText: localizations.subscriberNo,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: meterIdController,
              decoration: InputDecoration(
                labelText: localizations.meterId,
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
              if (customerNameController.text.isEmpty) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.enterCustomerName),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();
              setState(() => _isLoading = true);

              final subscriberData = {
                'action': 'add',
                'customer_name': customerNameController.text,
                'customer_no': customerNoController.text,
                'subscriber_no': subscriberNoController.text,
                'meter_id': meterIdController.text,
                'is_active': true,
              };

              await _subscriberService.addSubscriber(subscriberData);
              await _loadSubscribers();

              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(localizations.subscriberAddedSuccess),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              setState(() => _isLoading = false);
              if (mounted) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('${localizations.subscriberAddFailed}: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(localizations.add),
        ),
      ],
    ),
  );
}
```

## 국제화 (i18n)

가입자 관리 페이지는 `AppLocalizations` 클래스를 통해 다국어를 지원합니다. 주요 번역 키는 다음과 같습니다:

- `subscriberManagement`: 가입자 관리
- `subscriberManagementDescription`: 가입자 관리 페이지 설명
- `searchSubscriber`: 가입자 검색
- `searchSubscriberHint`: 가입자 검색 힌트
- `addSubscriber`: 가입자 추가
- `refresh`: 새로고침
- `exportSubscribersToExcel`: 엑셀로 내보내기
- `customerName`: 고객명
- `customerNo`: 고객번호
- `address`: 주소
- `shareHouse`: 공동주택
- `category`: 카테고리
- `subscriberNo`: 가입자번호
- `meterId`: 미터기 ID
- `subscriberClass`: 가입자 분류
- `inOutdoor`: 실내/실외
- `bindDeviceId`: 단말기 ID
- `bindDate`: 가입일

## 성능 최적화

가입자 관리 페이지는 다음과 같은 성능 최적화 기법을 적용하고 있습니다:

1. **페이지네이션**: 대량의 가입자 데이터를 효율적으로 표시하기 위해 페이지네이션을 구현했습니다.
2. **지연 로딩**: 필요한 데이터만 로드하여 초기 로딩 시간을 단축했습니다.
3. **효율적인 상태 관리**: 필요한 경우에만 `setState()`를 호출하여 불필요한 리렌더링을 방지했습니다.
4. **메모리 관리**: 리소스를 적절히 해제하여 메모리 누수를 방지했습니다.
5. **조건부 렌더링**: 로딩 상태와 오류 상태에 따라 적절한 UI를 표시하여 사용자 경험을 향상시켰습니다.

## 향후 개선 방향

1. **실시간 업데이트**: WebSocket을 활용하여 가입자 상태 변경 시 실시간으로 UI를 업데이트하는 기능 추가
2. **고급 필터링**: 다양한 조건으로 가입자를 필터링할 수 있는 고급 필터링 기능 추가
3. **대시보드 통합**: 가입자 관리 페이지와 대시보드를 통합하여 더 직관적인 UI 제공
4. **가입자 그룹 관리**: 가입자를 그룹으로 관리할 수 있는 기능 추가
5. **가입자 이력 관리**: 가입자의 상태 변경 이력을 조회할 수 있는 기능 추가
6. **지도 통합**: 가입자 위치를 지도에서 확인할 수 있는 기능 추가
7. **배치 작업**: 여러 가입자에 대한 배치 작업(상태 변경, 삭제 등) 기능 추가
8. **가입자-장치 연결 관리**: 가입자와 장치 간의 연결을 관리하는 기능 강화 