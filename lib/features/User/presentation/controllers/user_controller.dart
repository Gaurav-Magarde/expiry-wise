import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/services.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_inteface.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/routes/presentation/controllers/route_controller.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/snackbars/snack_bar_service.dart';
import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../Member/data/datasource/member_local_datasource_interface.dart';
import '../../data/models/user_model.dart';

final currentUserProvider = AsyncNotifierProvider(() {
  return CurrentUser();
});

class CurrentUser extends AsyncNotifier<UserModel?> {
  CurrentUser();
  late PrefsService _prefs;
  late IUserRepository userRepository;
  @override
  Future<UserModel> build() async {

    try{
      _prefs = ref.read(prefsServiceProvider);
      userRepository = ref.read(userRepoProvider);
      final currentLoggedUser = userRepository.currentLoggedInUser;
      if (currentLoggedUser != null) {
        final userFromDb = await userRepository.getUserFromIdLocal(
          userId: currentLoggedUser
        );
        if (userFromDb != null) {
          return userFromDb;
        }
      }
      final currentUserId = await _prefs.getCurrentUserId();
      if (currentUserId == null) {
        return UserModel.empty();
      }
      final userFromDb = await userRepository.getUserFromIdLocal(
        userId: currentUserId,
      );
      if(kDebugMode){
        print('user from db $currentUserId ${userFromDb?.toMap()}userFromDb');
      }
      if (userFromDb != null) {
        // ref.read(apiImageProvider).startSmartSync();
        // ref.read(firebaseStreamProvider).startAllListeners(userFromDb.id);

        return userFromDb;
      }

      return UserModel.empty();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<void> saveUserLocally({required UserModel user}) async {
    try{
      await userRepository.saveUserLocally(user: user);
      state = AsyncData(user);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw const TExceptions().message;
    } catch (e) {
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

  Future<UserModel?> loadUserOnLogin(String id, String email) async {
    try {
      final user = await ref
          .read(userServiceProvider)
          .loadUserOnLogin(id, email);
      state = AsyncData(user);

      return user;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<void> fetchNewName(String userId) async {
    try {
      final newUser = await userRepository.getUserDetailRemote(id: userId);
      if (newUser == null) {
        SnackBarService.showMessage('user not found');

        return;
      }
      if (state.value == null) {
        SnackBarService.showMessage('something went wrong');
        return;
      } else {
        state = AsyncData(state.value!.copyWith(name: newUser.name));
      }
    } catch (e) {
      SnackBarService.showError('some thing went wrong ${e.toString()}');
    }
  }

  Future<void> changeName(newName) async {
    try {
      final user = ref.read(currentUserProvider).value;
      await ref.read(userServiceProvider).changeName(newName: newName, user: user);
      ref.invalidate(currentUserProvider);
    } catch (e) {
      SnackBarService.showError('Name changed failed ');
    }
  }

  Future<void> toggleAutoSync(bool autoSync) async {
    final user = ref.read(currentUserProvider).value;
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
      return;
    }
    if (user.userType == 'guest') {
     throw Exception(
        'please login first to auto sync the items!',
      );
    }
    final prefs = ref.read(prefsServiceProvider);
    await prefs.setAutoSync(autoSync);
  }
}
