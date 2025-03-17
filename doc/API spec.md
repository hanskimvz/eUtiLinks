# GAS 인스톨러 앱 API 명세서

## 개요
이 문서는 GAS 인스톨러 앱에서 사용하는 API의 명세를 정의합니다. 모든 API 요청은 기본적으로 HTTPS 프로토콜을 사용하며, 응답 형식은 JSON 형태로 제공됩니다.

## 기본 URL
```
https:{server_ip}:5090/api
```

## 인증 방식
- 로그인 API를 제외한 모든 API 요청에는 인증이 필요합니다.
- 인증은 JWT(JSON Web Token) 방식을 사용합니다.
- 토큰은 HTTP 헤더의 `Authorization` 필드에 `Bearer {token}` 형태로 포함되어야 합니다.

## 공통 요청 변수
모든 API 요청(로그인 API 제외)에는 다음과 같은 공통 변수가 쿠키에 저장되어 있어야 합니다:
- `_login_id`: 로그인한 사용자의 ID
- `_db`: 사용자가 접근하는 데이터베이스 정보
- `_role`: 사용자의 역할 정보

이 정보는 서버에서 사용자 인증 및 권한 확인에 사용됩니다.

## 응답 형식
모든 API 응답은 다음과 같은 형식을 따릅니다:
```json
{
  "code": 상태코드,
  "data": 응답 데이터,
  "total_records": 전체 레코드 수,
  "elapsed_time": 처리 시간(초)
}
```

## 에러 응답 형식
에러가 발생한 경우에도 동일한 응답 형식을 사용하며, code 값은 해당 에러 코드가 됩니다:
```json
{
  "code": 에러코드,
  "data": {
    "message": "에러 메시지"
  },
  "total_records": 0,
  "elapsed_time": 처리 시간(초)
}
```

## API 목록

### 1. 로그인 API
사용자 인증을 위한 API입니다.

- **URL**: `/api/login`
- **Method**: `POST`
- **인증 필요**: 아니오

#### 요청 파라미터
```json
{
  "format": "json",
  "id": "user_id",
  "password": "user_pw"
}
```

#### 응답
```json
{
  "code": 200,
  "data": {
    "ID": "hanskim",
    "code": "U24110319484920",
    "email": "hanskimvz@gmail.com",
    "flag": true,
    "lang": "kor",
    "name": "Hans Kim",
    "regdate": "2024-11-03 10:48:49",
    "role": "admin",
    "db_name": "gas_demo",
    "userseq": "ca29e7325bf9825817bc185cb3435f49",
    "token": "JWT 인증 토큰"
  },
  "total_records": 1,
  "elapsed_time": 0.12
}
```

#### 에러 코드
- `401`: 인증 실패 (아이디 또는 비밀번호 오류)
- `422`: 유효하지 않은 요청 파라미터
- `500`: 서버 오류

---

### 2. 데이터 조회 API
데이터베이스에서 정보를 조회하는 API입니다. 장비 목록 조회와 장비 상세 정보 조회에 사용됩니다.

- **URL**: `/api/list`
- **Method**: `POST`
- **인증 필요**: 예

#### 요청 파라미터
```json
{
  "page": "list/view/modify/delete...",
  "db": "데이터베이스 이름",
  "table": "테이블명",
  "fields": ["필드1", "필드2", ...],
  "filter": {
    "필드명": "조건 값"
  },
  "format": "json",
  "user_id": "사용자 ID",
  "role": "사용자 역할"
}
```

#### 장비 목록 조회 요청 예시
```json
{
  "page": "database",
  "db": "gas_demo",
  "table": "device",
  "fields": [
    "device_uid",
    "release_date",
    "meter_id",
    "flag"
  ],
  "filter": {
    "installer_id": "hanskim"
  },
  "format": "json",
  "user_id": "hanskim",
  "role": "admin"
}
```

