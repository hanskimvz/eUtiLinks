import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/subscriber_model.dart';
import 'auth_service.dart';

class SubscriberService {
  final String baseUrl;

  SubscriberService({required this.baseUrl}) {
    _initService();
  }

  Future<void> _initService() async {
    await AuthService.initAuthData();
  }

  Future<List<SubscriberModel>> getSubscribers() async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'list',

          'fields': [],
          'format': 'json',
          ...AuthService.authData,
        }),
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // API 응답이 맵 형태인 경우 (data 필드 내에 리스트가 있는 경우)
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => SubscriberModel.fromJson(json)).toList();
        }
        // API 응답이 직접 리스트인 경우
        else if (responseData is List) {
          return responseData
              .map((json) => SubscriberModel.fromJson(json))
              .toList();
        }
        // 다른 형식의 응답인 경우
        else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load subscribers: ${response.statusCode}');
      }
    } catch (e) {
      // print (e);
      throw Exception('Error fetching subscribers: $e');
    }
  }

  Future<SubscriberModel> getSubscriberByMeterId(String meterId) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'view',
          'meter_id': meterId,
          'format': 'json',
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return SubscriberModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subscriber: $e');
    }
  }

  Future<void> addSubscriber(Map<String, dynamic> subscriberData) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...subscriberData, ...AuthService.authData}),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding subscriber: $e');
    }
  }

  Future<void> updateSubscriber(
    String subscriberId,
    Map<String, dynamic> subscriberData,
  ) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.put(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...subscriberData, ...AuthService.authData}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating subscriber: $e');
    }
  }

  Future<void> deleteSubscriber(String subscriberId) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting subscriber: $e');
    }
  }

  Future<List<SubscriberModel>> getSubscribersWithFilter({
    required String page,
    required List<String> fields,
    required Map<String, dynamic> filter,
  }) async {
    try {
      // 인증 데이터가 비어있으면 초기화
      if (AuthService.authData.isEmpty) {
        await AuthService.initAuthData();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriber'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'list',

          'format': 'json',
          'fields': fields,
          'filter': filter,
          ...AuthService.authData,
        }),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // API 응답이 맵 형태인 경우 (data 필드 내에 리스트가 있는 경우)
        if (responseData is Map && responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => SubscriberModel.fromJson(json)).toList();
        }
        // API 응답이 직접 리스트인 경우
        else if (responseData is List) {
          return responseData
              .map((json) => SubscriberModel.fromJson(json))
              .toList();
        }
        // 다른 형식의 응답인 경우
        else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw Exception('Failed to load subscribers: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching subscribers with filter: $e');
      throw Exception('Error fetching subscribers: $e');
    }
  }

  // 인증 데이터 갱신 메서드
  Future<void> refreshAuthData() async {
    await AuthService.initAuthData();
  }
}
