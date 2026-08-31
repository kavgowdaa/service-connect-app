import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  // Chrome / Windows:
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ============================================================
  // GET PROVIDERS
  // ============================================================

  Future<List<dynamic>> getProviders({String? service}) async {
    try {
      final String cleanService = service?.trim() ?? '';

      Uri url;

      if (cleanService.isEmpty || cleanService.toLowerCase() == 'all') {
        url = Uri.parse('$baseUrl/providers');
      } else {
        url = Uri.parse(
          '$baseUrl/providers',
        ).replace(queryParameters: {'service': cleanService.toLowerCase()});
      }

      debugPrint('==========================================');
      debugPrint('GET PROVIDERS');
      debugPrint('SERVICE: $cleanService');
      debugPrint('URL: $url');
      debugPrint('==========================================');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('STATUS CODE: ${response.statusCode}');
      debugPrint('RESPONSE: ${response.body}');
      debugPrint('==========================================');

      if (response.statusCode != 200) {
        throw Exception('Provider API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }

      throw Exception('Invalid providers response from server');
    } catch (e) {
      debugPrint('==========================================');
      debugPrint('PROVIDER API ERROR');
      debugPrint('$e');
      debugPrint('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET SINGLE PROVIDER
  // ============================================================

  Future<Map<String, dynamic>> getProvider(int providerId) async {
    try {
      final url = Uri.parse('$baseUrl/providers/$providerId');

      debugPrint('GET PROVIDER: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Provider API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid provider response');
    } catch (e) {
      debugPrint('GET PROVIDER ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET SERVICES
  // ============================================================

  Future<List<String>> getServices() async {
    try {
      final url = Uri.parse('$baseUrl/services');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('GET SERVICES STATUS: ${response.statusCode}');
      debugPrint('GET SERVICES BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Services API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['services'] is List) {
        return List<String>.from(decoded['services']);
      }

      throw Exception('Invalid services response');
    } catch (e) {
      debugPrint('GET SERVICES ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<Map<String, dynamic>> createBooking({
    required int providerId,
    required String customerName,
    required String customerEmail,
    required String serviceDate,
    required String serviceTime,
    required String address,
    String notes = '',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/book');

      final body = {
        'provider_id': providerId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'service_date': serviceDate,
        'service_time': serviceTime,
        'address': address,
        'notes': notes,
      };

      debugPrint('==========================================');
      debugPrint('CREATE BOOKING');
      debugPrint('URL: $url');
      debugPrint('BODY: $body');
      debugPrint('==========================================');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('BOOKING STATUS: ${response.statusCode}');
      debugPrint('BOOKING RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Booking failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid booking response');
    } catch (e) {
      debugPrint('BOOKING ERROR: $e');
      rethrow;
    }
  }
}
