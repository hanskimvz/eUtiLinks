# 가스 미터링 관리 플랫폼

가스 미터링 관리 플랫폼은 가스 미터기 장치를 관리하고 모니터링하기 위한 Flutter 기반 크로스 플랫폼 애플리케이션입니다.

## 프로젝트 개요

이 프로젝트는 가스 미터기 장치의 설치, 관리, 모니터링을 위한 종합 솔루션을 제공합니다. 웹과 모바일 환경 모두에서 작동하며, 다양한 사용자 역할(관리자, 설치자, 일반 사용자)을 지원합니다.

## 주요 기능

- **장치 관리**: 가스 미터기 장치의 등록, 조회, 수정, 삭제
- **데이터 조회**: 장치에서 수집된 데이터 조회 및 분석
- **사용량 조회**: 가스 사용량 통계 및 보고서
- **이상 상태 관리**: 비정상 미터기 상태 조회 및 해제
- **통계 분석**: 일별, 월별, 연별 통계 데이터 제공
- **사용자 관리**: 사용자 계정 및 권한 관리
- **다국어 지원**: 한국어, 영어 등 다국어 인터페이스

## 기술 스택

- **프론트엔드**: Flutter, Dart
- **상태 관리**: Provider
- **국제화**: Flutter Intl
- **데이터 시각화**: FL Chart
- **네트워크**: HTTP, WebSocket
- **데이터 저장**: SharedPreferences, SQLite

## 설치 및 실행

### 요구 사항

- Flutter 3.0.0 이상
- Dart 2.17.0 이상

### 설치 방법

```bash
# 저장소 클론
git clone [repository-url]

# 디렉토리 이동
cd gas_installer

# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 배포

### 웹 배포

```bash
flutter build web
```

### 안드로이드 배포

```bash
flutter build apk --release
```

### iOS 배포

```bash
flutter build ios --release
```

## 라이센스

이 프로젝트는 [라이센스 이름] 라이센스 하에 배포됩니다. 자세한 내용은 LICENSE 파일을 참조하세요.
