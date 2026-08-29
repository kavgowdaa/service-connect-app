import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/service_provider.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

class ProviderDetailsScreen extends StatelessWidget {
  final ServiceProvider provider;
  const ProviderDetailsScreen({super.key, required this.provider});

  Future<void> bookService(BuildContext context) async {
    if (BookingService.isAlreadyBooked(provider.name, provider.service)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have already booked this service.')));
      return;
    }
    final response = await http.post(Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'providerName': provider.name, 'service': provider.service, 'price': provider.price}));

    if (response.statusCode == 201) {
      BookingService.addBooking(Booking(provider.name, provider.service, provider.price));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking sent to ${provider.name}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Provider Details')),
      body: Padding(padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 60))),
          const SizedBox(height: 25),
          Text(provider.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Service: ${provider.service}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 12),
          Text('Price: ₹${provider.price}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => bookService(context), child: const Text('Book Service'))),
        ])));
  }
}