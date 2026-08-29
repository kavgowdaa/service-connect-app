import 'package:flutter/material.dart';
import '../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});
  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}
class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookings = BookingService.bookings;
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: bookings.isEmpty? const Center(child: Text('No bookings yet')) :
      ListView.builder(padding: const EdgeInsets.all(16), itemCount: bookings.length,
        itemBuilder: (_, i) {
          final b = bookings[i];
          return Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.check)),
            title: Text(b.providerName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${b.service}\n₹${b.price}'), isThreeLine: true,
            trailing: IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => setState(() => bookings.removeAt(i))),
          ));
        }),
    );
  }
}