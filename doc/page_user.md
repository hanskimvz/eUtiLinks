# 사용자 관리 페이지 (UserManagementPage)

## 개요
사용자 관리 페이지는 시스템 내의 사용자를 관리하는 기능을 제공합니다. 사용자 목록 조회, 추가, 수정, 삭제 및 미승인 사용자 승인 기능을 포함합니다.

## 파일 구조

```
lib/features/settings/presentation/pages/
└── user_management_page.dart     # 사용자 관리 페이지
```

## 주요 기능

### 1. 사용자 목록 조회
- 모든 사용자 정보를 테이블 형태로 표시
- 사용자 검색 기능 제공
- 사용자 정보 새로고침 기능

### 2. 사용자 추가
- 새 사용자 추가 다이얼로그 제공
- 필수 입력 필드 검증 (사용자 ID, 이름, 이메일, 비밀번호)
- 역할, 언어, 활성화 상태 설정 가능

### 3. 사용자 수정
- 기존 사용자 정보 수정 다이얼로그 제공
- 이름, 이메일, 코멘트, 역할, 언어, 활성화 상태 수정 가능
- 사용자 ID는 수정 불가

### 4. 사용자 삭제
- 사용자 삭제 확인 다이얼로그 제공
- 삭제 후 목록 자동 갱신

### 5. 미승인 사용자 관리
- 미승인 사용자 목록 조회
- 사용자 승인 기능 (DB 이름 설정 및 활성화 상태 지정)
- 미승인 사용자 정보 표시 (등록일, ID, 이메일, 이름, 코멘트)
- 승인 시 DB 이름 지정 및 활성화 상태 설정 가능

## 주요 클래스 및 위젯

### UserManagementPage
- `_UserManagementPageState`: 사용자 관리 페이지의 상태 관리
- 주요 메서드:
  - `_loadData()`: 초기 데이터 로드 (인증 데이터 초기화, 사용자 목록 및 미승인 사용자 목록 조회)
  - `_fetchUsers()`: 서버에서 사용자 목록을 가져오는 함수
  - `_fetchPendingUsers()`: 미승인 사용자 목록을 가져오는 함수
  - `_addUser()`: 사용자 추가 API 호출
  - `_updateUser()`: 사용자 수정 API 호출
  - `_deleteUser()`: 사용자 삭제 API 호출
  - `_approveUser()`: 사용자 승인 API 호출
  - `_filterUsers()`: 검색어에 따라 사용자 목록 필터링
  - `_showAddUserDialog()`: 사용자 추가 다이얼로그 표시
  - `_showEditUserDialog()`: 사용자 수정 다이얼로그 표시
  - `_showDeleteUserDialog()`: 사용자 삭제 확인 다이얼로그 표시
  - `_showPendingUsersDialog()`: 미승인 사용자 목록 다이얼로그 표시
  - `_buildUserTable()`: 사용자 목록 테이블 위젯 생성
  - `_getRoleName()`: 역할 코드에 따른 역할 이름 반환

## 데이터 흐름

1. 페이지 로드 → 인증 데이터 초기화 → 사용자 목록 및 미승인 사용자 목록 조회
2. 사용자 추가 → 추가 다이얼로그 → 사용자 정보 입력 → API 호출 → 목록 갱신
3. 사용자 수정 → 수정 다이얼로그 → 사용자 정보 수정 → API 호출 → 목록 갱신
4. 사용자 삭제 → 삭제 확인 다이얼로그 → API 호출 → 목록 갱신
5. 미승인 사용자 승인 → 미승인 사용자 목록 다이얼로그 → DB 이름 및 상태 설정 → API 호출 → 목록 갱신

## API 호출 형식

### 사용자 목록 조회
```json
{
  "action": "list",
  "format": "json",
  "fields": ["code", "ID", "email", "name", "lang", "role", "groups", "regdate", "flag", "comment"],
  ...AuthService.authData
}
```

**응답 형식**:
```json
{
  "code": 200,
  "data": [
    {
      "code": "사용자코드",
      "ID": "사용자아이디",
      "email": "이메일",
      "name": "이름",
      "lang": "언어코드",
      "role": "역할",
      "groups": "그룹정보",
      "regdate": "등록일시",
      "flag": true/false,
      "comment": "코멘트"
    },
    ...
  ]
}
```

### 사용자 추가
```json
{
  "action": "add",
  "format": "json",
  ...AuthService.authData,
  "data": {
    "ID": "사용자아이디",
    "name": "이름",
    "email": "이메일",
    "password": "비밀번호",
    "role": "역할",
    "lang": "언어",
    "flag": true/false,
    "comment": ""
  }
}
```

**응답 형식**:
```json
{
  "code": 200,
  "message": "사용자 추가 성공"
}
```

