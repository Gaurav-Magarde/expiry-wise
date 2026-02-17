import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_remote_data_source.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_interface.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';


final providerRemoteTransactionManager = Provider<RemoteTransactionManager>((ref){

  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);
  final spaceRemoteDataSource = ref.read(spaceRemoteDataSourceProvider);
  return RemoteTransactionManager(userRemoteDataSource: userRemoteDataSource,  spaceRemoteDataSource: spaceRemoteDataSource);
});

class RemoteTransactionManager{
  final ISpaceRemoteDataSource spaceRemoteDataSource;
  final IUserRemoteDataSource userRemoteDataSource;
  const RemoteTransactionManager(
      {required this.userRemoteDataSource, required this.spaceRemoteDataSource});



  Future<void> deleteSpaceDataAtomic({
    required String spaceId,
    required String userId,
  }) async {
    try{
      final batch = FirebaseFirestore.instance.batch();
      spaceRemoteDataSource.deleteSpaceFromFirebaseBatch(batch: batch,spaceId: spaceId);
      userRemoteDataSource.removeSpaceFromUserBatch(batch: batch,spaceId: spaceId,userId: userId);
      await batch.commit();
    }catch(e){};
  }

  Future<void> executeAtomic(Function (WriteBatch batch) action) async {
    final batch = FirebaseFirestore.instance.batch();
    action(batch);
    await batch.commit();
  }
}