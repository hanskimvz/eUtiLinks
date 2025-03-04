import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'api_constants.dart';

/// 서버 설정을 저장하고 불러오는 클래스
/// 
/// 웹 환경에서는 쿠키를, 모바일 환경에서는 SharedPreferences를 사용합니다.
class ServerConfig {
  // 저장 키
  static const String _serverAddressKey = 'server_address';
  static const String _serverPortKey = 'server_port';
  static const String _useCustomServerKey = 'use_custom_server';
  static const String _useDevServerKey = 'use_dev_server';
  
  /// 현재 서버 설정을 저장합니다.
  static Future<void> saveCurrentConfig() async {
    final address = ApiConstants.serverAddress;
    final port = ApiConstants.serverPort;
    final isCustom = ApiConstants.isCustomServer;
    final isDev = ApiConstants.isDevServer;
    
    if (kIsWeb) {
      // 웹에서는 localStorage 사용 (쿠키 대신)
      await _saveToLocalStorage(_serverAddressKey, address);
      await _saveToLocalStorage(_serverPortKey, port.toString());
      await _saveToLocalStorage(_useCustomServerKey, isCustom.toString());
      await _saveToLocalStorage(_useDevServerKey, isDev.toString());
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_serverAddressKey, address);
      await prefs.setInt(_serverPortKey, port);
      await prefs.setBool(_useCustomServerKey, isCustom);
      await prefs.setBool(_useDevServerKey, isDev);
    }
  }
  
  /// 저장된 서버 설정을 불러옵니다.
  static Future<void> loadSavedConfig() async {
    if (kIsWeb) {
      final address = await _getFromLocalStorage(_serverAddressKey);
      final portStr = await _getFromLocalStorage(_serverPortKey);
      final isCustomStr = await _getFromLocalStorage(_useCustomServerKey);
      final isDevStr = await _getFromLocalStorage(_useDevServerKey);
      
      if (address != null && portStr != null) {
        final port = int.tryParse(portStr);
        if (port != null) {
          final isCustom = isCustomStr == 'true';
          final isDev = isDevStr == 'true';
          
          if (isCustom) {
            ApiConstants.setCustomServer(address, port);
          } else if (isDev) {
            ApiConstants.useDevEnvironment();
          } else {
            ApiConstants.useProdEnvironment();
          }
        }
      }
    } else {
      final prefs = await SharedPreferences.getInstance();
      final address = prefs.getString(_serverAddressKey);
      final port = prefs.getInt(_serverPortKey);
      final isCustom = prefs.getBool(_useCustomServerKey);
      final isDev = prefs.getBool(_useDevServerKey);
      
      if (address != null && port != null && isCustom != null && isDev != null) {
        if (isCustom) {
          ApiConstants.setCustomServer(address, port);
        } else if (isDev) {
          ApiConstants.useDevEnvironment();
        } else {
          ApiConstants.useProdEnvironment();
        }
      }
    }
  }
  
  /// 서버 설정을 초기화합니다.
  static Future<void> resetConfig() async {
    if (kIsWeb) {
      await _removeFromLocalStorage(_serverAddressKey);
      await _removeFromLocalStorage(_serverPortKey);
      await _removeFromLocalStorage(_useCustomServerKey);
      await _removeFromLocalStorage(_useDevServerKey);
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_serverAddressKey);
      await prefs.remove(_serverPortKey);
      await prefs.remove(_useCustomServerKey);
      await prefs.remove(_useDevServerKey);
    }
    
    // 기본 설정으로 복원
    ApiConstants.useDevEnvironment();
  }
  
  // localStorage에 저장 (웹 환경)
  static Future<void> _saveToLocalStorage(String key, String value) async {
    if (kIsWeb) {
      try {
        // HTML5 localStorage 사용 (shared_preferences 내부 구현과 유사)
        await _invokeLocalStorage('setItem', [key, value]);
      } catch (e) {
        // print('localStorage 저장 오류: $e');
      }
    }
  }
  
  // localStorage에서 가져오기 (웹 환경)
  static Future<String?> _getFromLocalStorage(String key) async {
    if (kIsWeb) {
      try {
        return await _invokeLocalStorage('getItem', [key]) as String?;
      } catch (e) {
        // print('localStorage 가져오기 오류: $e');
      }
    }
    return null;
  }
  
  // localStorage에서 삭제 (웹 환경)
  static Future<void> _removeFromLocalStorage(String key) async {
    if (kIsWeb) {
      try {
        await _invokeLocalStorage('removeItem', [key]);
      } catch (e) {
        // print('localStorage 삭제 오류: $e');
      }
    }
  }
  
  // JavaScript localStorage 호출 (웹 환경)
  static Future<dynamic> _invokeLocalStorage(String method, List<dynamic> args) async {
    if (kIsWeb) {
      try {
        // 플랫폼 채널을 통해 JavaScript 호출
        // 실제 구현은 shared_preferences 웹 구현과 유사
        return await SharedPreferences.getInstance().then((prefs) {
          if (method == 'setItem') {
            return prefs.setString(args[0], args[1]);
          } else if (method == 'getItem') {
            return prefs.getString(args[0]);
          } else if (method == 'removeItem') {
            return prefs.remove(args[0]);
          }
          return null;
        });
      } catch (e) {
        // print('localStorage 호출 오류: $e');
        return null;
      }
    }
    return null;
  }
} 