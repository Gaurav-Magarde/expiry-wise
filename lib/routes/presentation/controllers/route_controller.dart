import 'package:expiry_wise_app/services/sync_services/local_firebase_syncing.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/local_db/prefs_service.dart';
import '../../../features/User/presentation/controllers/user_controller.dart';
import '../../route.dart';

final screenRedirectProvider = Provider((ref) => RouteController(ref));

class RouteController {
  final Ref ref;
  RouteController(this.ref);
  void screenRedirect() async {

    final prefs = ref.read(prefsServiceProvider);
    final isFirst = await prefs.isUserFirstLogin;
    if (!isFirst) {
      MYRoute.appRouter.goNamed(MYRoute.onBoardingScreen);
      return;
    }


    final userLoggedIn = await ref.read(currentUserProvider.future);
      if (userLoggedIn==null||userLoggedIn.id.isEmpty) {
        MYRoute.appRouter.goNamed(MYRoute.logInScreen);
      } else {
    ref
        .read(currentSpaceProvider.future);
         ref.read(syncProvider).performAutoSync();
        MYRoute.appRouter.goNamed(MYRoute.navigationScreen);

      }
  }
}
