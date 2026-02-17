import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../User/data/models/user_model.dart';
import '../data/models/member_model.dart';

abstract interface class IMemberRepository{

  Future<List<MemberModel>> fetchAllMemberRemote({spaceId});

  Future<void> addMemberLocal({required MemberModel member,required UserModel user,});

  Future<void> addMemberToSpaceRemote({required MemberModel member});

  Future<void> addMembersLocal({    required Batch batch,
    required List<MemberModel> members,required String spaceId});

  Future<void> removeMemberFromSpaceLocal({
    required String memberId,

  });

  Future<void> removeMemberFromSpaceRemote({
    required MemberModel member,
  });




  Future<void> markMemberAsSynced(String id);
  Future<void> markMemberAsUnSynced(String id);

  Future<List<MemberModel>> getSpaceMembersFromRemote({spaceId});

  Future<void> changeMemberRoleLocal({
    required MemberModel member,
  });

  Future<void> changeMemberRoleRemote({
    required MemberModel member,
  });

  Future<void> removeAllMemberFromSpace({required String spaceId,required UserModel user,});

  Future<MemberModel?> getSpaceMemberFromLocal({required String userId, required String spaceId});

  void removeLocalMemberFromSpaceAtomic({required String spaceId,  required Batch batch});

  void removeMemberFromSpaceRemoteBatch({required String spaceId, required WriteBatch batch});

  Future<int> fetchCountMemberLocal({required String spaceId});

  Future<MemberModel?> getMemberFromRemote({required String spaceId, required String userId});
}