import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../data/datasources/remote/rest_api.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  final client = HttpClient();
  ref.onDispose(client.dispose);
  return client;
});

final apiProvider = Provider<RestApi>(
  (ref) => RestApi(ref.watch(httpClientProvider)),
);
