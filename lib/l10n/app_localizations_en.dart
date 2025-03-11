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
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

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
  String serverConnectionError(Object error) {
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
  String get installerMenu => 'Installer';

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
  String get systemSettingsDescription => 'Manage system settings.';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get serverSettings => 'Server Settings';

  @override
  String get serverSettingsDescription => 'Configure the server that the application will connect to.';

  @override
  String get selectServerEnvironment => 'Select Server Environment';

  @override
  String get devServer => 'Development Server';

  @override
  String get prodServer => 'Production Server';

  @override
  String get address => 'Address';

  @override
  String get useCustomServer => 'Use Custom Server';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get serverAddressHint => 'e.g. 192.168.1.100';

  @override
  String get serverPort => 'Server Port';

  @override
  String get serverPortHint => 'e.g. 5100';

  @override
  String get reset => 'Reset';

  @override
  String get serverAddressRequired => 'Please enter a server address.';

  @override
  String get validPortRequired => 'Please enter a valid port number (1-65535).';

  @override
  String get serverSettingsSaved => 'Server settings have been saved.';

  @override
  String get serverSettingsReset => 'Server settings have been reset.';

  @override
  String get error => 'Error';

  @override
  String get permissionManagement => 'Permission Management';

  @override
  String get userManagement => 'User Management';

  @override
  String get locationManagement => 'Location Management';

  @override
  String get locationManagementDescription => 'Manage locations of devices and subscribers';

  @override
  String get deviceManagement => 'Device Management';

  @override
  String get deviceManagementDescription => 'Manage devices and monitor their status.';

  @override
  String get searchDevice => 'Search Devices';

  @override
  String get searchDeviceHint => 'Search by device ID, name, location, etc.';

  @override
  String get addDevice => 'Add Device';

  @override
  String get editDevice => 'Edit Device';

  @override
  String get deleteDevice => 'Delete Device';

  @override
  String deleteDeviceConfirm(Object name) {
    return 'Are you sure you want to delete device $name?';
  }

  @override
  String get deviceAddedSuccess => 'Device has been added successfully.';

  @override
  String get deviceEditedSuccess => 'Device information has been updated successfully.';

  @override
  String get deviceDeletedSuccess => 'Device has been deleted successfully.';

  @override
  String get deviceId => 'Device ID';

  @override
  String get deviceName => 'Device Name';

  @override
  String get deviceNameHint => 'e.g. Gas Meter 1';

  @override
  String get type => 'Type';

  @override
  String get location => 'Location';

  @override
  String get locationHint => 'e.g. Seoul, Gangnam';

  @override
  String get installDate => 'Install Date';

  @override
  String get lastCommunication => 'Last Communication';

  @override
  String get subscriberId => 'Subscriber ID';

  @override
  String get subscriberNo => 'Subscriber No';

  @override
  String get subscriberName => 'Subscriber Name';

  @override
  String get subscriberNameHint => 'e.g. John Doe';

  @override
  String get batteryLevel => 'Battery Level';

  @override
  String get totalDevices => 'Total Devices';

  @override
  String get activeDevices => 'Active Devices';

  @override
  String get inactiveDevices => 'Inactive Devices';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get subscriberManagement => 'Subscriber Management';

  @override
  String get subscriberManagementDescription => 'Manage subscribers and their information.';

  @override
  String get searchSubscriber => 'Search Subscriber';

  @override
  String get searchSubscriberHint => 'Search by ID, name, phone, email, etc.';

  @override
  String get addSubscriber => 'Add Subscriber';

  @override
  String get editSubscriber => 'Edit Subscriber';

  @override
  String get deleteSubscriber => 'Delete Subscriber';

  @override
  String deleteSubscriberConfirm(Object name) {
    return 'Are you sure you want to delete subscriber $name?';
  }

  @override
  String get subscriberAddedSuccess => 'Subscriber has been added successfully.';

  @override
  String get subscriberEditedSuccess => 'Subscriber information has been updated successfully.';

  @override
  String get subscriberDeletedSuccess => 'Subscriber has been deleted successfully.';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phoneNumberHint => 'e.g. 010-1234-5678';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'e.g. example@email.com';

  @override
  String get contractType => 'Contract Type';

  @override
  String get contractTypeHint => 'e.g. Standard, Premium';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get lastPaymentDate => 'Last Payment Date';

  @override
  String get deviceCount => 'Device Count';

  @override
  String get memo => 'Memo';

  @override
  String get memoHint => 'Additional notes about the subscriber';

  @override
  String get totalSubscribers => 'Total Subscribers';

  @override
  String get activeSubscribers => 'Active Subscribers';

  @override
  String get inactiveSubscribers => 'Inactive Subscribers';

  @override
  String get exportSubscribersToExcel => 'Export to Excel';

  @override
  String get subscriberList => 'Subscriber List';

  @override
  String get rowsPerPage => 'Rows per page';

  @override
  String get status => 'Status';

  @override
  String get actions => 'Actions';

  @override
  String get eventManagement => 'Event Management';

  @override
  String get dailyDataManagement => 'Daily Data Management';

  @override
  String get userManagementDescription => 'Manage system users and assign permissions.';

  @override
  String get searchUser => 'Search Users';

  @override
  String get searchUserHint => 'Search by name, email, role, etc.';

  @override
  String get addUser => 'Add User';

  @override
  String get refresh => 'Refresh';

  @override
  String get code => 'Code';

  @override
  String get id => 'ID';

  @override
  String get name => 'Name';

  @override
  String get language => 'Language';

  @override
  String get role => 'Role';

  @override
  String get korean => 'Korean';

  @override
  String get english => 'English';

  @override
  String get chinese => 'Chinese';

  @override
  String get admin => 'Administrator';

  @override
  String get operator => 'Operator';

  @override
  String get user => 'Regular User';

  @override
  String get installer => 'Installer';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get deleteUserConfirmation => 'Are you sure you want to delete this user?';

  @override
  String deleteUserConfirm(Object name) {
    return 'Are you sure you want to delete user $name?';
  }

  @override
  String get save => 'Save';

  @override
  String get userAdded => 'User has been added successfully.';

  @override
  String get userAddedSuccess => 'User has been added successfully.';

  @override
  String get userEditedSuccess => 'User information has been updated successfully.';

  @override
  String get userDeletedSuccess => 'User has been deleted successfully.';

  @override
  String userStatusChangedSuccess(Object name, Object status) {
    return 'User $name has been $status.';
  }

  @override
  String get bulkDeviceRegistration => 'Bulk Device Registration';

  @override
  String get deviceUidListDescription => 'Device UID List\n(Enter one UID per line)';

  @override
  String get releaseDate => 'Release Date';

  @override
  String get installerId => 'Installer ID';

  @override
  String get enterAtLeastOneDeviceUid => 'Please enter at least one device UID.';

  @override
  String get enterReleaseDate => 'Please enter the release date.';

  @override
  String get enterInstallerId => 'Please enter the installer ID.';

  @override
  String devicesRegisteredSuccess(Object count) {
    return '$count devices have been registered.';
  }

  @override
  String get deviceRegistrationFailed => 'Device registration failed';

  @override
  String get register => 'Register';

  @override
  String get exportToExcel => 'Export to Excel';

  @override
  String get deviceUid => 'Device UID';

  @override
  String get customerName => 'Customer Name';

  @override
  String get customerNo => 'Customer No';

  @override
  String get meterId => 'Meter ID';

  @override
  String get lastCount => 'Last Count';

  @override
  String get lastAccess => 'Last Access';

  @override
  String get battery => 'Battery';

  @override
  String get deviceInfo => 'Device Information';

  @override
  String get basicInfo => 'Basic Information';

  @override
  String get customerInfo => 'Customer Information';

  @override
  String get deviceNotFound => 'Device not found';

  @override
  String get welcome => 'Welcome';

  @override
  String get excelFileSaved => 'Excel file has been saved.';

  @override
  String excelFileSaveError(Object error) {
    return 'Error saving Excel file: $error';
  }

  @override
  String get shareHouse => 'Share House';

  @override
  String get category => 'Category';

  @override
  String get subscriberClass => 'Class';

  @override
  String get inOutdoor => 'In/Outdoor';

  @override
  String get bindDeviceId => 'Device ID';

  @override
  String get bindDate => 'Binding Date';

  @override
  String get deviceList => 'Device List';

  @override
  String get installerPageDescription => 'Access installer-related functions.';

  @override
  String get deviceSearch => 'Device Search';

  @override
  String get deviceSearchHint => 'Search by Device UID, Meter ID, etc.';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get statusNormal => 'Normal';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusWarning => 'Warning';

  @override
  String get statusError => 'Error';

  @override
  String get scanWithCamera => 'Scan with Camera';

  @override
  String imageCaptured(Object path) {
    return 'Image captured: $path';
  }

  @override
  String cameraError(Object error) {
    return 'Camera error: $error';
  }

  @override
  String get cameraPermissionDenied => 'Camera permission is required.';

  @override
  String get cameraPermissionPermanentlyDenied => 'Camera permission is permanently denied. Please enable it in settings.';

  @override
  String get initialValue => 'Initial Meter Value';

  @override
  String get dataInterval => 'Data Transmission Interval';

  @override
  String get comment => 'Comment';

  @override
  String get completeInstallation => 'Complete Installation';

  @override
  String get completeUninstallation => 'Complete Uninstallation';

  @override
  String get installationCompleted => 'Installation completed successfully.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get enterComment => 'Enter installation related comments';

  @override
  String get r1hour => '1 Hour';

  @override
  String get r2hours => '2 Hours';

  @override
  String get r3hours => '3 Hours';

  @override
  String get r6hours => '6 Hours';

  @override
  String get r12hours => '12 Hours';

  @override
  String get r1day => '1 Day';

  @override
  String get selectInterval => 'Select Interval';

  @override
  String scanCompleted(Object code) {
    return 'Code scan completed: $code';
  }

  @override
  String get qrScanTitle => 'QR/Barcode Scan';

  @override
  String get toggleFlash => 'Toggle Flash';

  @override
  String get switchCamera => 'Switch Camera';

  @override
  String get scanInstructions => 'Scan a barcode or QR code';

  @override
  String get subscriberInfo => 'Subscriber Information';

  @override
  String get retry => 'Retry';

  @override
  String get subscriberNotFound => 'Subscriber not found';

  @override
  String get addressInfo => 'Address Information';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get contractInfo => 'Contract Information';

  @override
  String get fullAddress => 'Full Address';

  @override
  String get province => 'Province';

  @override
  String get city => 'City';

  @override
  String get district => 'District';

  @override
  String get detailAddress => 'Detail Address';

  @override
  String get apartment => 'Apartment';

  @override
  String get dbViewer => 'DB Viewer(for developing)';

  @override
  String get dbViewerDescription => 'View database table contents. For development and debugging purposes only.';

  @override
  String get installationConfirmation => 'Installation Confirmation';

  @override
  String get pressButtonForFiveSeconds => 'Press the button for 5 seconds. When E1 message appears on the display, communication will start';

  @override
  String get communicationWillStartAfterTenSeconds => 'Communication status check will start 10 seconds after page load.\nWhen communication between the device and server starts, the status will be displayed below.';

  @override
  String get secondsBeforeCommunication => ' seconds before communication starts...';

  @override
  String get lastCommunicationTime => 'Last Communication Time';

  @override
  String get null_value => 'NULL';

  @override
  String get checkingCommunicationStatus => 'Checking communication status...';

  @override
  String get waitingForCommunication => 'Waiting for communication';

  @override
  String get seconds => ' seconds';

  @override
  String get deviceCommunicatingSuccessfully => 'Device is successfully communicating with the server!';

  @override
  String get deviceCommunicationProblem => 'Communication between device and server is not smooth. Please check the device status.';

  @override
  String get invalidCommunicationTimeInfo => 'No valid communication time information.';

  @override
  String get cannotGetDeviceInfo => 'Cannot retrieve device information.';

  @override
  String get communicationError => 'Error during server communication';

  @override
  String get connectAnotherDevice => 'Connect Another Device';

  @override
  String get disconnectDevice => 'Disconnect Device';

  @override
  String get disconnectingDevice => 'Disconnecting device...';

  @override
  String get deviceDisconnectedSuccessfully => 'Device has been disconnected successfully';

  @override
  String get deviceDisconnectionError => 'Error disconnecting device';

  @override
  String get pendingUserApproval => 'Pending User Approval';

  @override
  String get noPendingUsers => 'No pending users';

  @override
  String get dbName => 'DB Name';

  @override
  String get enterUserDbName => 'Enter user\'s database name';

  @override
  String get activationStatus => 'Activation Status';

  @override
  String get userApproved => 'User has been approved';

  @override
  String get approve => 'Approve';
}
