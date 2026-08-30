import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'provider_details_screen.dart';// <-- NEW LINE ADDED

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  final searchCtrl = TextEditingController();
  List providers = [];
  bool loading = false;
  String selectedService = "All";

  final services = ["All", "Plumbing", "Electrical", "Cleaning", "Carpentry"];

  @override
  void initState() {
    super.initState();
    loadProviders();
  }

  loadProviders({String? query}) async {
    setState(() => loading = true);
    try {
      final data = await api.getProviders(service: query);
      setState(() => providers = data);
    } catch (e) {
      print(e);
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: Color(0xFF6C5CE7), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.handyman, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Text("ServiceConnect", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        actions: [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search for plumbing, electrical...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF6C5CE7)),
                        onPressed: () => loadProviders(query: searchCtrl.text),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onSubmitted: (v) => loadProviders(query: v),
                  ),
                ),
                SizedBox(height: 16),
                Text("Popular Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: services.map((s) {
                      bool isSelected = selectedService == s;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedService = s);
                          loadProviders(query: s == "All"? "" : s);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected? Color(0xFF6C5CE7) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected? Color(0xFF6C5CE7) : Color(0xFFDFE6E9)),
                          ),
                          child: Text(s, style: TextStyle(color: isSelected? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
              ? Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
                : providers.isEmpty
                  ? Center(child: Text("No providers found. Try All"))
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: providers.length,
                        itemBuilder: (ctx, i) {
                          final p = providers[i];
                          return InkWell( // <-- CLICKABLE NOW
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProviderDetailScreen(provider: p))),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Color(0xFF6C5CE7).withOpacity(0.15),
                                          child: Text(p["name"][0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                            child: Icon(Icons.verified, color: Colors.green, size: 18),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(child: Text(p["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(color: Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(6)),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.star, size: 14, color: Colors.orange),
                                                    SizedBox(width: 2),
                                                    Text("${p["rating"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Text(p["service"], style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Text("₹${p["price"]}/hour", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
                                              Spacer(),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  await api.bookProvider(p["id"]);
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${p["name"]} booked!"), backgroundColor: Colors.green));
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Color(0xFF6C5CE7),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                                  elevation: 0,
                                                ),
                                                child: Text("Book Now", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}