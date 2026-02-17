import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_impl.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class UserLocalDataSourceImpl implements IUserLocalDataSource{


  final SqfLiteSetup sqfLiteSetup;
  UserLocalDataSourceImpl({required this.sqfLiteSetup});

  static const String usersTable = 'users';
  static const String isDeletedColumn = ' is_deleted';
  static const String isSyncedColumn = ' is_synced';
  static const String spaceIdColumn = 'space_id';
  static const String userIdColumn = 'id';

  @override
  Future<void> insertUser(UserModel user) async {
    try {
      final db = await sqfLiteSetup.getDatabase;
      final map = user.toMap();
      await db.insert(
        usersTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      final d = await db.query(usersTable);
      print(d);
      print('=======================++++++++++++++++++=======================');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> insertUserBatch(UserModel user,Batch batch) async {
    try {
      final map = user.toMap();
      batch.insert(
        usersTable,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel?> getUserFromId(String currentUserId) async {
    try {
      print("strt");
      final db = await sqfLiteSetup.getDatabase;


      final List<Map<String, dynamic>> map = await db.query(
        usersTable,
        where: '$userIdColumn = ? And $isDeletedColumn = ?',
        whereArgs: [currentUserId,0],
        limit: 1,
      );
      final D = await db.query(usersTable);
      print(D);
      for(final userMap in D){
        print('----------------------------------');
        print(userMap);
        print('--------------------------------');

      }
      if (map.isEmpty) {
        return null;
      } else {

        return UserModel.fromMap(map.first);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<List<UserModel>> getUsersDeleted() async {
    try {
      final db = await sqfLiteSetup.getDatabase;

      final List<Map<String, dynamic>> map = await db.query(
          usersTable,
          where: '$isDeletedColumn = ?',
          whereArgs: [1]
      );
      final list = map.map((user){
        return UserModel.fromMap(user);
      }).toList();
      return list;
    } catch (e) {
      throw Exception("");
    }
  }


  @override
  Future<List<UserModel>> getUserNotSynced() async {
    try {
      final db = await sqfLiteSetup.getDatabase;

      final List<Map<String, dynamic>> map = await db.query(
          usersTable,
          where: '$isSyncedColumn = ? AND $isDeletedColumn = 0',
          whereArgs: [0]
      );
      final list = map.map((user){
        return UserModel.fromMap(user);
      }).toList();
      return list;
    } catch (e) {
      throw Exception("");
    }
  }
  @override
  Future<List<UserModel>> fetchNonSyncedDeletedUsers() async {
    try {
      final db = await sqfLiteSetup.getDatabase;

      final List<Map<String, dynamic>> map = await db.query(
          usersTable,
          where: '$isSyncedColumn = ? AND $isDeletedColumn = 1',
          whereArgs: [0]
      );
      final list = map.map((user){
        return UserModel.fromMap(user);
      }).toList();
      return list;
    } catch (e) {
      throw Exception("");
    }
  }

  @override
  Future<void> updateUser(Map<String, dynamic> map, String userId) async {
    final db = await sqfLiteSetup.getDatabase;
      await db.update(usersTable, where: '$userIdColumn = ?',whereArgs: [userId],map);
  }

  @override
  Future<void> markUserAsSynced(String id) async {
    try{
      final db = await sqfLiteSetup.getDatabase;
      db.update(usersTable,whereArgs: [id],where: '$userIdColumn = ?',{isSyncedColumn : 1});
    }catch(e){
      throw " ";
    }
  }

  @override
  Future<void> markUserAsUnSynced(String id) async {
    try{
      final db = await sqfLiteSetup.getDatabase;
      db.update(usersTable,whereArgs: [id],where: '$userIdColumn = ?',{isSyncedColumn : 0});
    }catch(e){
      throw e;
    }
  }
}


final userLocalDataSourceProvider = Provider<IUserLocalDataSource>((ref){
  final sqf = ref.read(sqfLiteSetupProvider);
  return UserLocalDataSourceImpl(sqfLiteSetup: sqf);
});