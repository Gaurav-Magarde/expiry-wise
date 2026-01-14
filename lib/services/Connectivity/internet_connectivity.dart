import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

final connectivityStreamProvider =
StreamProvider<InternetStatus>((ref) {
  return InternetConnection().onStatusChange;
});

final isInternetConnectedProvider = Provider<bool>((ref) {
  final connectivityStatus = ref.watch(connectivityStreamProvider);

  return connectivityStatus.when(
    data: (result) {
      return result == InternetStatus.connected;

    },
    loading: () => false,
    error: (_, __) => false,
  );
});
