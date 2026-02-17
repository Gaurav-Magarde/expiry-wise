import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../../../../services/remote_db/fire_store_service.dart';
import '../../../Space/data/model/space_model.dart';
import '../models/user_model.dart';

abstract interface class IUserRemoteDataSource{

  Future<void> saveUserTOFirebase(UserModel user);

  Future<UserModel?> getUserDetail(String userId);


  Future<void> addSpaceToUser({
    required String spaceId,
    required String userId,
  }) ;



  Future<void> addUserTOFirebase(UserModel user);


  Future<List<String>> fetchSpacesFromUser(String id);

  Future<void> removeSpaceFromUser({required String spaceId,required String id});


  void removeSpaceFromUserBatch({required WriteBatch batch, required String spaceId, required String userId}) ;

  Future<void> deleteUserFromFirebase({required String userId}) ;
}


final userRemoteDataSourceProvider = Provider<IUserRemoteDataSource>((ref){
  final fireStore = FirebaseFirestore.instance;

  return UserRemoteDataSourceImpl(instance: fireStore);
});