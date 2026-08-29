class ServiceProvider {
  String name;
  String service;
  double price;
  ServiceProvider(this.name, this.service, this.price);

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(json['name'], json['service'], (json['price'] as num).toDouble());
  }
}