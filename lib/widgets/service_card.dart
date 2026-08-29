import 'package:flutter/material.dart';
class ServiceCard extends StatelessWidget {
  final IconData icon; final String title; final VoidCallback onTap;
  const ServiceCard({super.key, required this.icon, required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(20),
    child: Column(children: [Icon(icon, size: 40, color: Colors.blue), const SizedBox(height:8), Text(title)]))));
  }
}