import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../Space/data/model/space_card_model.dart';
import '../models/member_model.dart';

abstract interface class IMemberLocalDataSource{

  Future<void> addMemberToMembers({required MemberModel member});


  Future<int> fetchMemberCount({required String spaceId});

  Future<SpaceCardModel> fetchMemberBySpace({required String spaceId});

  Future<List<MemberModel>> fetchMemberFromLocal({required String spaceId});

  Future<MemberModel?> fetchSingleMemberFromLocal({required String spaceId,required String userId,});

  Future<List<MemberModel>> fetchAllNonSyncedMember();

  Future<int> deleteMember({required String memberId});

  Future<void> markMemberAsSynced(String id);

  Future<void> markMemberAsUnSynced(String id);

  Future<void> updateMember({required MemberModel member});

  Future<void> deleteAllMember({required String spaceId});

  Future<void> addMembersLocal({required List<MemberModel> members,required Batch batch,});

  Future<void> addMembersToBatch({required List<MemberModel> members,required Batch batch});

  void deleteMembersToBatch({required Batch batch, required String spaceId});

  Future<List<MemberModel>> fetchAllNonSyncedDeletedMember();
}