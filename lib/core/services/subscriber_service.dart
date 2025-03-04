import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscriber_model.dart';

class SubscriberService {
  final String baseUrl;

  SubscriberService({required this.baseUrl});

  Future<List<SubscriberModel>> getSubscribers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'page': 'database',
          'table': 'subscriber',
          'fields':[],
          // 'filter': {'\$or': [{'binded': false}, {'binded': null}]},
          'format': 'json',
          'db': dbName,
          'user_id': loginId,
          'role': role,
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
          return responseData.map((json) => SubscriberModel.fromJson(json)).toList();
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

  Future<SubscriberModel> getSubscriberById(String subscriberId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscribers/$subscriberId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return SubscriberModel.fromJson(data);
      } else {
        throw Exception('Failed to load subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching subscriber: $e');
    }
  }

  Future<void> addSubscriber(Map<String, dynamic> subscriberData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscribers'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(subscriberData),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add subscriber: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding subscriber: $e');
    }
  }

  Future<void> updateSubscriber(String subscriberId, Map<String, dynamic> subscriberData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/subscribers/$subscriberId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(subscriberData),
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
      final response = await http.delete(
        Uri.parse('$baseUrl/api/subscribers/$subscriberId'),
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
      final prefs = await SharedPreferences.getInstance();
      final dbName = prefs.getString('_db_name') ?? '';
      final loginId = prefs.getString('_login_id') ?? '';
      final role = prefs.getString('_role') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'page': page,
          'format': 'json',
          'fields': fields,
          'filter': filter,
          'db_name': dbName,
          'user_id': loginId,
          'role': role,
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
          return responseData.map((json) => SubscriberModel.fromJson(json)).toList();
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
} 