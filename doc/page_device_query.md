# DeviceQueryPage 분석

`device_query_page.dart`는 장치 정보를 조회하고 관리하는 페이지를 구현한 파일입니다. 이 문서는 해당 페이지의 주요 기능과 구조를 설명합니다.

## 주요 구성 요소

### 1. 클래스 구조
- `DeviceQueryPage`: StatefulWidget으로, 장치 조회 페이지의 기본 구조를 정의
- `_DeviceQueryPageState`: 페이지의 상태를 관리하는 State 클래스

### 2. 상태 관리
```dart
final _searchController = TextEditingController();
List<DeviceModel> _devices = [];
List<DeviceModel> _filteredDevices = [];
bool _isLoading = true;
String _errorMessage = '';
```
- 검색 입력을 위한 컨트롤러
- 전체 장치 목록과 필터링된 장치 목록
- 로딩 상태와 오류 메시지 관리

### 3. 데이터 정렬 및 페이지네이션
```dart
int _sortColumnIndex = 0;
bool _sortAscending = true;
final int _rowsPerPage = 10;
int _currentPage = 0;
```
- 테이블 데이터 정렬을 위한 변수
- 페이지당 표시할 행 수와 현재 페이지 관리

### 4. 주요 메서드

#### 데이터 로드
```dart
Future<void> _loadDevices() async { ... }
```
- API를 통해 장치 목록을 가져오는 비동기 메서드
- 필드 목록과 필터를 지정하여 서버에 요청

#### 검색 기능
```dart
void _filterDevices(String query) { ... }
```
- 사용자 입력에 따라 장치 목록을 필터링
- 장치 ID, 고객명, 고객번호 등 여러 필드로 검색 가능

#### 장치 정보 표시
```dart
void _showDeviceInfo(DeviceModel device) { ... }
```
- 선택한 장치의 상세 정보를 모달 다이얼로그로 표시
- `DeviceInfoViewPage` 위젯을 사용하여 정보 표시

#### 기타 기능
- `_showUsageHistory`: 사용량 내역 표시 (준비 중)
- `_showAbnormalStatus`: 이상 증상 확인 (준비 중)

### 5. UI 구성
- 검색 필드와 새로고침/내보내기 버튼
- 통계 카드 (전체/정상/주의 필요 장치 수)
- 데이터 테이블 (정렬 및 페이지네이션 기능)
- 각 행 클릭 시 장치 메뉴 표시

## 주요 특징

1. **모달 다이얼로그 사용**: 장치 정보를 전체 화면 전환 없이 모달로 표시하여 사용자 경험 향상
   ```dart
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return Dialog( ... );
     },
   );
   ```

2. **데이터 필터링 및 정렬**: 사용자가 쉽게 원하는 장치를 찾을 수 있도록 검색 및 정렬 기능 제공

3. **페이지네이션**: 대량의 데이터를 효율적으로 표시하기 위한 페이지 분할 구현

4. **반응형 UI**: 화면 크기에 따라 적절히 조정되는 레이아웃 구현

5. **엑셀 내보내기**: 장치 목록을 엑셀 파일로 내보내는 기능 제공

## 데이터 흐름

1. 페이지 초기화 시 `_loadDevices()` 메서드를 통해 서버에서 장치 목록을 가져옴
2. 사용자가 검색어를 입력하면 `_filterDevices()` 메서드를 통해 목록을 필터링
3. 사용자가 테이블 헤더를 클릭하면 해당 열을 기준으로 데이터 정렬
4. 사용자가 행을 클릭하면 `_showDeviceMenu()` 메서드를 통해 장치 메뉴 표시
5. 메뉴에서 옵션 선택 시 해당 기능 실행 (`_showDeviceInfo()`, `_showUsageHistory()`, `_showAbnormalStatus()`)

## 개선 가능한 부분

1. 대량의 데이터 처리 최적화
2. 오프라인 모드 지원
3. 사용자 정의 필터 추가
4. 데이터 캐싱 구현
5. 테스트 코드 작성 