import 'package:expiry_wise_app/features/Space/data/datasource/space_local_datasource_implementation.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../model/space_model.dart';

abstract interface class ISpaceLocalDataSource{



  void createSpaceBatch({required SpaceModel space, required Batch batch});

  Future<void> createSpace({required SpaceModel space});

  Future<List<Map<String, dynamic>>> fetchAllSpace({
    required String userId,
  });

  Future<void> updateSpace({required Map<String, dynamic> map, required String id});

  Future<SpaceModel?> fetchCurrentSpace({required String spaceId,userId});


  Future<SpaceModel?> findFirstSpace({required String userId}) ;

  Future<List<SpaceModel>> findNonSyncedSpace();

  Future<SpaceModel?> findSpace({
    required String userId,
    required String spaceId,
    int limit = 1,
  }) ;


  Future<SpaceModel?> findSpaceBySpaceId({

    required String spaceId,
    int limit = 1,
  }) ;


  Future<int> deleteSpace({required String spaceId});


  Future<void> addSpacesToBatch({required List<SpaceModel> spaces,required Batch batch});

  void deleteSpaceBatch({required Batch batch, required String spaceId});

  Future<void> markSpaceAsUnSynced(String id);

  Future<void> markSpaceAsSynced(String id);

  Future<List<SpaceModel>> getNonSyncedDeletedSpaces();
}


final spaceLocalDataSourceProvider = Provider<ISpaceLocalDataSource>((ref) {
  final sqf = ref.watch(sqfLiteSetupProvider);

    return SpaceLocalDataSourceImpl(sqfLiteSetup: sqf);
});
