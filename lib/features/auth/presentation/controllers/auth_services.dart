import 'dart:math';

import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/spaceServices/space_services.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/services.dart';
import 'package:expiry_wise_app/features/auth/data/repository/authentication_repository.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:uuid/uuid.dart';

final authServicesProvider = Provider<AuthServices>((ref){
  final userRepository = ref.read(userRepoProvider);
  final userUseCase = ref.read(userServiceProvider);
  final spaceService = ref.read(spaceUseCaseProvider);
  final authRepository = ref.read(authRepositoryProvider);
  final prefs = ref.read(prefsServiceProvider);
  final network = ref.read(networkInfoProvider);
  return AuthServices(userRepository: userRepository, authRepository: authRepository, userUseCase: userUseCase, spaceService: spaceService, prefs: prefs, connectionInfo: network);
});

class AuthServices{
  final IUserRepository userRepository;
  final AuthenticationRepository authRepository;
  final UserServices userUseCase;
  final SpaceUseCases spaceService;
  final PrefsService prefs;
  final NetworkInfoImpl connectionInfo;
  AuthServices({required this.userRepository,required this.connectionInfo,required this.prefs,required this.spaceService,required this.userUseCase,required this.authRepository,});
  Future<void> deleteUserUseCase({required UserModel? user}) async {
    if (user == null ||
        user.id.isEmpty) {
      throw Exception('user not found.please try again later');
    }
    if (user.userType == 'google') {
      await userRepository.deleteUserFromRemote(userId: user.id);
      await authRepository.logOutUser();
    }else{
      await authRepository.logOutUser();
    }
  }

  Future<void> continueWithGoogleUseCase() async {
    try {
      final credential = await authRepository.loginWithGoogle();
      final isInternet = await connectionInfo.checkInternetStatus;
      if(!isInternet) throw Exception('No Internet Connection');
      print(isInternet);
      if(credential==null || credential.user==null) {
        throw Exception('login failed');
      }
      final user = await userUseCase.loadUserOnLogin(credential.user!.uid,credential.user!.email??'');

      if(user==null){

        String name = credential.user!.displayName?? 'User${_generateNameSuffix()}' ;
        String email =  credential.user!.email?? '';

        UserModel user = UserModel(
          updatedAt: DateTime.now().toIso8601String(),
          id: credential.user!.uid,
          name: name,
          email: email,
          userType: 'google',
          photoUrl: credential.user!.photoURL??'',
        );
        await userRepository.saveUserLocally(user: user);
        await userRepository.addUserToRemote(user: user);
        await prefs.setCurrentUserId(user.id);

        await spaceService.addNewSpaceUseCase(name: 'My Space',user: user);

      }
      else {
        await prefs.setCurrentUserId(user.id);
      }
    } catch (e) {
      throw Exception('Login with google failed. $e');
    }

  }

  Future<void> continueAsGuestUseCase() async {
    try{
      String id = const Uuid().v1();
      String name = 'Guest_${_generateNameSuffix()}';
      String email = '';
      UserModel user = UserModel(
        updatedAt: DateTime.now().toIso8601String(),
        id: id,
        name: name,
        email: email,
        userType: 'guest',
        photoUrl: '',
      );
      await userRepository.saveUserLocally(user: user);

      try{
        await spaceService.addNewSpaceUseCase(
            name: 'My Space', user: user);
      }catch(e){
        throw Exception('space created failed $e');
      }
      await prefs.setCurrentUserId(user.id);
    }catch (e) {
      throw Exception('guest login failed $e');
    }
  }

  String _generateNameSuffix() {
    String s = '';
    for (int i = 0; i < 2; i++) {
      final random = Random();
      const String characters =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'; // Define your character set

      // Get a random index within the range of the character set's length
      int randomIndex = random.nextInt(characters.length);
      s = s + characters[randomIndex];
    }
    return s;
  }
}