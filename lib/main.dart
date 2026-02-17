import 'package:expiry_wise_app/services/Connectivity/internet_connectivity.dart';
import 'package:expiry_wise_app/firebase_options.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/theme.dart';
import 'package:expiry_wise_app/services/workmanager/work_manager_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_services/local_notification_service.dart';
import 'core/utils/snackbars/snack_bar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerOneOffTask(
    '777',taskSyncCheck,
    initialDelay: const Duration(seconds: 1),
    constraints: Constraints(
      networkType: NetworkType.connected,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: EAppTheme.lightTheme,
      title: 'expiry-wise',
      debugShowCheckedModeBanner: false,

      routerConfig: MYRoute.appRouter,
    );
  }
}
