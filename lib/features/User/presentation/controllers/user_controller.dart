import 'dart:async';

import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/snackbars/snack_bar_service.dart';
import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../data/models/user_model.dart';

final userRepoProvider = Provider<UserRepository>((ref) {
  final fireStoreService = ref.read(fireStoreServiceProvider);

  return UserRepository(ref, fireStoreService);
});

class UserRepository {
  final SqfLiteSetup _sqfLite;
  final PrefsService _prefs;
  final FireStoreService _fireStoreService;

  UserRepository(Ref ref, this._fireStoreService)
    : _sqfLite = ref.read(sqfLiteSetupProvider),
      _prefs = ref.read(prefsServiceProvider);

  Future<void> saveUserLocally({required UserModel user}) async {
    try {
      await _sqfLite.insertUser(user);
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }

}

final currentUserProvider = AsyncNotifierProvider(() {
  return CurrentUser();
});

class CurrentUser extends AsyncNotifier<UserModel?> {
  CurrentUser();
  late SqfLiteSetup _sqfLite;
  late PrefsService _prefs;
  late FireStoreService _fireStoreService;
  late String? currentLoggedUser;
  @override
  Future<UserModel> build() async {
    try {

      _fireStoreService = ref.read(fireStoreServiceProvider);
      _prefs = ref.read(prefsServiceProvider);
      _sqfLite = ref.read(sqfLiteSetupProvider);
      currentLoggedUser = FirebaseAuth.instance.currentUser?.uid;

      if (currentLoggedUser != null) {

        final userFromDb = await _sqfLite.getUserFromId(currentLoggedUser!);

        if (userFromDb != null) {
          return userFromDb;
        }
      }

      final currentUserId = await _prefs.getCurrentUserId();

      if (currentUserId == null) {

        return UserModel.empty();
      }

      final userFromDb = await _sqfLite.getUserFromId(currentUserId);

      if (userFromDb != null) {

        // ref.read(apiImageProvider).startSmartSync();
        // ref.read(firebaseStreamProvider).startAllListeners(userFromDb.id);
        return userFromDb;
      }

      return UserModel.empty();
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }

  Future<void> saveUserLocally({required UserModel user}) async {
    try {
      await _sqfLite.insertUser(user);
      state = AsyncData(user);
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }


  void copyWith({
    final String? name,
    final String? email,
    final String? id,
    final String? userType,
    final String? photoUrl,
  }) {
    state = AsyncValue.data(
      state.value!.copyWith(
        name: name,
        email: email,
        id: id,
        userType: userType,
        photoUrl: photoUrl,
      ),
    );
  }

  Future<UserModel?> loadUserOnLogin(String id,String email) async {
    try {
      final isInternet = ref.read(isInternetConnectedProvider);
      final isNotify = await _prefs.getIsNotificationOn();
      if(!isInternet) {
        SnackBarService.showMessage("Please check your internet connection");
        return null;
      }
      print('A');
      final user = await _fireStoreService.getUserDetail(id);
      print('A');
      if (user == null){
        return null;
      }

      print('A');
      await _sqfLite.insertUser(user);
      print('A');

      List<SpaceModel> spaces = await _fireStoreService.fetchSpacesFromUser(id);
      print('A');

      for (var space in spaces) {
      print('a');


        await _sqfLite.createSpace(space: space);

        List members = await _fireStoreService.fetchMembersFromSpace(
          spaceId: space.id,
        );
      print('b');

        for (MemberModel mem in members) {
      print('B');
          final newM = MemberModel(
            role: mem.role,
            name: mem.name,
            spaceID: mem.spaceID,
            id: mem.id,
            userId: mem.userId,
            photo: mem.photo,
          );
      print('#@');
          await _sqfLite.addMemberToMembers(member: newM);
        }
      print('#');

        List<ItemModel> items = await _fireStoreService.fetchAllItemsFirebase(
          user.id,
          space.id,
        );
      print('C');
          await _sqfLite.insertItems(  items);
      print('c');
        for (ItemModel item in items) {
      print('D');
           if(isNotify) ref.read(notificationServiceProvider).scheduleNotificationFor(item).catchError((e){});
        }
        await _sqfLite.markSpaceAsSynced(space.id);
      }
      print('E');
      if(state.hasValue && state.value!=null){
        await _sqfLite.changeUserIdOnTransaction(oldId:state.value!.id,newUser : user,email: email);
      }
      print('E');
      state = AsyncData(user);

      return user;
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }

  Future<void> fetchNewName(String userId) async {
    try {
      final isInternet = ref.read(isInternetConnectedProvider);
      if(!isInternet) {
        SnackBarService.showMessage("Please connect to the internet");
        return;
      }
      final newUser = await _fireStoreService.getUserDetail(userId);
      if (newUser == null) {
        SnackBarService.showMessage("something went wrong");

        return;
      }
      if (state.value == null) {
        SnackBarService.showMessage("something went wrong");
        return;
      }
      else{
        state = AsyncData(state.value!.copyWith(name: newUser.name));
      }
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }
}

final loggedInUserProvider = StreamProvider<String?>((ref) async* {
  String? user;
  await for (final firebaseUser in FirebaseAuth.instance.authStateChanges()) {
    user = firebaseUser?.uid;
    yield user;
  }
});
