import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/network/network_info.dart';
import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Member/domain/member_repository_interface.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../User/data/models/user_model.dart';

final memberRepoProvider = Provider<IMemberRepository>((ref) {
  final networkInfo = ref.read(networkInfoProvider);
  final IMemberLocalDataSource memberLocalData = ref.read(
    memberLocalDataSourceProvider,
  );
  final IMemberRemoteDataSource memberRemoteDataSource = ref.read(
    memberRemoteDataSourceProvider,
  );

  return MemberRepositoryImpl(
    memberLocalDataSource: memberLocalData,
    memberRemoteDataSource: memberRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class MemberRepositoryImpl implements IMemberRepository {
  final NetworkInfo networkInfo;
  final IMemberLocalDataSource memberLocalDataSource;

  final IMemberRemoteDataSource memberRemoteDataSource;

  MemberRepositoryImpl({
    required this.memberRemoteDataSource,
    required this.networkInfo,
    required this.memberLocalDataSource,
  });

  @override
  Future<List<MemberModel>> fetchAllMemberRemote({spaceId}) async {
    try {
      final list = await memberRemoteDataSource.fetchMembersFromSpace(
        spaceId: spaceId,
      );
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

  @override
  Future<List<MemberModel>> getSpaceMembersFromRemote({spaceId}) async {
    try {
      final list = await memberRemoteDataSource.fetchMembersFromSpace(
        spaceId: spaceId,
      );
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

  @override
  Future<void> addMemberLocal({
    required MemberModel member,
    required UserModel user,
  }) async {
    try {
      await memberLocalDataSource.addMemberToMembers(member: member);
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

  @override
  Future<void> addMemberToSpaceRemote({required MemberModel member}) async {
    try {
      await memberRemoteDataSource.addMemberToSpace(member: member);
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

  @override
  Future<void> removeMemberFromSpaceLocal({
    required String memberId,
  }) async {
    try {

      await memberLocalDataSource.deleteMember(memberId: memberId);

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

  @override
  Future<void> changeMemberRoleLocal({
    required MemberModel member,
  }) async {
    try {
          await memberLocalDataSource.updateMember(member: member);

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
  @override
  Future<void> changeMemberRoleRemote({
    required MemberModel member,
  }) async {
    try {
      final isInternet = await networkInfo.checkInternetStatus;
      if(!isInternet){
        throw Exception('no internet connection');
      }
      await memberRemoteDataSource.changeMemberRole(member: member);

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

  @override
  Future<void> removeAllMemberFromSpace({
    required String spaceId,
    required UserModel user,
  }) async {
    final isInternet = await networkInfo.checkInternetStatus;

    await memberLocalDataSource.deleteAllMember(spaceId: spaceId);
    if (isInternet && user.userType == 'google') {
      await memberRemoteDataSource.removeAllMemberFromSpace(spaceId: spaceId);
    }
  }

  @override
  Future<void> removeMemberFromSpaceRemote({
    required MemberModel member,
  }) async {
    final isInternet = await networkInfo.checkInternetStatus;

    if (isInternet) {
      await memberRemoteDataSource.removeMemberFromSpace(member);
    }
  }

  @override
  Future<void> addMembersLocal({
    required List<MemberModel> members,
    required String spaceId,
    required Batch batch,
  }) async {
    await memberLocalDataSource.addMembersLocal(members: members,batch: batch);
  }

  @override
  Future<MemberModel?> getSpaceMemberFromLocal({
    required String userId,
    required String spaceId,
  }) async {
    return await memberLocalDataSource.fetchSingleMemberFromLocal(
      spaceId: spaceId,
      userId: userId,
    );
  }

  @override
  void removeLocalMemberFromSpaceAtomic({required String spaceId, required Batch batch}) {
    memberLocalDataSource.deleteMembersToBatch(batch: batch, spaceId: spaceId);
  }

  @override
  void removeMemberFromSpaceRemoteBatch({required String spaceId, required WriteBatch batch}) {
    memberRemoteDataSource.removeAllMemberFromSpaceBatch(spaceId: spaceId,batch:batch);
  }

  @override
  Future<void> markMemberAsSynced(String id) async {
    await memberLocalDataSource.markMemberAsSynced(id);
  }

  @override
  Future<void> markMemberAsUnSynced(String id) async {
    await memberLocalDataSource.markMemberAsUnSynced(id);
  }

  @override
  Future<int> fetchCountMemberLocal({required String spaceId}) async {
    return await memberLocalDataSource.fetchMemberCount(spaceId:spaceId);
  }

  @override
  Future<MemberModel?> getMemberFromRemote({required String spaceId, required String userId}) async {
    return await memberRemoteDataSource.fetchSingleMemberFromSpace(spaceId: spaceId, userId: userId);
  }

  Future<List<MemberModel>> getNonSyncedMember() async {
    return await memberLocalDataSource.fetchAllNonSyncedMember();
  }

  Future<List<MemberModel>> getNonSyncedDeletedMember() async {
    return await memberLocalDataSource.fetchAllNonSyncedDeletedMember();
  }

}