#### 장비 목록 조회 응답 예시
```json
{
  "code": 200,
  "data": {
    "fields": [
      "device_uid",
      "release_date",
      "flag",
      "meter_id"
    ],
    "data": [
      {
        "device_uid": "F68C057D",
        "release_date": "2024-11-03",
        "flag": false,
        "meter_id": "-"
      },
      {
        "device_uid": "D4245A98",
        "release_date": "2024-11-03",
        "flag": false,
        "meter_id": "-"
      },
      // ... 추가 장비 데이터
    ]
  },
  "total_records": 55,
  "elapsed_time": 0.37
}
```

#### 장비 상세 정보 조회 요청 예시
```json
{
  "page": "database",
  "format": "json",
  "db": "gas_demo",
  "table": "device",
  "fields": [
    "device_uid",
    "meter_id",
    "minimum",
    "maximum",
    "release_date",
    "install_date",
    "initial_count",
    "ref_interval",
    "server_ip",
    "server_port",
    "comment",
    "installer_id",
    "flag"
  ],
  "filter": {
    "device_uid": "A3757BB5"
  },
  "user_id": "hanskim",
  "role": "admin"
}
```

#### 장비 상세 정보 조회 응답 예시
```json
{
  "code": 200,
  "data": {
    "fields": [
      "device_uid",
      "release_date",
      "installer_id",
      "comment",
      "flag",
      "initial_count",
      "maximum",
      "meter_id",
      "minimum",
      "ref_interval",
      "server_ip",
      "server_port"
    ],
    "data": [
      {
        "device_uid": "ABD6793E",
        "release_date": "2024-11-03",
        "installer_id": "hanskim",
        "comment": "",
        "flag": true,
        "initial_count": 8600,
        "maximum": 0,
        "meter_id": "254896357856",
        "minimum": 7200,
        "ref_interval": 43200,
        "server_ip": "47.56.150.14",
        "server_port": 5004
      }
    ]
  },
  "total_records": 1,
  "elapsed_time": 0.37
}
```

#### 에러 코드
- `401`: 인증 실패
- `403`: 권한 없음
- `404`: 리소스를 찾을 수 없음
- `422`: 유효하지 않은 요청 파라미터
- `500`: 서버 오류

---

### 3. 데이터 업데이트 API
데이터베이스의 정보를 업데이트하는 API입니다. 장비 정보 업데이트에 사용됩니다.

- **URL**: `/api/update`
- **Method**: `POST`
- **인증 필요**: 예

#### 요청 파라미터
```json
{
  "page": "database",
  "db": "gas_demo",
  "table": "device",
  "filter": {
    "device_uid": "장비 ID"
  },
  "data": {
    "필드명": "업데이트할 값"
  },
  "format": "json",
  "user_id": "사용자 ID",
  "role": "사용자 역할"
}
```

#### 장비 정보 업데이트 요청 예시
```json
{
  "page": "database",
  "db": "gas_demo",
  "table": "device",
  "filter": {
    "device_uid": "ABD6793E"
  },
  "data": {
    "meter_id": "254896357856",
    "flag": true,
    "comment": "업데이트된 장비 정보"
  },
  "format": "json",
  "user_id": "hanskim",
  "role": "admin"
}
```

#### 응답
```json
{
  "code": 200,
  "data": {
    "affected_rows": 1,
    "message": "데이터가 성공적으로 업데이트되었습니다."
  },
  "total_records": 1,
  "elapsed_time": 0.15
}
```

#### 에러 코드
- `401`: 인증 실패
- `403`: 권한 없음
- `404`: 장비를 찾을 수 없음
- `422`: 유효하지 않은 요청 파라미터
- `500`: 서버 오류

---

### 4. 로그아웃 API
사용자 로그아웃을 위한 API입니다.

- **URL**: `/api/logout`
- **Method**: `POST`
- **인증 필요**: 예

#### 요청 파라미터
```json
{
  "format": "json",
  "user_id": "사용자 ID"
}
```

#### 응답
```json
{
  "code": 200,
  "data": {
    "message": "로그아웃 되었습니다."
  },
  "total_records": 0,
  "elapsed_time": 0.08
}
```

#### 에러 코드
- `401`: 인증 실패
- `500`: 서버 오류

---

