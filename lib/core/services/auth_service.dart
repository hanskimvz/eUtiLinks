import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../constants/api_constants.dart';

/// 인증 관련 기능을 제공하는 서비스 클래스
class AuthService {
  static Map<String, String> authData = {};

  static Future<void> initAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final levelValue = int.tryParse(prefs.getString('_level') ?? '0') ?? 0;

      authData = {
        'db_name': prefs.getString('_db_name') ?? '',
        'login_id': prefs.getString('_login_id') ?? '',
        'role': prefs.getString('_role') ?? '',
        'userseq': prefs.getString('_userseq') ?? '',
        'level': levelValue.toString(),
      };
    } catch (e) {
      stdout.writeln('인증 데이터 초기화 오류: $e');
    }
  }

  static Future<void> refreshAuthData() async {
    await initAuthData();
  }

  static Map<String, String> getAuthData() {
    return authData;
  }

  // 저장 키
  static const String _loginIdKey = '_login_id';
  static const String _dbNameKey = '_db_name';
  static const String _roleKey = '_role';
  static const String _nameKey = '_name';
  static const String _userseqKey = '_userseq';
  static const String _levelKey = '_level';

  /// 사용자 로그인을 처리합니다.
  static Future<Map<String, dynamic>> login(String id, String password) async {
    final url = '${ApiConstants.serverUrl}/api/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': id, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['result'] == 'success') {
          final userInfo = data['data'];

          // 사용자 정보 저장
          await saveUserInfo(
            id: userInfo['id'] ?? id,
            dbName: userInfo['db_name'] ?? '',
            role: userInfo['role'] ?? '',
            name: userInfo['name'] ?? '',
            userseq: userInfo['userseq']?.toString() ?? '',
            level: int.parse(userInfo['level'] ?? '0'),
          );

          // 자동 로그인을 위해 아이디와 비밀번호 저장
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_id', id);
          await prefs.setString('saved_password', password);

          return userInfo;
        } else {
          throw Exception(data['message'] ?? '로그인에 실패했습니다.');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// 사용자가 로그인되어 있는지 확인합니다.
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loginId = prefs.getString(_loginIdKey);
    return loginId != null && loginId.isNotEmpty;
  }

  /// 현재 로그인된 사용자 정보를 가져옵니다.
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loginId = prefs.getString(_loginIdKey);

    if (loginId == null || loginId.isEmpty) {
      return null;
    }

    return {
      'id': loginId,
      'db_name': prefs.getString(_dbNameKey) ?? '',
      'role': prefs.getString(_roleKey) ?? '',
      'name': prefs.getString(_nameKey) ?? '',
      'userseq': prefs.getString(_userseqKey) ?? '',
      'level': int.tryParse(prefs.getString(_levelKey) ?? '0') ?? 0,
    };
  }

  /// 사용자 로그인 정보를 저장합니다.
  static Future<void> saveUserInfo({
    required String id,
    required String dbName,
    required String role,
    required String name,
    required String userseq,
    required int level,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_loginIdKey, id);
    await prefs.setString(_dbNameKey, dbName);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_userseqKey, userseq);
    await prefs.setString(_levelKey, level.toString());
  }

  /// 로그아웃 처리를 합니다.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginIdKey);
    await prefs.remove(_dbNameKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_userseqKey);
    await prefs.remove(_levelKey);

    // 사용자 이름은 'remember me' 옵션이 켜져 있을 경우 유지
    // await prefs.remove('saved_username');
  }

  /// 사용자 권한을 확인합니다.
  static Future<bool> hasRole(String requiredRole) async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_roleKey);
    return role == requiredRole;
  }

  /// 관리자 권한을 가지고 있는지 확인합니다.
  static Future<bool> isAdmin() async {
    return hasRole('admin');
  }

  /// 사용자의 권한 레벨을 확인합니다.
  static Future<bool> hasPermissionLevel(int requiredLevel) async {
    final prefs = await SharedPreferences.getInstance();
    final levelStr = prefs.getString(_levelKey);
    final level = int.tryParse(levelStr ?? '0') ?? 0;
    return level >= requiredLevel;
  }
}
