import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device_model.dart';
import 'auth_service.dart';

class DeviceService {
  final String baseUrl;

  DeviceService({required this.baseUrl}) {
    _initService();
  }

  Future<void> _initService() async {
    await AuthService.initAuthData();
  }

  Map<String, String> get authData => AuthService.authData;

  Future<List<DeviceModel>> getDevices() async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'list',
          'format': 'json',
          'fields': [
            'device_uid',
            'last_count',
            'last_access',
            'flag',
            'uptime',
            'initial_access',
            'ref_interval',
            'minimum',
            'maximum',
            'battery',
            'customer_name',
            'customer_no',
            'addr_prov',
            'addr_city',
            'addr_dist',
            'addr_detail',
            'share_house',
            'addr_apt',
            'category',
            'subscriber_no',
            'meter_id',
            'class',
            'in_outdoor',
          ],
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          final List<dynamic> devicesJson = jsonResponse['data'];
          return devicesJson.map((json) => DeviceModel.fromJson(json)).toList();
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('단말기 정보 조회 실패: $e');
    }
  }

  Future<DeviceModel> addDevice(DeviceModel device) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'add',
          'format': 'json',
          'data': {
            'device_uid': device.deviceUid,
            'customer_name': device.customerName,
            'customer_no': device.customerNo,
            'meter_id': device.meterId,
            'flag': device.flag,
          },
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          return DeviceModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('단말기 추가 실패: $e');
    }
  }

  Future<DeviceModel> updateDevice(DeviceModel device) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'modify',
          'format': 'json',
          'data': device.toJson(),
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          return DeviceModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('단말기 수정 실패: $e');
    }
  }

  Future<bool> deleteDevice(String deviceUid) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'format': 'json',
          'data': {'device_uid': deviceUid},
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          return true;
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('단말기 삭제 실패: $e');
    }
  }

  Future<DeviceModel> getDeviceInfo(String deviceUid) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'view',
          'format': 'json',
          'device_uid': deviceUid,
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          // print(data['data']);
          return DeviceModel.fromJson(data['data']);
        }
        throw Exception('장치 정보를 찾을 수 없습니다');
      } else {
        throw Exception('장치 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('장치 정보 조회 중 오류 발생: $e');
    }
  }

  Future<List<DeviceModel>> getDevicesWithFilter({
    List<String>? fields,
    Map<String, dynamic>? filter,
  }) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final Map<String, dynamic> requestBody = {
        'action': 'list',
        'format': 'json',
        'fields':  fields ?? [],
        ...authData,
      };

      // 필터가 있으면 추가
      if (filter != null && filter.isNotEmpty) {
        requestBody['filter'] = filter;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          final List<dynamic> devicesJson = jsonResponse['data'];
          return devicesJson.map((json) => DeviceModel.fromJson(json)).toList();
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('단말기 정보 조회 실패: $e');
    }
  }

  Future<bool> bindDeviceInstallation(Map<String, dynamic> data) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final Map<String, dynamic> requestBody = {
        'format': 'json',
        ...data,
        ...authData,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          return true;
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('설치 정보 업데이트 실패: $e');
    }
  }

  Future<DeviceModel?> getDeviceByMeterId(String meterId) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'list',
          'format': 'json',
          'fields': [
            'device_uid',
            'last_count',
            'last_access',
            'flag',
            'uptime',
            'initial_access',
            'ref_interval',
            'minimum',
            'maximum',
            'battery',
            'customer_name',
            'customer_no',
            'addr_prov',
            'addr_city',
            'addr_dist',
            'addr_detail',
            'share_house',
            'addr_apt',
            'category',
            'subscriber_no',
            'meter_id',
            'class',
            'in_outdoor',
            'release_date',
            'installer_id',
          ],
          'filter': {'meter_id': meterId},
          ...authData,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['code'] == 200) {
          final List<dynamic> devicesJson = jsonResponse['data'];
          if (devicesJson.isNotEmpty) {
            return DeviceModel.fromJson(devicesJson.first);
          }
          return null;
        } else {
          throw Exception('API 응답 오류: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('미터기 ID로 장치 정보 조회 실패: $e');
    }
  }

  // 인증 데이터 갱신 메서드
  Future<void> refreshAuthData() async {
    await AuthService.initAuthData();
  }
}
