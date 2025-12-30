import 'dart:math';

import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../data/repository/authentication_repository.dart';

final loginStateProvider = StateNotifierProvider.autoDispose<LoginStateController, bool>(
  (ref) => LoginStateController(ref, false),
);

class LoginStateController extends StateNotifier<bool> {
  final AuthenticationRepository authRepository;
  final Ref ref;
  final CurrentUser userRepository;
  final PrefsService _prefs;

  LoginStateController(this.ref, super._state)
    : authRepository = ref.read(authRepositoryProvider),
      userRepository = ref.read(currentUserProvider.notifier),
        _prefs = ref.read(prefsServiceProvider)
  ;

  Future<void> continueWithGoogle() async {
    try {
      // await ref.read(profileStateProvider.notifier).deleteUser();
      
      final isInternet = ref.read(isInternetConnectedProvider);
      if(!isInternet) {
        SnackBarService.showMessage('please check your IC');
        return;
      }
      final credential = await authRepository.loginWithGoogle();
      // print("cred ${credential?.user}");

      if(credential==null || credential.user==null) {
        SnackBarService.showMessage('login failed');
        return;
      }

      final user = await userRepository.loadUserOnLogin(credential.user!.uid,credential.user!.email??'');

      if(user==null){

        final fireStoreService = ref.read(fireStoreServiceProvider);
        final spaceRepo = ref.read(spaceRepoProvider);

        String name = credential.user!.displayName?? "User${_generateNameSuffix()}" ;
        String email =  credential.user!.email?? '';

        UserModel user = UserModel(
          updatedAt: DateTime.now().toString(),
          id: credential.user!.uid,
          name: name,
          email: email,
          userType: "google",
          photoUrl: credential.user!.photoURL??"",
        );

        await userRepository.saveUserLocally(user: user);
        await fireStoreService.addUserTOFirebase(user);

        //
        final isInternet = ref.read(isInternetConnectedProvider);
        final isUser = FirebaseAuth.instance.currentUser?.uid;
        await _prefs.setCurrentUserId(user.id);

        ref.read(currentUserProvider).value!.copyWith(id: user.id,name: user.name,photoUrl: user.photoUrl,userType: 'google',email: user.email);

        await spaceRepo.createSpace(user: user,spaceName: "My Space",isInternet: isInternet,isUser: isUser);

      }
      else {


        await _prefs.setCurrentUserId(user.id);
      }
      MYRoute.appRouter.goNamed(MYRoute.screenRedirect);
    } catch (e) {
      SnackBarService.showError('Login with google failed. $e');
    }

  }

  Future<void> continueAsGuest() async {
    try{
      String id = Uuid().v1();
      final fireStoreService = ref.read(fireStoreServiceProvider);
      final spaceRepo = ref.read(spaceRepoProvider);

      final isInternet = ref.read(isInternetConnectedProvider);
      final isUser = ref.read(loggedInUserProvider);
      String spaceId = Uuid().v1();
      String name = "Guest_${_generateNameSuffix()}";
      String email = "";
      UserModel user = UserModel(
        updatedAt: DateTime.now().toString(),
        id: id,
        name: name,
        email: email,
        userType: "guest",
        photoUrl: "",
      );
      await userRepository.saveUserLocally(user: user);
      //
      await spaceRepo.createSpace(user: user,
          spaceName: "My Space",
          isInternet: isInternet,
          isUser: isUser.value);
      await _prefs.setCurrentUserId(user.id);
      MYRoute.appRouter.goNamed(MYRoute.screenRedirect);
    }catch (e){
      SnackBarService.showError('guest login failed $e');
    }
  }


  String _generateNameSuffix() {
    String s = "";
    for (int i = 0; i < 2; i++) {
      final random = Random();
      const String characters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Define your character set

      // Get a random index within the range of the character set's length
      int randomIndex = random.nextInt(characters.length);

      // Return the character at the random index
      s = s + characters[randomIndex];
    }
    return s;
  }
}

final isLoginProvider = StateProvider<bool>((ref)=>false);