## 상태 코드
- `200 OK`: 요청이 성공적으로 처리됨
- `201 Created`: 리소스가 성공적으로 생성됨
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `403 Forbidden`: 권한 없음
- `404 Not Found`: 리소스를 찾을 수 없음
- `422 Unprocessable Entity`: 유효하지 않은 요청 파라미터
- `500 Internal Server Error`: 서버 오류

## 데이터 타입
- `id`: 문자열 (UUID)
- `date`: 문자열 (ISO 8601 형식, YYYY-MM-DDTHH:MM:SSZ)
- `status`: 문자열 ('active', 'inactive', 'maintenance' 등)
- `elapsed_time`: 숫자 (API 처리 시간, 초 단위)
- `total_records`: 숫자 (응답에 포함된 전체 레코드 수)

---

작성일: 2024년 3월 2일
버전: 1.4 

# eUtiLinks API 명세서

## 개요
이 문서는 eUtiLinks 애플리케이션에서 사용하는 API의 명세를 정의합니다. 모든 API 요청은 기본적으로 HTTP 프로토콜을 사용하며, 응답 형식은 JSON 형태로 제공됩니다.

## 기본 URL
```
http://140.245.72.44:5100
```

## 인증 방식
- 로그인 API를 통해 인증 정보를 받아 SharedPreferences에 저장합니다.
- 인증 후 모든 API 요청에는 인증 데이터가 요청 본문에 포함되어야 합니다.
- 인증 데이터는 다음과 같은 형태로 포함됩니다:
  - `db_name`: 데이터베이스 이름
  - `login_id`: 로그인한 사용자의 ID
  - `role`: 사용자의 역할 정보
  - `userseq`: 사용자 고유 식별자
  - `level`: 사용자 권한 레벨

## 공통 응답 형식
모든 API 응답은 다음과 같은 형식을 따릅니다:
```json
{
  "code": 200,
  "data": 응답 데이터,
  "message": "성공 메시지"
}
```

## 에러 응답 형식
에러가 발생한 경우에도 동일한 응답 형식을 사용하며, code 값은 해당 에러 코드가 됩니다:
```json
{
  "code": 에러코드,
  "message": "에러 메시지"
}
```

## API 목록

### 1. 인증 API

#### 1.1 로그인 API
사용자 인증을 위한 API입니다.

- **URL**: `/api/login`
- **Method**: `POST`
- **인증 필요**: 아니오

##### 요청 파라미터
```json
{
  "id": "사용자 ID",
  "password": "비밀번호"
}
```

##### 응답
```json
{
  "result": "success",
  "data": {
    "id": "사용자 ID",
    "db_name": "데이터베이스 이름",
    "role": "사용자 역할",
    "name": "사용자 이름",
    "userseq": "사용자 고유 식별자",
    "level": "사용자 권한 레벨"
  }
}
```

##### 에러 응답
```json
{
  "result": "error",
  "message": "로그인에 실패했습니다."
}
```

### 2. 장치 관리 API

#### 2.1 장치 목록 조회 API
장치 목록을 조회하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": [
    "device_uid",
    "last_count",
    "last_access",
    "flag",
    "uptime",
    "initial_access",
    "ref_interval",
    "minimum",
    "maximum",
    "battery",
    "customer_name",
    "customer_no",
    "addr_prov",
    "addr_city",
    "addr_dist",
    "addr_detail",
    "share_house",
    "addr_apt",
    "category",
    "subscriber_no",
    "meter_id",
    "class",
    "in_outdoor"
  ],
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "device_uid": "장치 ID",
      "last_count": "마지막 카운트",
      "last_access": "마지막 접속 시간",
      "flag": true,
      "uptime": "가동 시간",
      "initial_access": "초기 접속 시간",
      "ref_interval": "참조 간격",
      "minimum": "최소값",
      "maximum": "최대값",
      "battery": "배터리 상태",
      "customer_name": "고객 이름",
      "customer_no": "고객 번호",
      "addr_prov": "주소(도)",
      "addr_city": "주소(시)",
      "addr_dist": "주소(구)",
      "addr_detail": "상세 주소",
      "share_house": "공유 주택 여부",
      "addr_apt": "아파트 주소",
      "category": "카테고리",
      "subscriber_no": "가입자 번호",
      "meter_id": "미터기 ID",
      "class": "클래스",
      "in_outdoor": "실내/실외 구분"
    }
  ]
}
```

#### 2.2 장치 상세 정보 조회 API
특정 장치의 상세 정보를 조회하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "view",
  "format": "json",
  "device_uid": "장치 ID",
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": {
    "device_uid": "장치 ID",
    "last_count": "마지막 카운트",
    "last_access": "마지막 접속 시간",
    "flag": true,
    "uptime": "가동 시간",
    "initial_access": "초기 접속 시간",
    "ref_interval": "참조 간격",
    "minimum": "최소값",
    "maximum": "최대값",
    "battery": "배터리 상태",
    "customer_name": "고객 이름",
    "customer_no": "고객 번호",
    "addr_prov": "주소(도)",
    "addr_city": "주소(시)",
    "addr_dist": "주소(구)",
    "addr_detail": "상세 주소",
    "share_house": "공유 주택 여부",
    "addr_apt": "아파트 주소",
    "category": "카테고리",
    "subscriber_no": "가입자 번호",
    "meter_id": "미터기 ID",
    "class": "클래스",
    "in_outdoor": "실내/실외 구분"
  }
}
```

