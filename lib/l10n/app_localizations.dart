import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SEJIN TECH Gas Metering Management Platform'**
  String get appTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @serverConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Server connection error: {error}'**
  String serverConnectionError(Object error);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordMessage.
  ///
  /// In en, this message translates to:
  /// **'Please contact the administrator.'**
  String get forgotPasswordMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @infoManagement.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get infoManagement;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @installerMenu.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get installerMenu;

  /// No description provided for @deviceQuery.
  ///
  /// In en, this message translates to:
  /// **'Device Query'**
  String get deviceQuery;

  /// No description provided for @receivedDataQuery.
  ///
  /// In en, this message translates to:
  /// **'Received Data Query'**
  String get receivedDataQuery;

  /// No description provided for @usageQuery.
  ///
  /// In en, this message translates to:
  /// **'Usage Query'**
  String get usageQuery;

  /// No description provided for @abnormalMeterQuery.
  ///
  /// In en, this message translates to:
  /// **'Abnormal Meter Query/Release'**
  String get abnormalMeterQuery;

  /// No description provided for @dailyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Daily Statistics'**
  String get dailyStatistics;

  /// No description provided for @monthlyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Monthly Statistics'**
  String get monthlyStatistics;

  /// No description provided for @yearlyStatistics.
  ///
  /// In en, this message translates to:
  /// **'Yearly Statistics'**
  String get yearlyStatistics;

  /// No description provided for @subscriberStatistics.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Statistics'**
  String get subscriberStatistics;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @systemSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage system settings.'**
  String get systemSettingsDescription;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @serverSettings.
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get serverSettings;

  /// No description provided for @serverSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Configure the server that the application will connect to.'**
  String get serverSettingsDescription;

  /// No description provided for @selectServerEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Select Server Environment'**
  String get selectServerEnvironment;

  /// No description provided for @devServer.
  ///
  /// In en, this message translates to:
  /// **'Development Server'**
  String get devServer;

  /// No description provided for @prodServer.
  ///
  /// In en, this message translates to:
  /// **'Production Server'**
  String get prodServer;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @useCustomServer.
  ///
  /// In en, this message translates to:
  /// **'Use Custom Server'**
  String get useCustomServer;

  /// No description provided for @serverAddress.
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// No description provided for @serverAddressHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.100'**
  String get serverAddressHint;

  /// No description provided for @serverPort.
  ///
  /// In en, this message translates to:
  /// **'Server Port'**
  String get serverPort;

  /// No description provided for @serverPortHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5100'**
  String get serverPortHint;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @serverAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a server address.'**
  String get serverAddressRequired;

  /// No description provided for @validPortRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid port number (1-65535).'**
  String get validPortRequired;

  /// No description provided for @serverSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Server settings have been saved.'**
  String get serverSettingsSaved;

  /// No description provided for @serverSettingsReset.
  ///
  /// In en, this message translates to:
  /// **'Server settings have been reset.'**
  String get serverSettingsReset;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @permissionManagement.
  ///
  /// In en, this message translates to:
  /// **'Permission Management'**
  String get permissionManagement;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @locationManagement.
  ///
  /// In en, this message translates to:
  /// **'Location Management'**
  String get locationManagement;

  /// No description provided for @locationManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage locations of devices and subscribers'**
  String get locationManagementDescription;

  /// No description provided for @deviceManagement.
  ///
  /// In en, this message translates to:
  /// **'Device Management'**
  String get deviceManagement;

  /// No description provided for @deviceManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage devices and monitor their status.'**
  String get deviceManagementDescription;

  /// No description provided for @searchDevice.
  ///
  /// In en, this message translates to:
  /// **'Search Devices'**
  String get searchDevice;

  /// No description provided for @searchDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Search by device ID, name, location, etc.'**
  String get searchDeviceHint;

  /// No description provided for @addDevice.
  ///
  /// In en, this message translates to:
  /// **'Add Device'**
  String get addDevice;

  /// No description provided for @editDevice.
  ///
  /// In en, this message translates to:
  /// **'Edit Device'**
  String get editDevice;

  /// No description provided for @deleteDevice.
  ///
  /// In en, this message translates to:
  /// **'Delete Device'**
  String get deleteDevice;

  /// No description provided for @deleteDeviceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete device {name}?'**
  String deleteDeviceConfirm(Object name);

  /// No description provided for @deviceAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device has been added successfully.'**
  String get deviceAddedSuccess;

  /// No description provided for @deviceEditedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device information has been updated successfully.'**
  String get deviceEditedSuccess;

  /// No description provided for @deviceDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Device has been deleted successfully.'**
  String get deviceDeletedSuccess;

  /// No description provided for @deviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceId;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name'**
  String get deviceName;

  /// No description provided for @deviceNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Gas Meter 1'**
  String get deviceNameHint;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @locationHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Seoul, Gangnam'**
  String get locationHint;

  /// No description provided for @installDate.
  ///
  /// In en, this message translates to:
  /// **'Install Date'**
  String get installDate;

  /// No description provided for @lastCommunication.
  ///
  /// In en, this message translates to:
  /// **'Last Communication'**
  String get lastCommunication;

  /// No description provided for @subscriberId.
  ///
  /// In en, this message translates to:
  /// **'Subscriber ID'**
  String get subscriberId;

  /// No description provided for @subscriberNo.
  ///
  /// In en, this message translates to:
  /// **'Subscriber No'**
  String get subscriberNo;

  /// No description provided for @subscriberName.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Name'**
  String get subscriberName;

  /// No description provided for @subscriberNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get subscriberNameHint;

  /// No description provided for @batteryLevel.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get batteryLevel;

  /// No description provided for @totalDevices.
  ///
  /// In en, this message translates to:
  /// **'Total Devices'**
  String get totalDevices;

  /// No description provided for @activeDevices.
  ///
  /// In en, this message translates to:
  /// **'Active Devices'**
  String get activeDevices;

  /// No description provided for @inactiveDevices.
  ///
  /// In en, this message translates to:
  /// **'Inactive Devices'**
  String get inactiveDevices;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @subscriberManagement.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Management'**
  String get subscriberManagement;

  /// No description provided for @subscriberManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscribers and their information.'**
  String get subscriberManagementDescription;

  /// No description provided for @searchSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Search Subscriber'**
  String get searchSubscriber;

  /// No description provided for @searchSubscriberHint.
  ///
  /// In en, this message translates to:
  /// **'Search by ID, name, phone, email, etc.'**
  String get searchSubscriberHint;

  /// No description provided for @addSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Add Subscriber'**
  String get addSubscriber;

  /// No description provided for @editSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Edit Subscriber'**
  String get editSubscriber;

  /// No description provided for @deleteSubscriber.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscriber'**
  String get deleteSubscriber;

  /// No description provided for @deleteSubscriberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete subscriber {name}?'**
  String deleteSubscriberConfirm(Object name);

  /// No description provided for @subscriberAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscriber has been added successfully.'**
  String get subscriberAddedSuccess;

  /// No description provided for @subscriberEditedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscriber information has been updated successfully.'**
  String get subscriberEditedSuccess;

  /// No description provided for @subscriberDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscriber has been deleted successfully.'**
  String get subscriberDeletedSuccess;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 010-1234-5678'**
  String get phoneNumberHint;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. example@email.com'**
  String get emailHint;

  /// No description provided for @contractType.
  ///
  /// In en, this message translates to:
  /// **'Contract Type'**
  String get contractType;

  /// No description provided for @contractTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Standard, Premium'**
  String get contractTypeHint;

  /// No description provided for @registrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get registrationDate;

  /// No description provided for @lastPaymentDate.
  ///
  /// In en, this message translates to:
  /// **'Last Payment Date'**
  String get lastPaymentDate;

  /// No description provided for @deviceCount.
  ///
  /// In en, this message translates to:
  /// **'Device Count'**
  String get deviceCount;

  /// No description provided for @memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get memo;

  /// No description provided for @memoHint.
  ///
  /// In en, this message translates to:
  /// **'Additional notes about the subscriber'**
  String get memoHint;

  /// No description provided for @totalSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Total Subscribers'**
  String get totalSubscribers;

  /// No description provided for @activeSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Active Subscribers'**
  String get activeSubscribers;

  /// No description provided for @inactiveSubscribers.
  ///
  /// In en, this message translates to:
  /// **'Inactive Subscribers'**
  String get inactiveSubscribers;

  /// No description provided for @exportSubscribersToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportSubscribersToExcel;

  /// No description provided for @subscriberList.
  ///
  /// In en, this message translates to:
  /// **'Subscriber List'**
  String get subscriberList;

  /// No description provided for @rowsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get rowsPerPage;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @eventManagement.
  ///
  /// In en, this message translates to:
  /// **'Event Management'**
  String get eventManagement;

  /// No description provided for @dailyDataManagement.
  ///
  /// In en, this message translates to:
  /// **'Daily Data Management'**
  String get dailyDataManagement;

  /// No description provided for @userManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage system users and assign permissions.'**
  String get userManagementDescription;

  /// No description provided for @searchUser.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUser;

  /// No description provided for @searchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email, role, etc.'**
  String get searchUserHint;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get id;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get korean;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Administrator'**
  String get admin;

  /// No description provided for @operator.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get operator;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get user;

  /// No description provided for @installer.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get installer;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @deleteUserConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this user?'**
  String get deleteUserConfirmation;

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete user {name}?'**
  String deleteUserConfirm(Object name);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @userAdded.
  ///
  /// In en, this message translates to:
  /// **'User has been added successfully.'**
  String get userAdded;

  /// No description provided for @userAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User has been added successfully.'**
  String get userAddedSuccess;

  /// No description provided for @userEditedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User information has been updated successfully.'**
  String get userEditedSuccess;

  /// No description provided for @userDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User has been deleted successfully.'**
  String get userDeletedSuccess;

  /// No description provided for @userStatusChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User {name} has been {status}.'**
  String userStatusChangedSuccess(Object name, Object status);

  /// No description provided for @bulkDeviceRegistration.
  ///
  /// In en, this message translates to:
  /// **'Bulk Device Registration'**
  String get bulkDeviceRegistration;

  /// No description provided for @deviceUidListDescription.
  ///
  /// In en, this message translates to:
  /// **'Device UID List\n(Enter one UID per line)'**
  String get deviceUidListDescription;

  /// No description provided for @releaseDate.
  ///
  /// In en, this message translates to:
  /// **'Release Date'**
  String get releaseDate;

  /// No description provided for @installerId.
  ///
  /// In en, this message translates to:
  /// **'Installer ID'**
  String get installerId;

  /// No description provided for @enterAtLeastOneDeviceUid.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least one device UID.'**
  String get enterAtLeastOneDeviceUid;

  /// No description provided for @enterReleaseDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter the release date.'**
  String get enterReleaseDate;

  /// No description provided for @enterInstallerId.
  ///
  /// In en, this message translates to:
  /// **'Please enter the installer ID.'**
  String get enterInstallerId;

  /// No description provided for @devicesRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} devices have been registered.'**
  String devicesRegisteredSuccess(Object count);

  /// No description provided for @deviceRegistrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Device registration failed'**
  String get deviceRegistrationFailed;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @exportToExcel.
  ///
  /// In en, this message translates to:
  /// **'Export to Excel'**
  String get exportToExcel;

  /// No description provided for @deviceUid.
  ///
  /// In en, this message translates to:
  /// **'Device UID'**
  String get deviceUid;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @customerNo.
  ///
  /// In en, this message translates to:
  /// **'Customer No'**
  String get customerNo;

  /// No description provided for @meterId.
  ///
  /// In en, this message translates to:
  /// **'Meter ID'**
  String get meterId;

  /// No description provided for @lastCount.
  ///
  /// In en, this message translates to:
  /// **'Last Count'**
  String get lastCount;

  /// No description provided for @lastAccess.
  ///
  /// In en, this message translates to:
  /// **'Last Access'**
  String get lastAccess;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @deviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInfo;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInfo;

  /// No description provided for @deviceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Device not found'**
  String get deviceNotFound;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @excelFileSaved.
  ///
  /// In en, this message translates to:
  /// **'Excel file has been saved.'**
  String get excelFileSaved;

  /// No description provided for @excelFileSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving Excel file: {error}'**
  String excelFileSaveError(Object error);

  /// No description provided for @shareHouse.
  ///
  /// In en, this message translates to:
  /// **'Share House'**
  String get shareHouse;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @subscriberClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get subscriberClass;

  /// No description provided for @inOutdoor.
  ///
  /// In en, this message translates to:
  /// **'In/Outdoor'**
  String get inOutdoor;

  /// No description provided for @bindDeviceId.
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get bindDeviceId;

  /// No description provided for @bindDate.
  ///
  /// In en, this message translates to:
  /// **'Binding Date'**
  String get bindDate;

  /// No description provided for @deviceList.
  ///
  /// In en, this message translates to:
  /// **'Device List'**
  String get deviceList;

  /// No description provided for @installerPageDescription.
  ///
  /// In en, this message translates to:
  /// **'Access installer-related functions.'**
  String get installerPageDescription;

  /// No description provided for @deviceSearch.
  ///
  /// In en, this message translates to:
  /// **'Device Search'**
  String get deviceSearch;

  /// No description provided for @deviceSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by Device UID, Meter ID, etc.'**
  String get deviceSearchHint;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @statusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get statusNormal;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get statusWarning;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @scanWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with Camera'**
  String get scanWithCamera;

  /// No description provided for @imageCaptured.
  ///
  /// In en, this message translates to:
  /// **'Image captured: {path}'**
  String imageCaptured(Object path);

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error: {error}'**
  String cameraError(Object error);

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required.'**
  String get cameraPermissionDenied;

  /// No description provided for @cameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is permanently denied. Please enable it in settings.'**
  String get cameraPermissionPermanentlyDenied;

  /// No description provided for @initialValue.
  ///
  /// In en, this message translates to:
  /// **'Initial Meter Value'**
  String get initialValue;

  /// No description provided for @dataInterval.
  ///
  /// In en, this message translates to:
  /// **'Data Transmission Interval'**
  String get dataInterval;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @completeInstallation.
  ///
  /// In en, this message translates to:
  /// **'Complete Installation'**
  String get completeInstallation;

  /// No description provided for @completeUninstallation.
  ///
  /// In en, this message translates to:
  /// **'Complete Uninstallation'**
  String get completeUninstallation;

  /// No description provided for @installationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Installation completed successfully.'**
  String get installationCompleted;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @enterComment.
  ///
  /// In en, this message translates to:
  /// **'Enter installation related comments'**
  String get enterComment;

  /// No description provided for @r1hour.
  ///
  /// In en, this message translates to:
  /// **'1 Hour'**
  String get r1hour;

  /// No description provided for @r2hours.
  ///
  /// In en, this message translates to:
  /// **'2 Hours'**
  String get r2hours;

  /// No description provided for @r3hours.
  ///
  /// In en, this message translates to:
  /// **'3 Hours'**
  String get r3hours;

  /// No description provided for @r6hours.
  ///
  /// In en, this message translates to:
  /// **'6 Hours'**
  String get r6hours;

  /// No description provided for @r12hours.
  ///
  /// In en, this message translates to:
  /// **'12 Hours'**
  String get r12hours;

  /// No description provided for @r1day.
  ///
  /// In en, this message translates to:
  /// **'1 Day'**
  String get r1day;

  /// No description provided for @selectInterval.
  ///
  /// In en, this message translates to:
  /// **'Select Interval'**
  String get selectInterval;

  /// No description provided for @scanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Code scan completed: {code}'**
  String scanCompleted(Object code);

  /// No description provided for @qrScanTitle.
  ///
  /// In en, this message translates to:
  /// **'QR/Barcode Scan'**
  String get qrScanTitle;

  /// No description provided for @toggleFlash.
  ///
  /// In en, this message translates to:
  /// **'Toggle Flash'**
  String get toggleFlash;

  /// No description provided for @switchCamera.
  ///
  /// In en, this message translates to:
  /// **'Switch Camera'**
  String get switchCamera;

  /// No description provided for @scanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan a barcode or QR code'**
  String get scanInstructions;

  /// No description provided for @subscriberInfo.
  ///
  /// In en, this message translates to:
  /// **'Subscriber Information'**
  String get subscriberInfo;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @subscriberNotFound.
  ///
  /// In en, this message translates to:
  /// **'Subscriber not found'**
  String get subscriberNotFound;

  /// No description provided for @addressInfo.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get addressInfo;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @contractInfo.
  ///
  /// In en, this message translates to:
  /// **'Contract Information'**
  String get contractInfo;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full Address'**
  String get fullAddress;

  /// No description provided for @province.
  ///
  /// In en, this message translates to:
  /// **'Province'**
  String get province;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @detailAddress.
  ///
  /// In en, this message translates to:
  /// **'Detail Address'**
  String get detailAddress;

  /// No description provided for @apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get apartment;

  /// No description provided for @dbViewer.
  ///
  /// In en, this message translates to:
  /// **'DB Viewer(for developing)'**
  String get dbViewer;

  /// No description provided for @dbViewerDescription.
  ///
  /// In en, this message translates to:
  /// **'View database table contents. For development and debugging purposes only.'**
  String get dbViewerDescription;

  /// No description provided for @installationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Installation Confirmation'**
  String get installationConfirmation;

  /// No description provided for @pressButtonForFiveSeconds.
  ///
  /// In en, this message translates to:
  /// **'Press the button for 5 seconds. When E1 message appears on the display, communication will start'**
  String get pressButtonForFiveSeconds;

  /// No description provided for @communicationWillStartAfterTenSeconds.
  ///
  /// In en, this message translates to:
  /// **'Communication status check will start 10 seconds after page load.\nWhen communication between the device and server starts, the status will be displayed below.'**
  String get communicationWillStartAfterTenSeconds;

  /// No description provided for @secondsBeforeCommunication.
  ///
  /// In en, this message translates to:
  /// **' seconds before communication starts...'**
  String get secondsBeforeCommunication;

  /// No description provided for @lastCommunicationTime.
  ///
  /// In en, this message translates to:
  /// **'Last Communication Time'**
  String get lastCommunicationTime;

  /// No description provided for @null_value.
  ///
  /// In en, this message translates to:
  /// **'NULL'**
  String get null_value;

  /// No description provided for @checkingCommunicationStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking communication status...'**
  String get checkingCommunicationStatus;

  /// No description provided for @waitingForCommunication.
  ///
  /// In en, this message translates to:
  /// **'Waiting for communication'**
  String get waitingForCommunication;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **' seconds'**
  String get seconds;

  /// No description provided for @deviceCommunicatingSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Device is successfully communicating with the server!'**
  String get deviceCommunicatingSuccessfully;

  /// No description provided for @deviceCommunicationProblem.
  ///
  /// In en, this message translates to:
  /// **'Communication between device and server is not smooth. Please check the device status.'**
  String get deviceCommunicationProblem;

  /// No description provided for @invalidCommunicationTimeInfo.
  ///
  /// In en, this message translates to:
  /// **'No valid communication time information.'**
  String get invalidCommunicationTimeInfo;

  /// No description provided for @cannotGetDeviceInfo.
  ///
  /// In en, this message translates to:
  /// **'Cannot retrieve device information.'**
  String get cannotGetDeviceInfo;

  /// No description provided for @communicationError.
  ///
  /// In en, this message translates to:
  /// **'Error during server communication'**
  String get communicationError;

  /// No description provided for @connectAnotherDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect Another Device'**
  String get connectAnotherDevice;

  /// No description provided for @disconnectDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Device'**
  String get disconnectDevice;

  /// No description provided for @disconnectingDevice.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting device...'**
  String get disconnectingDevice;

  /// No description provided for @deviceDisconnectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Device has been disconnected successfully'**
  String get deviceDisconnectedSuccessfully;

  /// No description provided for @deviceDisconnectionError.
  ///
  /// In en, this message translates to:
  /// **'Error disconnecting device'**
  String get deviceDisconnectionError;

  /// No description provided for @pendingUserApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending User Approval'**
  String get pendingUserApproval;

  /// No description provided for @noPendingUsers.
  ///
  /// In en, this message translates to:
  /// **'No pending users'**
  String get noPendingUsers;

  /// No description provided for @dbName.
  ///
  /// In en, this message translates to:
  /// **'DB Name'**
  String get dbName;

  /// No description provided for @enterUserDbName.
  ///
  /// In en, this message translates to:
  /// **'Enter user\'s database name'**
  String get enterUserDbName;

  /// No description provided for @activationStatus.
  ///
  /// In en, this message translates to:
  /// **'Activation Status'**
  String get activationStatus;

  /// No description provided for @userApproved.
  ///
  /// In en, this message translates to:
  /// **'User has been approved'**
  String get userApproved;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ko': return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
