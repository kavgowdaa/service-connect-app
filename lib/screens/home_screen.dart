import 'package:flutter/material.dart';
import '../models/service_provider.dart';
import '../services/api_service.dart';
import '../widgets/service_card.dart';
import 'provider_details_screen.dart';
import 'my_bookings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  List<ServiceProvider> searchResults = [];
  final apiService = ApiService();

  Future<void> searchService(String service) async {
    searchController.text = service;
    final providers = await apiService.fetchProviders();
    setState(() => searchResults = providers.where((p) => p.service == service).toList());
  }
  Future<void> searchFromText() async {
    final q = searchController.text.trim().toLowerCase();
    if (q.isEmpty) { setState(() => searchResults = []); return; }
    final providers = await apiService.fetchProviders();
    setState(() => searchResults = providers.where((p) => p.service == q).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ServiceConnect'), actions: [
        IconButton(icon: const Icon(Icons.book_online), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()))),
        IconButton(icon: const Icon(Icons.logout), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
      ]),
      body: Padding(padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: searchController, decoration: const InputDecoration(hintText: 'Search for a service', prefixIcon: Icon(Icons.search), border: OutlineInputBorder())),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: searchFromText, child: const Text('Search'))),
          const SizedBox(height: 15),
          Expanded(child: ListView(children: [
            ...searchResults.map((p) => Card(child: ListTile(title: Text(p.name), subtitle: Text(p.service), trailing: Text('₹${p.price}'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderDetailsScreen(provider: p)))))),
            const SizedBox(height: 20),
            const Text('Popular Services', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(children: [Expanded(child: ServiceCard(icon: Icons.plumbing, title: 'Plumbing', onTap: () => searchService('plumbing'))), const SizedBox(width: 10), Expanded(child: ServiceCard(icon: Icons.electrical_services, title: 'Electrical', onTap: () => searchService('electrical')))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: ServiceCard(icon: Icons.cleaning_services, title: 'Cleaning', onTap: () => searchService('cleaning'))), const SizedBox(width: 10), Expanded(child: ServiceCard(icon: Icons.handyman, title: 'Carpentry', onTap: () => searchService('carpentry')))]),
          ]))
        ])),
    );
  }
}