#### 2.3 장치 추가 API
새로운 장치를 추가하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "add",
  "format": "json",
  "data": {
    "device_uid": "장치 ID",
    "customer_name": "고객 이름",
    "customer_no": "고객 번호",
    "meter_id": "미터기 ID",
    "flag": true
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": {
    "device_uid": "장치 ID",
    "customer_name": "고객 이름",
    "customer_no": "고객 번호",
    "meter_id": "미터기 ID",
    "flag": true
  }
}
```

#### 2.4 장치 수정 API
기존 장치 정보를 수정하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "modify",
  "format": "json",
  "data": {
    "device_uid": "장치 ID",
    "customer_name": "고객 이름",
    "customer_no": "고객 번호",
    "meter_id": "미터기 ID",
    "ref_interval": "참조 간격"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": {
    "device_uid": "장치 ID",
    "customer_name": "고객 이름",
    "customer_no": "고객 번호",
    "meter_id": "미터기 ID",
    "ref_interval": "참조 간격"
  }
}
```

#### 2.5 장치 삭제 API
장치를 삭제하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "delete",
  "format": "json",
  "data": {
    "device_uid": "장치 ID"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": true
}
```

#### 2.6 미터기 ID로 장치 조회 API
미터기 ID를 사용하여 장치를 조회하는 API입니다.

- **URL**: `/api/device`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": [
    "device_uid",
    "last_count",
    "last_access",
    "flag",
    "uptime",
    "initial_access",
    "ref_interval",
    "minimum",
    "maximum",
    "battery",
    "customer_name",
    "customer_no",
    "addr_prov",
    "addr_city",
    "addr_dist",
    "addr_detail",
    "share_house",
    "addr_apt",
    "category",
    "subscriber_no",
    "meter_id",
    "class",
    "in_outdoor",
    "release_date",
    "installer_id"
  ],
  "filter": {
    "meter_id": "미터기 ID"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "device_uid": "장치 ID",
      "last_count": "마지막 카운트",
      "last_access": "마지막 접속 시간",
      "flag": true,
      "uptime": "가동 시간",
      "initial_access": "초기 접속 시간",
      "ref_interval": "참조 간격",
      "minimum": "최소값",
      "maximum": "최대값",
      "battery": "배터리 상태",
      "customer_name": "고객 이름",
      "customer_no": "고객 번호",
      "addr_prov": "주소(도)",
      "addr_city": "주소(시)",
      "addr_dist": "주소(구)",
      "addr_detail": "상세 주소",
      "share_house": "공유 주택 여부",
      "addr_apt": "아파트 주소",
      "category": "카테고리",
      "subscriber_no": "가입자 번호",
      "meter_id": "미터기 ID",
      "class": "클래스",
      "in_outdoor": "실내/실외 구분",
      "release_date": "출시 날짜",
      "installer_id": "설치자 ID"
    }
  ]
}
```

### 3. 가입자 관리 API

