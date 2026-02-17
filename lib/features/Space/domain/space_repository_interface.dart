import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

import '../../Member/data/models/member_model.dart';
import '../../User/data/models/user_model.dart';
import '../data/model/space_model.dart';

abstract interface class ISpaceRepository{

  Future<SpaceModel?> createSpace({
    required UserModel user,
    required SpaceModel space,
  }) ;


  Future<SpaceModel?> createSpaceRemote({
    required UserModel user,
    required SpaceModel space,
  }) ;

  void createSpaceLocal({
    required SpaceModel space, required Batch batch,
  });

  Future<void> addSpaceToFirebase({
    required String userId,
    required SpaceModel space,
    UserModel? user,
  });

  Future<List<SpaceModel>> fetchAllSpaces({required String userId});

  void deleteLocalSpaceAtomic({
    required String spaceId,required Batch batch,
  });

  Future<void> changeCurrentSpace({required String spaceID});

  Future<void> updateSpace( {
    required UserModel user,
    required SpaceModel space,}) ;

  Future<SpaceModel?> fetchSpaceLocal({required String spaceId, required String userId}) ;

  Future<SpaceModel?> fetchSpaceRemote({required String spaceId});

  Future<SpaceModel?> getFirstSpace({required String userId});

  void deleteRemoteSpaceAtomic({required String spaceId, required WriteBatch batch});


  Future<void> markSpaceAsSynced(String id) ;
  Future<void> markSpaceAsUnSynced(String id);

  Future<List<SpaceModel>> getSpacesRemote({required List<String> spaceId});
}