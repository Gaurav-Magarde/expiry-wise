import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ < 6.x ke liye: onConnectivityChanged = Stream<ConnectivityResult>
final connectivityStreamProvider =
StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

final isInternetConnectedProvider = Provider<bool>((ref) {
  final connectivityStatus = ref.watch(connectivityStreamProvider);

  return connectivityStatus.when(
    data: (result) {
      switch (result) {
        case ConnectivityResult.wifi:
        case ConnectivityResult.mobile:
        case ConnectivityResult.ethernet:
          return true;
        case ConnectivityResult.bluetooth:
        case ConnectivityResult.none:
        default:
          return false;
      }
    },
    loading: () => true,
    error: (_, __) => false,
  );
});

// ✅ Sirf debug ke liye listener (yahi print karega)
final connectivityLoggerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<ConnectivityResult>>(
    connectivityStreamProvider,
        (previous, next) {
      next.when(
        data: (result) {
          // yeh har change par chalega
          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@CONNECTIVITY CHANGE: $result');
        },
        loading: () {
          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@CONNECTIVITY: loading');
        },
        error: (err, stack) {
          print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@22CONNECTIVITY ERROR: $err');
        },
      );
    },
  );
});
