import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_provider.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final serviceProvidersProvider =
    FutureProvider.family<List<ServiceProvider>, String>((ref, service) async {
  final apiService = ref.read(apiServiceProvider);

  final data = await apiService.getProviders(
    service: service,
  );

  return data
      .map(
        (json) => ServiceProvider.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
      .toList();
});