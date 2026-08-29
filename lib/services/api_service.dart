import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_provider.dart';

class ApiService {
  final services = ['plumbing','electrical','cleaning','carpentry'];
  final prices = [500.0,700.0,400.0,800.0];

  Future<List<ServiceProvider>> fetchProviders() async {
    final res = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/users'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return List.generate(data.length, (i) => ServiceProvider.fromJson({
        'name': data[i]['name'],
        'service': services[i % 4],
        'price': prices[i % 4],
      }));
    }
    return [];
  }
}