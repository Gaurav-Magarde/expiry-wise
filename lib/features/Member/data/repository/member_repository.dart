import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../User/data/models/user_model.dart';

final memberRepoProvider = Provider((ref) {
  final sqf = ref.read(sqfLiteSetupProvider);
  final FireStoreService fireStoreService = ref.read(fireStoreServiceProvider);
  return MemberRepository(sqf, fireStoreService, );
});

class MemberRepository {
  final SqfLiteSetup _sqfLiteSetup;
  final FireStoreService _fireStoreService;

  MemberRepository(
    this._sqfLiteSetup,
    this._fireStoreService,
  );

  Future<List<MemberModel>> fetchAllMemberOfSpace({spaceId}) async {
    try {
      final list = await _sqfLiteSetup.fetchMemberFromLocal(spaceId: spaceId);
      return list;
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

  Future<void> addMemberToLocalSpace({member}) async {
    try {
      await _sqfLiteSetup.addMemberToMembers(member: member);
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
      throw 'something went wrong';
    }
  }

  Future<void> removeMemberFromSpace({
    required bool isInternet,
    required UserModel? user,
    member,
  }) async {
    try {
      if (user == null) {
        SnackBarService.showError(
          'something went wrong!.please try again later',
        );
        return;
      }
      if (!isInternet && user.userType == 'google') {
        SnackBarService.showError(
          'removing member failed.please check internet connection',
        );
        return;
      }
      await _sqfLiteSetup.deleteMember(memberId: member.id);

      if (user.id == member.userId) {
        await _sqfLiteSetup.deleteSpace(spaceId: member.spaceID);
      }
      if (user.userType == 'google') {
        await _fireStoreService.removeMemberFromSpace(member);
      }
      SnackBarService.showMessage('member removed');
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

  Future<void> changeMemberRole({
    required MemberModel member,
    required UserModel? user,
    required bool isInternet,
  }) async {
    try {
      if (user == null || user.id.isEmpty) {
        SnackBarService.showError('user not found');
        return;
      }

      final String changeRoleTO = member.role == 'admin' ? 'member' : 'admin';
      final map = {'role': changeRoleTO};
      if (!isInternet && user.userType == 'google') {
        SnackBarService.showError(
          'role changed failed.please check internet connection',
        );
        return;
      }
      await _sqfLiteSetup.updateMember(member: member, map: map);
      if (user.userType == 'google') {
        await _fireStoreService.changeMemberRole(member, changeRoleTO);
      }
      SnackBarService.showSuccess(
        ' ${member.name}\'s role changed successfully',
      );
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
}
