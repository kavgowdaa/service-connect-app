import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // ============================================================
  // BACKEND URL
  // ============================================================

  // Chrome / Windows
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

      if (response.statusCode != 200) {
        throw Exception('Provider API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded;
      }

      throw Exception('Invalid providers response from server');
    } catch (e) {
      debugPrint('PROVIDER API ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET SINGLE PROVIDER
  // ============================================================

  Future<Map<String, dynamic>> getProvider(int providerId) async {
    try {
      final url = Uri.parse('$baseUrl/providers/$providerId');

      debugPrint('==========================================');
      debugPrint('GET PROVIDER');
      debugPrint('URL: $url');
      debugPrint('==========================================');

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

      debugPrint('==========================================');
      debugPrint('GET SERVICES');
      debugPrint('URL: $url');
      debugPrint('==========================================');

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
  // LOGIN
  // ============================================================

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final body = {'email': email.trim().toLowerCase(), 'password': password};

      debugPrint('==========================================');
      debugPrint('LOGIN');
      debugPrint('URL: $url');
      debugPrint('EMAIL: ${body['email']}');
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

      debugPrint('LOGIN STATUS: ${response.statusCode}');

      debugPrint('LOGIN RESPONSE: ${response.body}');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from login server');
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Invalid login response');
      }

      // ==========================================================
      // FASTAPI ERROR
      // ==========================================================

      if (decoded is Map && decoded['detail'] != null) {
        throw Exception(decoded['detail'].toString());
      }

      throw Exception('Login failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('LOGIN API ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/auth/register');

      final body = {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      };

      debugPrint('==========================================');
      debugPrint('REGISTER');
      debugPrint('URL: $url');
      debugPrint('NAME: ${body['name']}');
      debugPrint('EMAIL: ${body['email']}');
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

      debugPrint('REGISTER STATUS: ${response.statusCode}');

      debugPrint('REGISTER RESPONSE: ${response.body}');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from registration server');
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Invalid registration response');
      }

      // ==========================================================
      // FASTAPI ERROR
      // ==========================================================

      if (decoded is Map && decoded['detail'] != null) {
        throw Exception(decoded['detail'].toString());
      }

      throw Exception('Registration failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('REGISTER API ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final url = Uri.parse('$baseUrl/auth/forgot-password');

      final body = {'email': email.trim().toLowerCase()};

      debugPrint('==========================================');
      debugPrint('FORGOT PASSWORD');
      debugPrint('URL: $url');
      debugPrint('EMAIL: ${body['email']}');
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

      debugPrint('FORGOT PASSWORD STATUS: ${response.statusCode}');

      debugPrint('FORGOT PASSWORD RESPONSE: ${response.body}');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from forgot password server');
      }

      // ==========================================================
      // SUCCESS
      // ==========================================================

      if (response.statusCode == 200) {
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        throw Exception('Invalid forgot password response');
      }

      // ==========================================================
      // FASTAPI ERROR
      // ==========================================================

      if (decoded is Map && decoded['detail'] != null) {
        throw Exception(decoded['detail'].toString());
      }

      throw Exception('Forgot password failed: ${response.statusCode}');
    } catch (e) {
      debugPrint('FORGOT PASSWORD API ERROR: $e');

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
        'customer_name': customerName.trim(),
        'customer_email': customerEmail.trim().toLowerCase(),
        'service_date': serviceDate,
        'service_time': serviceTime,
        'address': address.trim(),
        'notes': notes.trim(),
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

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from booking server');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (decoded is Map && decoded['detail'] != null) {
          throw Exception(decoded['detail'].toString());
        }

        throw Exception('Booking failed: ${response.statusCode}');
      }

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid booking response');
    } catch (e) {
      debugPrint('BOOKING ERROR: $e');
      rethrow;
    }
  }

  // ============================================================
  // GET USER BOOKINGS
  // ============================================================

  Future<List<dynamic>> getBookings(String customerEmail) async {
    try {
      final url = Uri.parse(
        '$baseUrl/bookings/${Uri.encodeComponent(customerEmail)}',
      );

      debugPrint('==========================================');
      debugPrint('GET BOOKINGS');
      debugPrint('EMAIL: $customerEmail');
      debugPrint('URL: $url');
      debugPrint('==========================================');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('BOOKINGS STATUS: ${response.statusCode}');

      debugPrint('BOOKINGS RESPONSE: ${response.body}');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from bookings server');
      }

      if (response.statusCode != 200) {
        if (decoded is Map && decoded['detail'] != null) {
          throw Exception(decoded['detail'].toString());
        }

        throw Exception('Bookings API failed: ${response.statusCode}');
      }

      if (decoded is Map && decoded['bookings'] is List) {
        return List<dynamic>.from(decoded['bookings']);
      }

      throw Exception('Invalid bookings response');
    } catch (e) {
      debugPrint('GET BOOKINGS ERROR: $e');

      rethrow;
    }
  }

  // ============================================================
  // DELETE BOOKING
  // ============================================================

  Future<bool> deleteBooking(int bookingId) async {
    try {
      final url = Uri.parse('$baseUrl/booking/$bookingId');

      debugPrint('==========================================');
      debugPrint('DELETE BOOKING');
      debugPrint('BOOKING ID: $bookingId');
      debugPrint('URL: $url');
      debugPrint('==========================================');

      final response = await http
          .delete(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      debugPrint('DELETE STATUS: ${response.statusCode}');

      debugPrint('DELETE RESPONSE: ${response.body}');

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid response from delete booking server');
      }

      if (response.statusCode != 200) {
        if (decoded is Map && decoded['detail'] != null) {
          throw Exception(decoded['detail'].toString());
        }

        throw Exception('Delete booking failed: ${response.statusCode}');
      }

      if (decoded is Map && decoded['success'] == true) {
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('DELETE BOOKING ERROR: $e');

      rethrow;
    }
  }
}
