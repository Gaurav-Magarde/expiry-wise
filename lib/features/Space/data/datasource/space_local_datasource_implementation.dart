import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:sqflite/sqflite.dart';

import '../model/space_model.dart';

class SpaceLocalDataSourceImpl implements ISpaceLocalDataSource {
  static const String spaceTable = 'spaces';
  static const String isDeletedColumn = 'is_deleted';
  static const String isSyncedColumn = 'is_synced';
  static const String userIdColumn = 'user_id';
  static const String spaceIdColumn = 'id';
  final SqfLiteSetup sqfLiteSetup;
  SpaceLocalDataSourceImpl({required this.sqfLiteSetup});
  @override
  void createSpaceBatch({required SpaceModel space,required Batch batch}) {
    final map = space.getMap();
    batch.insert(
      spaceTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  @override
  Future<void> createSpace({required SpaceModel space}) async {
    final map = space.getMap();
    final db = await sqfLiteSetup.getDatabase;
    await db.insert(
      spaceTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateSpace({
    required Map<String, dynamic> map,
    required String id,
  }) async {
    try {
      final db = await sqfLiteSetup.getDatabase;
      await db.update(
        spaceTable,
        whereArgs: [id],
        where: '$spaceIdColumn = ?',
        map,
      );
    } catch (e) {
      throw " ";
    }
  }

  @override
  Future<void> addSpacesToBatch({
    required List<SpaceModel> spaces,
    required Batch batch,
  }) async {
    for (final space in spaces) {
      batch.insert(
        spaceTable,
        space.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllSpace({
    required String userId,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$isDeletedColumn= ?',
      whereArgs: [0],
    );
    return map;
  }

  @override
  Future<SpaceModel?> fetchCurrentSpace({
    required String spaceId,
      userId,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$spaceIdColumn = ?AND $isDeletedColumn = ?',
      whereArgs: [spaceId,0],
    );
    if (map.isEmpty) return null;
    final space = SpaceModel.fromMap(map: map.first, userId: userId);
    return space;
  }

  @override
  Future<SpaceModel?> findFirstSpace({required String userId}) async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$isDeletedColumn = ?',
      whereArgs: [0],
      limit: 1,
    );
    if (map.isEmpty) return null;
    final space = SpaceModel.fromMap(map: map.first, userId: userId);

    return space;
  }

  @override
  Future<List<SpaceModel>> findNonSyncedSpace() async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 0',
      whereArgs: [0],
    );
    final list = map
        .map(
          (space) => SpaceModel.fromMap(
            map: space,
            userId: space[userIdColumn] as String,
          ),
        )
        .toList();

    return list;
  }

  @override
  Future<List<SpaceModel>> getNonSyncedDeletedSpaces() async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 1',
      whereArgs: [0],
    );
    final list = map
        .map(
          (space) => SpaceModel.fromMap(
            map: space,
            userId: space[userIdColumn] as String,
          ),
        )
        .toList();

    return list;
  }

  @override
  Future<SpaceModel?> findSpace({
    required String userId,
    required String spaceId,
    int limit = 1,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: '$userIdColumn = ? AND $spaceIdColumn = ?AND $isDeletedColumn = ?',
      whereArgs: [userId, spaceId,0],
      limit: limit,
    );
    if (map.isEmpty) return null;
    final space = SpaceModel.fromMap(map: map.first, userId: userId);

    return space;
  }

  @override
  Future<SpaceModel?> findSpaceBySpaceId({
    required String spaceId,
    int limit = 1,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      spaceTable,
      where: ' $spaceIdColumn = ? AND $isDeletedColumn = ?',
      whereArgs: [spaceId,0],
      limit: limit,
    );
    if (map.isEmpty) return null;
    return SpaceModel.fromMap(map: map.first, userId: '');
  }

  @override
  Future<int> deleteSpace({required String spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.update(
      spaceTable,
      where: '$spaceIdColumn = ?',
      whereArgs: [spaceId],
      {isDeletedColumn: 1},
    );
    return await markSpaceAsUnSynced(spaceId);
  }

  @override
  void deleteSpaceBatch({required Batch batch, required String spaceId}) {
    batch.update(spaceTable, whereArgs: [spaceId], where: '$spaceIdColumn = ?',{isDeletedColumn:1});
  }


  @override
  Future<void> markSpaceAsSynced(String id) async {
    try{
      final db = await sqfLiteSetup.getDatabase;
      await db.update(spaceTable,whereArgs: [id],where: '$spaceIdColumn = ?',{isSyncedColumn : 1});
    }catch(e){
      throw e;
    }
  }
  @override
  Future<int> markSpaceAsUnSynced(String id) async {
    try{
      final db = await sqfLiteSetup.getDatabase;
      return await db.update(spaceTable,whereArgs: [id],where: '$spaceIdColumn = ?',{isSyncedColumn : 0});
    }catch(e){
      rethrow;
    }
  }
}
