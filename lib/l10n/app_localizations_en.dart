// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SEJIN TECH Gas Metering Management Platform';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get usernameRequired => 'Please enter your username';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get invalidCredentials => 'Invalid username or password';

  @override
  String serverConnectionError(String error) {
    return 'Server connection error: $error';
  }

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordMessage => 'Please contact the administrator.';

  @override
  String get confirm => 'Confirm';

  @override
  String get infoManagement => 'Information';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get deviceQuery => 'Device Query';

  @override
  String get receivedDataQuery => 'Received Data Query';

  @override
  String get usageQuery => 'Usage Query';

  @override
  String get abnormalMeterQuery => 'Abnormal Meter Query/Release';

  @override
  String get dailyStatistics => 'Daily Statistics';

  @override
  String get monthlyStatistics => 'Monthly Statistics';

  @override
  String get yearlyStatistics => 'Yearly Statistics';

  @override
  String get subscriberStatistics => 'Subscriber Statistics';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get permissionManagement => 'Permission Management';

  @override
  String get userManagement => 'User Management';

  @override
  String get locationManagement => 'Location Management';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get subscriberManagement => 'Subscriber Management';

  @override
  String get eventManagement => 'Event Management';

  @override
  String get dailyDataManagement => 'Daily Data Management';
}
