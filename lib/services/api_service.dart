import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  String get baseUrl {
    if (kIsWeb) return "http://127.0.0.1:8000";
    return "http://10.0.2.2:8000";
  }

  Future<List> getProviders({String? service}) async {
    var url = Uri.parse("$baseUrl/providers");
    if (service != null && service.isNotEmpty && service != "All") {
      url = Uri.parse("$baseUrl/providers?service=$service");
    }
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // This fixes your error - add both names
  Future bookProvider(int id) async {
    final res = await http.post(Uri.parse("$baseUrl/book/$id"));
    return res.body;
  }

  Future bookService(int id) async {
    return bookProvider(id);
  }
}