#### 3.1 가입자 목록 조회 API
가입자 목록을 조회하는 API입니다.

- **URL**: `/api/subscriber`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": [],
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "subscriber_id": "가입자 ID",
      "name": "가입자 이름",
      "phone": "전화번호",
      "address": "주소",
      "email": "이메일",
      "status": "상태"
    }
  ]
}
```

#### 3.2 미터기 ID로 가입자 조회 API
미터기 ID를 사용하여 가입자를 조회하는 API입니다.

- **URL**: `/api/subscriber`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "view",
  "meter_id": "미터기 ID",
  "format": "json",
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": {
    "subscriber_id": "가입자 ID",
    "name": "가입자 이름",
    "phone": "전화번호",
    "address": "주소",
    "email": "이메일",
    "status": "상태",
    "meter_id": "미터기 ID"
  }
}
```

#### 3.3 필터를 사용한 가입자 조회 API
필터를 사용하여 가입자를 조회하는 API입니다.

- **URL**: `/api/subscriber`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": ["필드1", "필드2", "..."],
  "filter": {
    "필드명": "조건 값"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "필드1": "값1",
      "필드2": "값2",
      "...": "..."
    }
  ]
}
```

### 4. 사용자 관리 API

#### 4.1 사용자 목록 조회 API
사용자 목록을 조회하는 API입니다.

- **URL**: `/api/user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": [
    "code",
    "ID",
    "email",
    "name",
    "lang",
    "role",
    "groups",
    "regdate",
    "flag",
    "comment"
  ],
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "id": "사용자 코드",
      "username": "사용자 ID",
      "name": "사용자 이름",
      "email": "이메일",
      "role": "역할",
      "lastLogin": "마지막 로그인 시간",
      "status": "상태",
      "lang": "언어",
      "comment": "설명"
    }
  ]
}
```

#### 4.2 미승인 사용자 목록 조회 API
미승인 사용자 목록을 조회하는 API입니다.

- **URL**: `/api/floating_user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "list",
  "format": "json",
  "fields": [
    "code",
    "ID",
    "email",
    "name",
    "regdate",
    "comment"
  ],
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": [
    {
      "id": "사용자 코드",
      "username": "사용자 ID",
      "name": "사용자 이름",
      "email": "이메일",
      "regdate": "등록 날짜",
      "comment": "설명"
    }
  ]
}
```

#### 4.3 사용자 추가 API
새로운 사용자를 추가하는 API입니다.

- **URL**: `/api/user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "add",
  "format": "json",
  "data": {
    "ID": "사용자 ID",
    "name": "사용자 이름",
    "email": "이메일",
    "password": "비밀번호",
    "role": "역할",
    "lang": "언어",
    "flag": true,
    "comment": "설명"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": true
}
```

#### 4.4 사용자 수정 API
기존 사용자 정보를 수정하는 API입니다.

- **URL**: `/api/user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "modify",
  "format": "json",
  "data": {
    "code": "사용자 코드",
    "ID": "사용자 ID",
    "name": "사용자 이름",
    "email": "이메일",
    "user_role": "역할",
    "lang": "언어",
    "groups": "그룹",
    "flag": true,
    "comment": "설명"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": true
}
```

#### 4.5 사용자 삭제 API
사용자를 삭제하는 API입니다.

- **URL**: `/api/user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "delete",
  "format": "json",
  "data": {
    "code": "사용자 코드",
    "ID": "사용자 ID"
  },
  "db_name": "데이터베이스 이름",
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": true
}
```

#### 4.6 사용자 승인 API
미승인 사용자를 승인하는 API입니다.

- **URL**: `/api/user`
- **Method**: `POST`
- **인증 필요**: 예

##### 요청 파라미터
```json
{
  "action": "approve",
  "format": "json",
  "code": "사용자 코드",
  "ID": "사용자 ID",
  "db_name": "데이터베이스 이름",
  "flag": true,
  "login_id": "사용자 ID",
  "role": "사용자 역할",
  "userseq": "사용자 고유 식별자",
  "level": "사용자 권한 레벨"
}
```

##### 응답
```json
{
  "code": 200,
  "data": true
}
``` 