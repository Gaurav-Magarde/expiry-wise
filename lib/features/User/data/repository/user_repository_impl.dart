import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements IUserRepository{
  UserRepositoryImpl({required this.userRemoteDataSource,required this.networkConnection,required this.userLocalDataSource});
  final IUserRemoteDataSource userRemoteDataSource;
  final NetworkInfoImpl networkConnection;

  final IUserLocalDataSource userLocalDataSource;
  @override
  Future<void> saveUserLocally({required UserModel user}) async {
    try {
      await userLocalDataSource.insertUser(user);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<void> addSpaceToUserRemote({
    required UserModel user,
    required String spaceId,
  }) async {
    try {
      await userRemoteDataSource.addSpaceToUser(userId: user.id, spaceId: spaceId);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<void> removeSpaceFromUser({
    required UserModel user,
    required String spaceId,
  }) async {
    try {
      await userRemoteDataSource.removeSpaceFromUser(id: user.id, spaceId: spaceId);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw const TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  void removeSpaceFromUserRemoteBatch({required UserModel user, required String spaceId, required WriteBatch batch,}) {
    userRemoteDataSource.removeSpaceFromUserBatch(spaceId: spaceId, batch: batch, userId: user.id);
  }

  @override
  Future<UserModel?> getUserFromIdLocal({required String userId}) async {
    return await userLocalDataSource.getUserFromId(userId);
  }

  @override
  Future<void> deleteUserFromRemote({required String userId}) async {
    final isInternet = await networkConnection.checkInternetStatus;
    if(isInternet){
      await userRemoteDataSource.deleteUserFromFirebase(userId: userId);
    }
    else{
      throw Exception('No Internet Connection');
    }
  }

  @override
  Future<List<String>> fetchSpacesFromUserRemote(String id) async {
    return await userRemoteDataSource.fetchSpacesFromUser(id);
  }

  Future<List<UserModel>> fetchNonSyncedUsers() async {
    return await userLocalDataSource.getUserNotSynced();
  }
  Future<List<UserModel>> fetchNonSyncedDeletedUsers() async {
    return await userLocalDataSource.getUsersDeleted();
  }

  @override
  Future<void> addUserToRemote({required UserModel user}) async {
    await userRemoteDataSource.addUserTOFirebase(user);
  }

  @override
  Future<UserModel?> getUserDetailRemote({required String id})  async{
    return await userRemoteDataSource.getUserDetail(id);
  }

  @override
  Future<void> saveUserToRemote({required UserModel user}) async {
    await userRemoteDataSource.saveUserTOFirebase(user);
  }

  @override
  Future<void> updateUserLocal(Map<String, dynamic> map, String userId) async {
   await userLocalDataSource.updateUser(map,userId);
  }

  @override
  Future<void> markUserAsSynced(String id) async {
    await userLocalDataSource.markUserAsSynced(id);

  }

  @override
  Future<void> markUserAsUnSynced(String id) async {
    await userLocalDataSource.markUserAsUnSynced(id);
  }

  @override
  String? get currentLoggedInUser => FirebaseAuth.instance.currentUser?.uid;

  @override
  void saveUserLocalBatch({required UserModel user, required Batch batch}) {
    userLocalDataSource.insertUserBatch(user,batch);
  }



}