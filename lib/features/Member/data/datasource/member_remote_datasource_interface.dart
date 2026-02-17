import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Space/data/model/space_model.dart';
import '../models/member_model.dart';

abstract interface class IMemberRemoteDataSource{


  Future<SpaceModel?> addMemberToSpace({
    required MemberModel member
  }) ;


  Future<List<MemberModel>> fetchMembersFromSpace({required spaceId});

  Future<MemberModel?> fetchSingleMemberFromSpace({required String spaceId, required String userId});

  Future<void> removeMemberFromSpace(MemberModel member);

  Future<void> changeMemberRole( {required MemberModel member}) ;


  Future<void> removeAllMemberFromSpace({required String spaceId});

  void removeAllMemberFromSpaceBatch({required String spaceId, required WriteBatch batch}) {}

}