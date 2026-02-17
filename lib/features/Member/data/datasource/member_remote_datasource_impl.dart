import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../Space/data/model/space_model.dart';
import '../models/member_model.dart';

final memberRemoteDataSourceProvider = Provider<IMemberRemoteDataSource>((ref) {
  return MemberRemoteDataSourceImpl();
});

class MemberRemoteDataSourceImpl implements IMemberRemoteDataSource {
  static const String memberCollection = 'member';
  static const String spaceCollection = 'spaces';
  static const String memberIdKey = 'id';
  static const String spaceIdKey = 'space_id';
  static const String userIdKey = 'user_id';
  static const String isDeletedKey = 'is_deleted';
  static const String updatedAtKey = 'updated_at';
  static const String isSyncedKey = 'is_synced';

  final FirebaseFirestore instance = FirebaseFirestore.instance;

  @override
  Future<SpaceModel?> addMemberToSpace({required MemberModel member}) async {
    try {
      final docRefMember = instance
          .collection(spaceCollection)
          .doc(member.spaceID)
          .collection(memberCollection);

      final memberMap = member.toMap();

      memberMap[isSyncedKey] = 1;
      await docRefMember.doc(member.id).set(memberMap, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
    return null;
  }

  @override
  Future<List<MemberModel>> fetchMembersFromSpace({required spaceId}) async {
    try {
      final docRef  = instance
          .collection(spaceCollection)
          .doc(spaceId)
          .collection(memberCollection).where(isDeletedKey,isNotEqualTo: true);
      final doc = await docRef.get();
      List<MemberModel> memberList = [];
      for(final docs in doc.docs){
        final map = docs.data();
        final member = MemberModel.fromLocal(map);
        memberList.add(member);
      }
      return memberList;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<MemberModel?> fetchSingleMemberFromSpace({
    required String spaceId,
    required String userId,
  }) async {
    try {
      final docRef  = instance
        .collection(spaceCollection)
        .doc(spaceId)
        .collection(memberCollection).where(userIdKey,isEqualTo: userId).where(isDeletedKey,isEqualTo: false);
    final doc = await docRef.get();
    for(final docs in doc.docs){
      final map = docs.data();
      return MemberModel.fromLocal(map);
    }
      return null;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'something went wrong';
    }
  }

  @override
  Future<void> removeMemberFromSpace(MemberModel member) async {
    try {
      await instance
          .collection(spaceCollection)
          .doc(member.spaceID)
          .collection(memberCollection)
          .doc(member.id)
          .update({isDeletedKey:true});

    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<void> changeMemberRole({required MemberModel member}) async {
    try {
      final docRef = instance
          .collection(spaceCollection)
          .doc(member.spaceID)
          .collection(memberCollection)
          .doc(member.id);
      await docRef.update(member.toMap());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<void> removeAllMemberFromSpace({required String spaceId}) async {

  }

  @override
  void removeAllMemberFromSpaceBatch({
    required String spaceId,
    required WriteBatch batch,
  }) {
    final doc = instance
        .collection(spaceCollection)
        .doc(spaceId)
        .collection(memberCollection).get();
    {
      // batch.update(docRefMember, {isDeletedKey: true});
    }
  }
}