### 사용자 수정
```json
{
  "action": "modify",
  "format": "json",
  ...AuthService.authData,
  "data": {
    "code": "사용자코드",
    "ID": "사용자아이디",
    "name": "이름",
    "email": "이메일",
    "user_role": "역할",
    "lang": "언어",
    "groups": "",
    "flag": true/false,
    "comment": "코멘트"
  }
}
```

**응답 형식**:
```json
{
  "code": 200,
  "message": "사용자 수정 성공"
}
```

### 사용자 삭제
```json
{
  "action": "delete",
  "format": "json",
  ...AuthService.authData,
  "data": {
    "code": "사용자코드",
    "ID": "사용자아이디"
  }
}
```

**응답 형식**:
```json
{
  "code": 200,
  "message": "사용자 삭제 성공"
}
```

### 미승인 사용자 목록 조회
```json
{
  "action": "list",
  "format": "json",
  "fields": ["code", "ID", "email", "name", "regdate", "comment"],
  ...AuthService.authData
}
```

**응답 형식**:
```json
{
  "code": 200,
  "data": [
    {
      "code": "사용자코드",
      "ID": "사용자아이디",
      "email": "이메일",
      "name": "이름",
      "regdate": "등록일시",
      "comment": "코멘트"
    },
    ...
  ]
}
```

### 사용자 승인
```json
{
  "action": "approve",
  "format": "json",
  ...AuthService.authData,
  "code": "사용자코드",
  "ID": "사용자아이디",
  "db_name": "DB이름",
  "flag": true/false
}
```

**응답 형식**:
```json
{
  "code": 200,
  "message": "사용자 승인 성공"
}
```

## 미승인 사용자 (Floating User) 관리

미승인 사용자는 시스템에 가입 신청을 했지만 아직 관리자의 승인을 받지 않은 사용자를 의미합니다.

### 미승인 사용자 목록 조회 프로세스
1. 미승인 사용자 목록 버튼 클릭
2. `/api/floating_user` 엔드포인트로 목록 요청
3. 응답 데이터를 기반으로 미승인 사용자 목록 표시
4. 각 사용자별로 승인 폼 제공

### 미승인 사용자 승인 프로세스
1. 미승인 사용자 정보 확인 (ID, 이름, 이메일, 등록일, 코멘트)
2. DB 이름 입력 (사용자가 사용할 데이터베이스 이름)
3. 활성화 상태 설정 (활성/비활성)
4. 승인 버튼 클릭
5. `/api/user` 엔드포인트로 승인 요청 전송
6. 승인 성공 시 미승인 사용자 목록에서 해당 사용자 제거
7. 승인된 사용자는 일반 사용자 목록에 추가됨

### 미승인 사용자 다이얼로그 UI
- 다이얼로그 너비: 화면 너비의 50%
- 다이얼로그 높이: 화면 높이의 60%
- 각 미승인 사용자는 카드 형태로 표시
- 카드 내용: 등록일, ID, 이름, 이메일, 코멘트
- 승인 폼: DB 이름 입력 필드, 활성화 상태 스위치, 승인 버튼

## 사용자 역할
- admin: 관리자
- operator: 운영자
- installer: 설치자
- user: 일반 사용자
- guest: 게스트

## 언어 설정
- kor: 한국어
- eng: 영어
- chn: 중국어

## 상태 관리
- active: 활성화 상태
- inactive: 비활성화 상태

## 오류 처리
- API 호출 실패 시 오류 메시지 표시
- 필수 입력 필드 누락 시 유효성 검사 오류 표시
- 서버 응답 오류 코드에 따른 적절한 오류 메시지 표시

## 사용자 인터페이스 구성요소

### 사용자 목록 테이블
- 컬럼: 코드, ID, 이름, 이메일, 언어, 역할, 등록일, 상태, 작업
- 각 행에 수정 및 삭제 버튼 제공
- 반응형 레이아웃으로 화면 크기에 따라 자동 조정

### 사용자 추가/수정 다이얼로그
- 입력 필드: 사용자 ID, 이름, 이메일, 비밀번호, 역할, 언어, 상태
- 필수 입력 필드 검증 및 오류 표시
- 저장 및 취소 버튼

### 미승인 사용자 다이얼로그
- 미승인 사용자 목록 카드 형태로 표시
- 각 카드에 승인 폼 제공
- 승인 및 취소 버튼

## 서비스 클래스

### UserService
사용자 관련 API 호출을 담당하는 서비스 클래스입니다. 사용자 관리 페이지에서 직접 API를 호출하던 코드를 분리하여 별도의 서비스 클래스로 구현했습니다.

#### 파일 위치
```
lib/core/services/user_service.dart
```

