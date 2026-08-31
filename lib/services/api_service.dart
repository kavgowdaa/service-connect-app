import 'dart:convert';
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
      String cleanService = service?.trim() ?? '';

      // Build URL
      Uri url;

      if (cleanService.isEmpty || cleanService.toLowerCase() == 'all') {
        url = Uri.parse('$baseUrl/providers');
      } else {
        url = Uri.parse(
          '$baseUrl/providers',
        ).replace(queryParameters: {'service': cleanService.toLowerCase()});
      }

      print('==========================================');
      print('GET PROVIDERS');
      print('SERVICE: $cleanService');
      print('URL: $url');
      print('==========================================');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.body}');
      print('==========================================');

      // ========================================================
      // CHECK HTTP STATUS
      // ========================================================

      if (response.statusCode != 200) {
        throw Exception('Provider API failed: ${response.statusCode}');
      }

      // ========================================================
      // DECODE JSON
      // ========================================================

      final decoded = jsonDecode(response.body);

      // ========================================================
      // PROVIDER LIST
      // ========================================================

      if (decoded is List) {
        return decoded;
      }

      throw Exception('Invalid providers response from server');
    } catch (e) {
      print('==========================================');
      print('PROVIDER API ERROR');
      print(e);
      print('==========================================');

      rethrow;
    }
  }

  // ============================================================
  // GET SINGLE PROVIDER
  // ============================================================

  Future<Map<String, dynamic>> getProvider(int providerId) async {
    try {
      final url = Uri.parse('$baseUrl/providers/$providerId');

      print('GET PROVIDER: $url');

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Provider API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid provider response');
    } catch (e) {
      print('GET PROVIDER ERROR: $e');
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

      print('GET SERVICES STATUS: ${response.statusCode}');
      print('GET SERVICES BODY: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Services API failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['services'] is List) {
        return List<String>.from(decoded['services']);
      }

      throw Exception('Invalid services response');
    } catch (e) {
      print('GET SERVICES ERROR: $e');
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

      print('==========================================');
      print('CREATE BOOKING');
      print('URL: $url');
      print('BODY: $body');
      print('==========================================');

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

      print('BOOKING STATUS: ${response.statusCode}');
      print('BOOKING RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Booking failed: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      throw Exception('Invalid booking response');
    } catch (e) {
      print('BOOKING ERROR: $e');
      rethrow;
    }
  }
}
