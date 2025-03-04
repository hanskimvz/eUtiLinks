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

- **URL**: `/api/query`
- **Method**: `POST`
- **인증 필요**: 예

#### 요청 파라미터
```json
{
  "page": "database",
  "db": "gas_demo",
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