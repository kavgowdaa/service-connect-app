import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000";
    return "http://10.0.2.2:8000";
  }

  // Main method
  static Future<List<dynamic>> getProviders() async {
    final res = await http.get(Uri.parse("$baseUrl/providers"));
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  // Alias for home_screen.dart which calls fetchProviders
  static Future<List<dynamic>> fetchProviders() async {
    return getProviders();
  }

  static Future<bool> bookService(int id) async {
    final res = await http.post(Uri.parse("$baseUrl/book/$id"));
    return res.statusCode == 200;
  }

  static Future<List<dynamic>> getBookings() async {
    final res = await http.get(Uri.parse("$baseUrl/bookings"));
    return res.statusCode == 200 ? jsonDecode(res.body) : [];
  }

  static Future<List<dynamic>> fetchBookings() async {
    return getBookings();
  }
}