class ServiceProvider {
  final int id;
  final String name;
  final String service;
  final double price;
  final double rating;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.rating,
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int,
      name: json['name'] as String,
      service: json['service'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}