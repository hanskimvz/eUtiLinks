# 로그아웃 기능 리팩토링

## 문제점

기존 코드에서는 여러 페이지(`HomePage`, `InfoManagementPage`, `InstallerPage`, `SettingsPage`, `StatisticsPage` 등)에서 동일한 로그아웃 기능을 구현하기 위해 각각 `_logout()` 메서드를 중복해서 작성하고 있었습니다. 이로 인해 다음과 같은 문제가 발생했습니다:

1. 코드 중복: 동일한 로그아웃 로직이 여러 페이지에 반복됨
2. 유지보수 어려움: 로그아웃 로직 변경 시 모든 페이지를 수정해야 함
3. 일관성 부족: 페이지마다 로그아웃 구현이 약간씩 다를 가능성 존재

## 해결 방법

로그아웃 기능을 중앙화하기 위해 `AuthService` 클래스에 `showLogoutDialog` 메서드를 추가하여 로그아웃 다이얼로그 표시와 로그아웃 처리를 한 곳에서 관리하도록 변경했습니다.

### 1. AuthService에 showLogoutDialog 메서드 추가

```dart
/// 로그아웃 다이얼로그를 표시하고 사용자가 확인하면 로그아웃을 수행합니다.
static Future<void> showLogoutDialog(BuildContext context) async {
  final localizations = AppLocalizations.of(context)!;
  
  // 로그아웃 확인 다이얼로그 표시
  final shouldLogout = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(localizations.logoutTitle),
      content: Text(localizations.logoutConfirmation),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(localizations.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(localizations.logout),
        ),
      ],
    ),
  ) ?? false;

  if (shouldLogout) {
    await logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }
}
```

### 2. 각 페이지에서 중복된 _logout() 메서드 제거

모든 페이지에서 중복된 `_logout()` 메서드를 제거하고, `MainLayout`의 `onLogout` 속성에 `() => AuthService.showLogoutDialog(context)` 람다 함수를 전달하도록 변경했습니다.

예시:
```dart
// 변경 전
onLogout: _logout,

// 변경 후
onLogout: () => AuthService.showLogoutDialog(context),
```

### 변경된 파일 목록

다음 파일들에서 중복된 `_logout()` 메서드를 제거하고 `AuthService.showLogoutDialog(context)`를 사용하도록 수정했습니다:

1. `lib/features/home/presentation/pages/home_page.dart`
2. `lib/features/info_management/presentation/pages/info_management_page.dart`
3. `lib/features/installer/presentation/pages/installer_page.dart`
4. `lib/features/settings/presentation/pages/settings_page.dart`
5. `lib/features/statistics/presentation/pages/statistics_page.dart`

## 장점

이러한 리팩토링의 장점은 다음과 같습니다:

1. **코드 중복 제거**: 동일한 로그아웃 로직이 여러 페이지에 중복되지 않습니다.
2. **유지보수 용이성**: 로그아웃 로직을 변경해야 할 경우 한 곳만 수정하면 됩니다.
3. **일관성**: 모든 페이지에서 동일한 로그아웃 경험을 제공합니다.
4. **관심사 분리**: 인증 관련 로직은 `AuthService`에 집중되어 있습니다.

## 사용 방법

새로운 페이지에서 로그아웃 기능이 필요한 경우, 다음과 같이 간단히 구현할 수 있습니다:

```dart
import '../../../../core/services/auth_service.dart';

// ...

@override
Widget build(BuildContext context) {
  return MainLayout(
    // ...
    onLogout: () => AuthService.showLogoutDialog(context),
    // ...
  );
}
``` 