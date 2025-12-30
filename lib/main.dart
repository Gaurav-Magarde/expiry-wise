import 'package:expiry_wise_app/services/Connectivity/internet_connectivity.dart';
import 'package:expiry_wise_app/firebase_options.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/notification_services/local_notification_service.dart';
import 'core/utils/snackbars/snack_bar_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );

  // RestartWidget ko sabse upar lagaya hai taaki ProviderScope destroy ho sake
  runApp(
      const RestartWidget(
          child: ProviderScope(
              child: MyApp()
          )
      )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    // Notification initialization
    final notification = ref.watch(notificationServiceProvider);
    final c = ref.watch(isInternetConnectedProvider);
    notification.init();
    notification.checkPendingNotifications();

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: EAppTheme.lightTheme,
      title: "expiry-wise",
      debugShowCheckedModeBanner: false,

      routerConfig: MYRoute.appRouter,
    );
  }
}

class AppStartScreen extends StatelessWidget {
  const AppStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Add products'),
            )));
  }
}

// 🔥 Restart Logic Widget
class RestartWidget extends StatefulWidget {
  final Widget child;
  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}