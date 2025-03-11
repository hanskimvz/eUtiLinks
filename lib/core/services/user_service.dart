import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../constants/api_constants.dart';
import 'auth_service.dart';
// import '../models/user_model.dart';

/// 사용자 관련 API 호출을 담당하는 서비스 클래스
class UserService {
  final String baseUrl;

  UserService({required this.baseUrl}) {
    _initService();
  }

  Future<void> _initService() async {
    await AuthService.initAuthData();
  }

  Map<String, String> get authData => AuthService.authData;

  /// 사용자 목록을 가져옵니다.
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final tableHead = [
        'code',
        'ID',
        'email',
        'name',
        'lang',
        'role',
        'groups',
        'regdate',
        'flag',
        'comment',
      ];

      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'list',
          'format': 'json',
          'fields': tableHead,
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          final List<Map<String, dynamic>> users = [];

          // 서버에서 받은 사용자 데이터를 처리
          if (data['data'] != null && data['data'] is List) {
            for (var user in data['data']) {
              users.add({
                'id': user['code'] ?? '',
                'username': user['ID'] ?? '',
                'name': user['name'] ?? '',
                'email': user['email'] ?? '',
                'role': user['role'] ?? '',
                'lastLogin': user['regdate'] ?? '-',
                'status': user['flag'] == true ? 'active' : 'inactive',
                'lang': user['lang'] ?? 'kor',
                'comment': user['comment'] ?? '',
              });
            }
          }

          return users;
        } else {
          throw Exception('사용자 데이터를 가져오는데 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  /// 미승인 사용자 목록을 가져옵니다.
  Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final tableHead = ['code', 'ID', 'email', 'name', 'regdate', 'comment'];

      final response = await http.post(
        Uri.parse('$baseUrl/api/floating_user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'list',
          'format': 'json',
          'fields': tableHead,
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          final List<Map<String, dynamic>> pendingUsers = [];

          // 서버에서 받은 미승인 사용자 데이터를 처리
          if (data['data'] != null && data['data'] is List) {
            for (var user in data['data']) {
              pendingUsers.add({
                'id': user['code'] ?? '',
                'username': user['ID'] ?? '',
                'name': user['name'] ?? '',
                'email': user['email'] ?? '',
                'regdate': user['regdate'] ?? '-',
                'comment': user['comment'] ?? '',
              });
            }
          }

          return pendingUsers;
        } else {
          throw Exception('미승인 사용자 데이터를 가져오는데 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  /// 사용자를 추가합니다.
  Future<bool> addUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'add',
          'format': 'json',
          ...authData,
          'data': {
            'ID': userData['username'],
            'name': userData['name'],
            'email': userData['email'],
            'password': userData['password'],
            'role': userData['role'],
            'lang': userData['lang'],
            'flag': userData['status'] == 'active',
            'comment': userData['comment'] ?? '',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          throw Exception('사용자 추가에 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  /// 사용자 정보를 수정합니다.
  Future<bool> updateUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'modify',
          'format': 'json',
          ...authData,
          'data': {
            'code': userData['id'],
            'ID': userData['username'],
            'name': userData['name'],
            'email': userData['email'],
            'user_role': userData['role'],
            'lang': userData['lang'] ?? 'kor',
            'groups': userData['groups'] ?? '',
            'flag': userData['status'] == 'active',
            'comment': userData['comment'] ?? '',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 200) {
          return true;
        } else {
          throw Exception('사용자 수정에 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  /// 사용자를 삭제합니다.
  Future<bool> deleteUser(String userCode, String userID) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'format': 'json',
          ...authData,
          'data': {'code': userCode, 'ID': userID},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          throw Exception('사용자 삭제에 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }

  /// 미승인 사용자를 승인합니다.
  Future<bool> approveUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'approve',
          'format': 'json',
          ...authData,
          'code': userData['id'],
          'ID': userData['username'],
          'db_name': userData['db_name'] ?? '',
          'flag': userData['flag'] ?? true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 200) {
          return true;
        } else {
          throw Exception('사용자 승인에 실패했습니다. 코드: ${data['code']}');
        }
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('오류 발생: $e');
    }
  }
}
