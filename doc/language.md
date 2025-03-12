# 다국어 지원 시스템 가이드

## 개요

이 프로젝트는 Flutter의 공식 국제화(i18n) 시스템을 사용하여 다국어를 지원합니다. 이 문서는 다국어 지원 시스템의 구조, 언어 파일 수정 방법, 그리고 변경사항을 적용하는 방법에 대해 설명합니다.

## 다국어 지원 시스템 구조

### 핵심 컴포넌트

1. **ARB 파일**: 각 언어별 번역 문자열이 포함된 JSON 형식의 파일
   - 위치: `l10n/` 디렉토리
   - 파일명 형식: `app_<언어코드>.arb`
   - 예: `app_en.arb` (영어), `app_ko.arb` (한국어)

2. **AppLocalizations 클래스**: 자동 생성된 로컬라이제이션 클래스
   - 위치: `l10n/app_localizations.dart`
   - 역할: 언어 코드에 따라 적절한 번역 문자열을 제공

### 코드에서의 사용 방법

```dart
// AppLocalizations 클래스 가져오기
import '../../../../l10n/app_localizations.dart';

// 현재 컨텍스트의 로컬라이제이션 객체 가져오기
final localizations = AppLocalizations.of(context)!;

// 번역된 문자열 사용하기
Text(localizations.deviceList)
```

## 언어 파일 구조

ARB 파일은 JSON 형식으로, 키-값 쌍으로 구성됩니다. 각 키는 코드에서 참조할 식별자이고, 값은 해당 언어로 번역된 문자열입니다.

### 예시: app_ko.arb (한국어)

```json
{
  "customerName": "고객명",
  "customerNo": "고객번호",
  "deviceList": "장치 목록",
  "meterId": "계량기 ID",
  "deviceUid": "장치 UID",
  "lastCount": "마지막 검침값",
  "lastAccess": "마지막 접속",
  "status": "상태",
  "category": "카테고리",
  "subscriberClass": "가입자 분류",
  "inOutdoor": "실내/실외",
  "shareHouse": "공동주택",
  "address": "주소",
  "refresh": "새로고침",
  "excelFileSaved": "엑셀 파일이 저장되었습니다",
  "excelFileSaveError": "엑셀 파일 저장 중 오류가 발생했습니다",
  "cancel": "취소",
  "confirm": "확인"
}
```

### 예시: app_en.arb (영어)

```json
{
  "customerName": "Customer Name",
  "customerNo": "Customer No",
  "deviceList": "Device List",
  "meterId": "Meter ID",
  "deviceUid": "Device UID",
  "lastCount": "Last Count",
  "lastAccess": "Last Access",
  "status": "Status",
  "category": "Category",
  "subscriberClass": "Subscriber Class",
  "inOutdoor": "Indoor/Outdoor",
  "shareHouse": "Share House",
  "address": "Address",
  "refresh": "Refresh",
  "excelFileSaved": "Excel file has been saved",
  "excelFileSaveError": "Error saving Excel file",
  "cancel": "Cancel",
  "confirm": "Confirm"
}
```

## 언어 파일 수정 방법

### 오타 수정하기

1. `l10n` 디렉토리에서 수정하려는 언어의 ARB 파일을 찾습니다.
2. 텍스트 에디터로 파일을 열고 수정하려는 문자열을 찾습니다.
3. 값을 수정하고 파일을 저장합니다.

### 새 문자열 추가하기

1. 모든 언어 파일(예: app_en.arb, app_ko.arb 등)에 동일한 키로 새 문자열을 추가합니다.
2. 각 언어에 맞게 번역된 값을 입력합니다.
3. 파일을 저장합니다.

### 주의사항

- 키는 모든 언어 파일에서 동일해야 합니다.
- 키는 영문 소문자로 시작하고, camelCase 형식을 사용하는 것이 일반적입니다.
- 특수 문자나 공백은 키에 사용하지 않는 것이 좋습니다.
- 번역되지 않은 문자열이 있으면 기본 언어(보통 영어)의 문자열이 표시됩니다.

## 변경사항 반영 방법

ARB 파일을 수정한 후에는 로컬라이제이션 클래스를 다시 생성해야 합니다.

### 기본 명령어

```bash
flutter gen-l10n
```

### 대체 명령어 (프로젝트 설정에 따라 다를 수 있음)

```bash
flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/app_localizations.dart lib/l10n/app_*.arb
```

### pubspec.yaml 설정 확인

정확한 명령어는 프로젝트의 `pubspec.yaml` 파일에 정의된 설정에 따라 다를 수 있습니다. `flutter` 섹션 아래 `generate` 또는 `l10n` 관련 설정을 확인하세요.

```yaml
flutter:
  generate: true  # 자동 생성 활성화
  
  # 국제화 설정
  l10n:
    arb-dir: lib/l10n
    template-arb-file: app_en.arb
    output-localization-file: app_localizations.dart
```

## 변경사항 테스트

1. 로컬라이제이션 클래스를 다시 생성합니다.
2. 앱을 다시 빌드하고 실행합니다:
   ```bash
   flutter run
   ```
3. 앱 내에서 언어 설정을 변경하거나, 수정한 언어로 설정된 상태에서 해당 텍스트가 표시되는 화면으로 이동하여 변경사항이 적용되었는지 확인합니다.

## 언어 전환 구현

앱에서 언어를 동적으로 전환하려면 다음과 같은 방법을 사용할 수 있습니다:

```dart
// 언어 변경 함수 예시
void changeLanguage(BuildContext context, Locale newLocale) {
  final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
  localeProvider.setLocale(newLocale);
}

// 사용 예시
ElevatedButton(
  onPressed: () => changeLanguage(context, Locale('ko')),
  child: Text('한국어로 변경'),
),
```

## 지원되는 언어 목록

현재 프로젝트에서 지원하는 언어 목록:

- 한국어 (ko)
- 영어 (en)

## 새 언어 추가하기

1. `l10n` 디렉토리에 새 언어의 ARB 파일을 생성합니다 (예: `app_ja.arb` for 일본어).
2. 기존 ARB 파일의 모든 키를 복사하고 해당 언어로 번역합니다.
3. `pubspec.yaml` 파일의 `flutter.l10n.supported-locales` 섹션에 새 언어 코드를 추가합니다 (필요한 경우).
4. 로컬라이제이션 클래스를 다시 생성합니다.

## 문제 해결

### 변경사항이 반영되지 않는 경우

1. 로컬라이제이션 클래스를 다시 생성했는지 확인합니다.
2. 앱을 완전히 다시 시작합니다 (핫 리로드는 ARB 파일 변경을 감지하지 못할 수 있음).
3. 빌드 캐시를 정리합니다:
   ```bash
   flutter clean
   flutter pub get
   ```
4. 다시 빌드하고 실행합니다.

### 오류 메시지가 표시되는 경우

- ARB 파일의 JSON 형식이 올바른지 확인합니다.
- 모든 언어 파일에 동일한 키가 있는지 확인합니다.
- 생성된 로컬라이제이션 클래스 파일에 오류가 있는지 확인합니다.

## 참고 자료

- [Flutter 국제화 공식 문서](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- [ARB 파일 형식 설명](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [intl 패키지 문서](https://pub.dev/packages/intl) 