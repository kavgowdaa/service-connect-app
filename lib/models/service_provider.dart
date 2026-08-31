class ServiceProvider {
  final int id;
  final String name;
  final String service;
  final double price;
  final double rating;
  final String description;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.service,
    required this.price,
    required this.rating,
    this.description = '',
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Provider',
      service: json['service']?.toString() ?? 'Service',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'service': service,
      'price': price,
      'rating': rating,
      'description': description,
    };
  }
}
