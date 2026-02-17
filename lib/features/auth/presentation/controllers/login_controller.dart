import 'dart:math';

import 'package:expiry_wise_app/features/Space/presentation/controllers/spaceServices/space_services.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/auth/presentation/controllers/auth_services.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../routes/presentation/controllers/route_controller.dart';
import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../../../services/local_db/sqflite_setup.dart';
import '../../data/repository/authentication_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref, false),
);

class AuthController extends StateNotifier<bool> {
  final AuthenticationRepository authRepository;
  final Ref ref;

  AuthController(this.ref, super._state)
    : authRepository = ref.read(authRepositoryProvider)
  ;

  Future<void> continueWithGoogle() async {
    final link = ref.keepAlive();
    try {
      await ref.read(authServicesProvider).continueWithGoogleUseCase();
      ref.invalidate(currentUserProvider);
      MYRoute.appRouter.goNamed(MYRoute.screenRedirect);
    } catch (e) {
      SnackBarService.showError('Login with google failed. $e');
    }finally{
     link.close();
    }

  }

  Future<void> continueAsGuest() async {
    final link = ref.keepAlive();
    try{
      await ref.read(authServicesProvider).continueAsGuestUseCase();
      ref.invalidate(currentUserProvider);
      MYRoute.appRouter.goNamed(MYRoute.screenRedirect);
    }catch (e){
      SnackBarService.showError('$e');
    }finally{
      link.close();
    }
  }

  Future<void> logOutUser() async {

    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logOutUser();
    ref.invalidate(currentUserProvider);
    ref.read(screenRedirectProvider).screenRedirect();
  }

  Future<void> deleteUser() async {
    final user = ref.read(currentUserProvider).value;
    await ref.read(authServicesProvider).deleteUserUseCase(user: user);
    ref.invalidate(currentUserProvider);
  }

}

final isLoginProvider = StateProvider.autoDispose<bool>((ref)=>false);