#### 클래스 구조
```dart
class UserService {
  final String baseUrl;

  UserService({required this.baseUrl}) {
    _initService();
  }

  Future<void> _initService() async {
    await AuthService.initAuthData();
  }

  Map<String, String> get authData => AuthService.authData;

  // API 호출 메서드들...
}
```

#### 주요 메서드
- `getUsers()`: 사용자 목록을 가져옵니다.
- `getPendingUsers()`: 미승인 사용자 목록을 가져옵니다.
- `addUser()`: 사용자를 추가합니다.
- `updateUser()`: 사용자 정보를 수정합니다.
- `deleteUser()`: 사용자를 삭제합니다.
- `approveUser()`: 미승인 사용자를 승인합니다.

#### 사용 예시
```dart
final userService = UserService(baseUrl: ApiConstants.serverAddress);

// 사용자 목록 가져오기
final users = await userService.getUsers();

// 사용자 추가
final userData = {
  'username': 'user123',
  'name': '홍길동',
  'email': 'user@example.com',
  'password': 'password123',
  'role': 'user',
  'lang': 'kor',
  'status': 'active',
};
final success = await userService.addUser(userData);

// 미승인 사용자 승인
final approvalData = {
  'id': 'user_code',
  'username': 'user123',
  'db_name': 'user_db',
  'flag': true,
};
final approved = await userService.approveUser(approvalData);
```

### UserModel
사용자 정보를 담는 데이터 모델 클래스입니다. API 응답 데이터를 객체 지향적으로 처리하기 위해 도입되었습니다.

#### 파일 위치
```
lib/core/models/user_model.dart
```

#### 클래스 구조
```dart
class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final String role;
  final String lastLogin;
  final String status;
  final String lang;
  final String comment;

  UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.lastLogin,
    this.status = 'active',
    this.lang = 'kor',
    this.comment = '',
  });

  // 팩토리 생성자 및 변환 메서드...
}
```

#### 주요 속성
- `id`: 사용자 코드
- `username`: 사용자 ID
- `name`: 사용자 이름
- `email`: 이메일
- `role`: 역할
- `lastLogin`: 마지막 로그인 시간
- `status`: 상태 (active/inactive)
- `lang`: 언어 설정
- `comment`: 코멘트

#### 주요 메서드
- `fromJson()`: JSON 데이터로부터 UserModel 객체 생성
- `toJson()`: UserModel 객체를 JSON 형태로 변환
- `toApiJson()`: API 요청에 맞는 형식으로 JSON 변환

## 코드 구조 개선

### API 호출 코드 분리의 이점

1. **관심사 분리(Separation of Concerns)**
   - UI 로직과 API 호출 로직이 분리되어 코드의 가독성과 유지보수성이 향상됩니다.
   - UserManagementPage는 UI 표시와 사용자 상호작용에만 집중할 수 있습니다.
   - UserService는 API 통신과 데이터 처리에만 집중할 수 있습니다.

2. **재사용성(Reusability)**
   - UserService는 다른 화면이나 위젯에서도 쉽게 재사용할 수 있습니다.
   - 동일한 API 호출이 필요한 다른 기능에서 코드 중복을 방지할 수 있습니다.

3. **테스트 용이성(Testability)**
   - 비즈니스 로직과 UI 로직이 분리되어 단위 테스트가 용이해집니다.
   - UserService만 독립적으로 테스트할 수 있어 테스트 커버리지를 높일 수 있습니다.

4. **유지보수성(Maintainability)**
   - API 엔드포인트나 요청/응답 형식이 변경될 경우 UserService만 수정하면 됩니다.
   - 여러 화면에서 동일한 API를 사용하는 경우 한 곳에서만 수정하면 되므로 유지보수가 용이합니다.

5. **코드 일관성(Consistency)**
   - 다른 서비스 클래스(AuthService, DeviceService 등)와 동일한 패턴을 사용하여 코드 일관성이 향상됩니다.
   - 개발자가 코드베이스를 더 쉽게 이해하고 작업할 수 있습니다.

### 현재 코드 구조

```
lib/core/
├── models/
│   └── user_model.dart           # 사용자 데이터 모델
└── services/
    └── user_service.dart         # 사용자 관련 API 호출 서비스

lib/features/settings/presentation/pages/
└── user_management_page.dart     # UI 코드, UserService를 통해 API 호출
```

### UserManagementPage에서의 UserService 사용

UserManagementPage는 UserService를 통해 API를 호출합니다.

```dart
class _UserManagementPageState extends State<UserManagementPage> {
  // ...
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(baseUrl: ApiConstants.serverAddress);
    _loadData();
  }

  // 서버에서 사용자 목록을 가져오는 함수
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await _userService.getUsers();
      
      setState(() {
        _users.clear();
        _users.addAll(users);
        _filteredUsers = List.from(_users);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // 다른 API 호출 메서드들도 유사한 방식으로 구현
} 