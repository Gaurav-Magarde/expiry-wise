import 'package:expiry_wise_app/core/utils/loaders/image_api.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../User/data/models/user_model.dart';

final spaceRepoProvider = Provider<SpaceRepository>((ref) {
  final fireStore = ref.read(fireStoreServiceProvider);
  final sqfRepo = ref.read(sqfLiteSetupProvider);
  final prefs = ref.read(prefsServiceProvider);
  return SpaceRepository(ref, fireStore, sqfRepo, prefs);
});

class SpaceRepository {
  final Ref ref;
  final FireStoreService _fireStoreService;
  final SqfLiteSetup _sqfRepo;
  final PrefsService _prefs;
  SpaceRepository(
    this.ref,
    this._fireStoreService,
    this._sqfRepo,
    this._prefs,
  );

  Future<SpaceModel?> createSpace({
    required UserModel user,
    String? spaceName,
    String? isUser,
    required bool isInternet
  }) async {
    try{
      final sqf = ref.read(sqfLiteSetupProvider);
      final prefs = ref.read(prefsServiceProvider);
      final memberRepository = ref.read(memberRepoProvider);
      final id = Uuid().v4();
      final mId = Uuid().v4();
      if(user.id.isEmpty ){
        SnackBarService.showError('user not found');
        return null;
      }

      final space = SpaceModel(
        userId: user.id,
        name: spaceName ?? "My Space",
        id: id,
        updatedAt: DateTime.now().toString()
      );
      await sqf.createSpace(space: space);

      final member = MemberModel(
        photo: user.photoUrl,
        name: user.name,
        spaceID: space.id,
        id: mId,
        userId: user.id,
        role: MemberRole.admin.name,
      );
      await memberRepository.addMemberToLocalSpace(member: member);
      await prefs.changeCurrentSpace(space.id);

      if (isInternet && user.userType == 'google') {
        await addSpaceToFirebase(space: space,
            userId: user.id,
            isInternet: isInternet,
            user: user);
        await _fireStoreService.addMemberToSpace(
            member: member
        );
      }
      return space;
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

  Future<void> addSpaceToFirebase({
    required String userId,
    required SpaceModel space,
    UserModel? user,
    required bool isInternet
  }) async {
    try {

      if(isInternet && user!=null && user.userType=='google') {
        await _fireStoreService.insertSpaceTOFirebase(userId, space);
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

  Future<List<SpaceModel>> fetchAllSpaces({required String userId}) async {
    try {
      final sqf = ref.read(sqfLiteSetupProvider);
      final map = await sqf.fetchAllSpace(userId: userId);
      final list = map.map((map) => SpaceModel.fromMap(map: map,userId:userId )).toList();
      return list;
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

  Future<int> deleteSpace({
    required String spaceId,
    required String userId,

    UserModel? user,
    required bool isInternet
  }) async {
    try {
      if(user==null || user.id.isEmpty){
        SnackBarService.showError('user not fount');
        return 0;
      }
      if(user.userType == 'google' && !isInternet ) {
        SnackBarService.showMessage('space delete failed. please connect to the internet');
        return 0;
      }
      if(user.userType == 'google') await _fireStoreService.deleteSpaceFromFirebase(spaceId: spaceId);
      final rows = await _sqfRepo.deleteSpace( spaceId: spaceId);
      SnackBarService.showSuccess('space deleted');
       ref.invalidate(currentSpaceProvider);
      return 1;
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

  Future<void> changeCurrentSpace({required String spaceID}) async {
    try{
      await _prefs.changeCurrentSpace(spaceID);
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

  Future<void> joinNewSpace({
    required MemberModel member,

    UserModel? isUser,
    required bool isInternet
  }) async {
    try {
      final spaceId = member.spaceID;
      final userId = member.userId;
      if(!isInternet ) {
        SnackBarService.showMessage('Please check internet connection');
        return;
      }
      if(isUser==null || isUser.id.isEmpty) {
        SnackBarService.showMessage('user not found');
        return;
      }
      if(isUser.userType=='guest' ) {
        SnackBarService.showMessage('Please login first to join spaces');
        return;
      }


      final bool isExist = await _fireStoreService.isExist(
        collection: "spaces",
        doc: spaceId,
      );

      if (!isExist) {
        SnackBarService.showError('Please enter valid code');
        return;
      }

      final isSpace = await _sqfRepo.findSpace(
        spaceId: spaceId,
        userId: userId,
        limit: 1,
      );

      if (isSpace != null) {
        SnackBarService.showSuccess('Already part of the space');
        return;
      }
      final space = await _fireStoreService.addMemberToSpace(
       member: member
      );

      await _sqfRepo.createSpace(space: space!);

      await ref.read(currentSpaceProvider.notifier).changeCurrentSpace(space: space);
      final imageController  = ref.read(apiImageProvider);

      await _sqfRepo.markSpaceAsSynced(space.id);

      final list = await _fireStoreService.fetchAllItemsFirebase(
        userId,
        spaceId,
      );

      await _sqfRepo.insertItems(list);

      for (var item in list) {
        await _sqfRepo.markItemAsSynced(item.id);
      }

      List members = await _fireStoreService.fetchMembersFromSpace(userId,
        spaceId: spaceId,
      );

      for (MemberModel mem in members) {



        await _sqfRepo.addMemberToMembers(member: mem);

        await _sqfRepo.markMemberAsSynced(mem.id);
      }
      SnackBarService.showMessage('Space joined successfully');
      return;
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

  Future<void> changeSpaceName( {required bool isInternet,required UserModel? user,required String spaceId, required String newName}) async {
    try{
      if(user==null||user.id.isEmpty){
        SnackBarService.showError('user not found');
        return;
      }
      if(user.userType == 'google' && !isInternet){
        SnackBarService.showError('name change failed. please connect to the internet');
        return;
      }
        final map = {'name':newName};
      if(user.userType=='google') await _fireStoreService.updateSpaceFromFirebase(map: map, id: spaceId);
      await _sqfRepo.updateSpace(map: map, id: spaceId);
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
