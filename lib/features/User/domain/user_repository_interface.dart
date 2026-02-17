import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/data/repository/user_repository_impl.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite_common/sqlite_api.dart';
import '../data/models/user_model.dart';


abstract interface class IUserRepository {


  String? get currentLoggedInUser;
  Future<void> saveUserLocally({required UserModel user});

  Future<void> addSpaceToUserRemote({
    required UserModel user,
    required String spaceId,
  });

  Future<void> removeSpaceFromUser({
    required UserModel user,
    required String spaceId,
  });

  void removeSpaceFromUserRemoteBatch({
    required UserModel user,
    required String spaceId,
    required WriteBatch batch,
  });

  Future<UserModel?> getUserFromIdLocal({required String userId});

  Future<void> deleteUserFromRemote({required String userId});

  Future<List<String>> fetchSpacesFromUserRemote(String id);

  Future<void> addUserToRemote({required UserModel user});

  Future<UserModel?> getUserDetailRemote({required String id});

  Future<void> saveUserToRemote({required UserModel user});

  Future<void> updateUserLocal(Map<String, dynamic> map, String userId);

  Future<void> markUserAsSynced(String id) ;

  Future<void> markUserAsUnSynced(String id) ;

  void saveUserLocalBatch({required UserModel user, required Batch batch});

}

final userRepoProvider = Provider<IUserRepository>((ref){
  final userLocalDataSource = ref.read(userLocalDataSourceProvider);
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return UserRepositoryImpl(networkConnection: networkInfo,userLocalDataSource: userLocalDataSource, userRemoteDataSource: userRemoteDataSource);
});