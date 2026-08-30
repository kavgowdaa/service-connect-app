import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProviderDetailScreen extends StatelessWidget {
  final Map provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(provider["name"]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.15),
                      child: Text(provider["name"][0],
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(child: Text(provider["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                  Center(child: Text(provider["service"], style: const TextStyle(color: Colors.grey, fontSize: 16))),
                  const SizedBox(height: 20),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    _info(Icons.star, "${provider["rating"]} Rating", Colors.orange),
                    _info(Icons.work, "120+ Jobs", Colors.blue),
                    _info(Icons.verified, "Verified", Colors.green),
                  ]),
                  const SizedBox(height: 20),

                  // ADDED FOR JOB: Google Maps Section
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(color: Colors.grey[200]),
                          Center(child: Icon(Icons.map, size: 40, color: Colors.grey[400])),
                          Positioned(
                            bottom: 10, left: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                              child: Text("📍 ${provider["name"]} • 1.2 km away • Mangaluru", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text("Experienced ${provider["service"]} professional with 5+ years. Serving tenants, landlords & PG owners. Available 24/7 in Mangaluru area.",
                    style: TextStyle(color: Colors.grey[600], height: 1.5)),
                ],
              ),
            ),
          ),
          // Bottom price bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("₹${provider["price"]}/hour", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                Text("Incl. taxes", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ]),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  await ApiService().bookProvider(provider["id"]);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("✅ ${provider["name"]} booked for ₹${provider["price"]}"), backgroundColor: Colors.green));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("Confirm Booking", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text, Color color) {
    return Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 6), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))]);
  }
}