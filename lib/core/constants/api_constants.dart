// API 관련 상수를 정의하는 파일입니다.
// 서버 주소, 포트 및 API 엔드포인트를 관리합니다.

/// API 관련 상수를 관리하는 클래스
/// 
/// 사용 예시:
/// ```dart
/// // 서버 URL 가져오기
/// final serverUrl = ApiConstants.serverUrl;
/// 
/// // API 엔드포인트 URL 생성
/// final loginUrl = ApiConstants.getApiUrl(ApiConstants.loginEndpoint);
/// 
/// // 서버 주소와 포트 개별적으로 사용
/// print('서버 주소: ${ApiConstants.serverAddress}');
/// print('서버 포트: ${ApiConstants.serverPort}');
/// ```
class ApiConstants {
  // 서버 주소 및 포트
  static const String serverAddress = 'http://192.168.1.252:5100';
  // static const String serverAddress = 'https://192.168.1.252:5100';
  static const int serverPort = 5100;
  
  // 서버 주소 (운영 환경)
  // static const String prodServerAddress = 'https://api.example.com:443';
  static const String prodServerAddress = 'http://192.168.1.252:5100';
  static const int prodServerPort = 5100;
  
  // 현재 사용할 서버 환경 (개발/운영)
  static bool _useDevServer = true;
  
  // 사용자 정의 서버 설정
  static String? _customServerAddress;
  static int? _customServerPort;
  static bool _useCustomServer = false;
  
  // 현재 환경에 따른 서버 주소
  static String get currentServerAddress {
    if (_useCustomServer && _customServerAddress != null) {
      return _customServerAddress!;
    }
    return _useDevServer ? serverAddress : prodServerAddress;
  }
  
  static int get currentServerPort {
    if (_useCustomServer && _customServerPort != null) {
      return _customServerPort!;
    }
    return _useDevServer ? serverPort : prodServerPort;
  }
  
  // 전체 서버 URL
  static String get serverUrl => currentServerAddress;
  
  // API 엔드포인트
  static const String loginEndpoint = '/api/login';
  static const String logoutEndpoint = '/api/logout';
  static const String deviceDataEndpoint = '/api/device/data';
  static const String usageDataEndpoint = '/api/usage/data';
  static const String anomalyDataEndpoint = '/api/anomaly/data';
  
  // 전체 API URL 생성 메서드
  static String getApiUrl(String endpoint) {
    return '$serverUrl$endpoint';
  }
  
  /// 개발 서버 사용 여부 확인
  static bool get isDevServer => _useDevServer;
  
  /// 사용자 정의 서버 사용 여부 확인
  static bool get isCustomServer => _useCustomServer;
  
  /// 개발 서버로 설정
  static void useDevEnvironment() {
    _useDevServer = true;
    _useCustomServer = false;
  }
  
  /// 운영 서버로 설정
  static void useProdEnvironment() {
    _useDevServer = false;
    _useCustomServer = false;
  }
  
  /// 사용자 정의 서버 설정
  /// 
  /// 예시:
  /// ```dart
  /// ApiConstants.setCustomServer('192.168.0.100', 8080);
  /// ```
  static void setCustomServer(String address, int port) {
    // HTTPS 프로토콜 확인 및 추가
    String finalAddress = address;
    if (!finalAddress.startsWith('https://') && !finalAddress.startsWith('http://')) {
      finalAddress = 'https://$finalAddress';
    }
    
    _customServerAddress = finalAddress;
    _customServerPort = port;
    _useCustomServer = true;
  }
  
  /// 사용자 정의 서버 설정 초기화
  static void resetCustomServer() {
    _customServerAddress = null;
    _customServerPort = null;
    _useCustomServer = false;
  }
} 