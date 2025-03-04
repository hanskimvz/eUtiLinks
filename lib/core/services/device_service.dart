import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class DeviceService {
  final String baseUrl;

  DeviceService({
    required this.baseUrl,
  });

  Future<List<DeviceModel>> getDevices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'page': 'device_info',
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
            'in_outdoor'
          ],
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
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
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/device/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_uid': device.deviceUid,
          'customer_name': device.customerName,
          'customer_no': device.customerNo,
          'meter_id': device.meterId,
          'flag': device.flag,
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
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
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/device/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_uid': device.deviceUid,
          'customer_name': device.customerName,
          'customer_no': device.customerNo,
          'meter_id': device.meterId,
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
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
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/device/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'device_uid': deviceUid,
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
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
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';
      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'page': 'device_info',
          'device_uid': deviceUid,
          'format': 'json',
          'fields': [],
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data'].isNotEmpty) {
          return DeviceModel.fromJson(data['data'][0]);
        }
        throw Exception('장치 정보를 찾을 수 없습니다');
      } else {
        throw Exception('장치 정보 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('장치 정보 조회 중 오류 발생: $e');
    }
  }
} 