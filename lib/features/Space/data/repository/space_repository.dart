import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_remote_data_source.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/Space/domain/space_repository_interface.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/exception/repository_error_handler.dart';
import '../../../User/data/models/user_model.dart';


final spaceRepoProvider = Provider<ISpaceRepository>((ref) {
  final prefs = ref.read(prefsServiceProvider);
  final localDataBase = ref.watch(spaceLocalDataSourceProvider);
  final networkConnection = ref.watch(networkInfoProvider);
  final remoteDataBase = ref.watch(spaceRemoteDataSourceProvider);
  return SpaceRepository(
    networkConnection: networkConnection,
    remoteDataSource: remoteDataBase,
    localDataSource: localDataBase,
    prefs: prefs,
  );
});


class SpaceRepository with RepositoryErrorHandler implements ISpaceRepository{

  final PrefsService prefs;
  final ISpaceLocalDataSource localDataSource;
  final NetworkInfo networkConnection;
  final ISpaceRemoteDataSource remoteDataSource;
  SpaceRepository({
    required this.localDataSource,
    required this.networkConnection,
    required this.remoteDataSource,
    required this.prefs,
  });

  @override
  Future<SpaceModel?> createSpace({
    required UserModel user,
    required SpaceModel space,
  }) async {
    return await safeCall(() async {
      final isInternet = await networkConnection.checkInternetStatus;

      await localDataSource.createSpace(space: space);

      if (isInternet && user.userType == 'google') {
        await remoteDataSource.insertSpaceTOFirebase(user.id, space);
      }
      return space;
    });
  }

  @override
  Future<SpaceModel?> createSpaceRemote({
    required UserModel user,
    required SpaceModel space,
  }) async {
    return await safeCall(() async {
      final isInternet = await networkConnection.checkInternetStatus;
      if (isInternet && user.userType == 'google') {
        await remoteDataSource.insertSpaceTOFirebase(user.id, space);
      }
      return space;
    });
  }
  @override
  void createSpaceLocal({
    required SpaceModel space,
    required Batch batch,
  }) {

      localDataSource.createSpaceBatch(space: space,batch:batch);

  }


  @override
  Future<void> addSpaceToFirebase({
    required String userId,
    required SpaceModel space,
    UserModel? user,
  }) async {
    return await safeCall(() async {
      final isInternet = await networkConnection.checkInternetStatus;
      if (isInternet && user != null && user.userType == 'google') {
        await remoteDataSource.insertSpaceTOFirebase(userId, space);
      }
    });
  }

  @override
  Future<List<SpaceModel>> fetchAllSpaces({required String userId}) async {
    return await safeCall(() async {
      final map = await localDataSource.fetchAllSpace(userId: userId);
      final list = map
          .map((map) => SpaceModel.fromMap(map: map, userId: userId))
          .toList();
      return list;
    });
  }

  @override
  Future<SpaceModel?> fetchSpaceLocal({required String userId,required String spaceId}) async {
    return await safeCall(() async {
      final space = await localDataSource.findSpace(spaceId: spaceId,userId: userId);
      return space;
    });
  }



  @override
  Future<void> changeCurrentSpace({required String spaceID}) async {
    return await safeCall(() async {
      await prefs.changeCurrentSpace(spaceID);
    });
  }


  @override
  Future<void> updateSpace({
    required UserModel user,
    required SpaceModel space,
  }) async {
    await safeCall(() async {

      final isInternet = await networkConnection.checkInternetStatus;

      await localDataSource.updateSpace(map: space.toMap(), id: space.id);
      if (user.userType == 'google' && isInternet) {
        await remoteDataSource.updateSpaceFromFirebase(map: space.toMap(), id: space.id);
      }
    });
  }


  Future<SpaceModel?> findFirstSpace({required String userId}) async {
    return await safeCall(() async {
      return await localDataSource.findFirstSpace(userId: userId);
    });
  }

  @override
  Future<SpaceModel?> fetchSpaceRemote({required String spaceId}) async {
     return await safeCall(() async {

        final isInternet = await networkConnection.checkInternetStatus;

        if (isInternet) {
          return await remoteDataSource.spaceDetailById(id: spaceId);
        }
      });
  }

  @override
  Future<SpaceModel?> getFirstSpace({required String userId}) async {

    return await safeCall(() async {

      return await findFirstSpace(userId: userId);
    });

  }

  @override
  void deleteLocalSpaceAtomic({required String spaceId, required Batch batch}) {
    localDataSource.deleteSpaceBatch(batch: batch, spaceId: spaceId);
  }

  @override
  void deleteRemoteSpaceAtomic({required String spaceId, required WriteBatch batch}) {
remoteDataSource.deleteSpaceFromFirebaseBatch(spaceId: spaceId, batch: batch);
  }

  @override
  Future<void> markSpaceAsSynced(String id) async {
    await localDataSource.markSpaceAsSynced(id);
  }

  @override
  Future<void> markSpaceAsUnSynced(String id) async {
    await localDataSource.markSpaceAsUnSynced(id);
  }

  @override
  Future<List<SpaceModel>> getSpacesRemote({required List<String> spaceId}) async{
    return await remoteDataSource.getSpaces(spaceId);
  }

  Future<List<SpaceModel>> getNonSyncedSpaces() async{
    return await localDataSource.findNonSyncedSpace();
  }

  Future<List<SpaceModel>> getNonSyncedDeletedSpaces() async{
    return await localDataSource.getNonSyncedDeletedSpaces();
  }

  Future<void> deleteRemoteSpace({required String spaceId}) async {
    return await remoteDataSource.deleteSpaceFromFirebase(spaceId: spaceId);
  }

}
