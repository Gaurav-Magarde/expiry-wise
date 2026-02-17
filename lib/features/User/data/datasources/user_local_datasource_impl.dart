import 'package:sqflite_common/sqlite_api.dart';

import '../models/user_model.dart';

abstract interface class IUserLocalDataSource{



  Future<void> insertUser(UserModel user);

  Future<UserModel?> getUserFromId(String currentUserId);
  Future<List<UserModel>> getUsersDeleted();
  Future<List<UserModel>> getUserNotSynced();
  Future<List<UserModel>> fetchNonSyncedDeletedUsers();

  Future<void> updateUser(Map<String, dynamic> map, String userId);

  Future<void> markUserAsUnSynced(String id);
  Future<void> markUserAsSynced(String id);

  void insertUserBatch(UserModel user, Batch batch);
}