import 'dart:core';

import 'package:expiry_wise_app/core/utils/exception/repository_error_handler.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_remote_datasource_interface.dart' hide quickListLocalDataSourceProvider;
import 'package:expiry_wise_app/features/quick_list/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/features/quick_list/domain/quick_list_repo_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';
import '../../../../core/network/network_info_impl.dart';

final quickListRepoProvider = Provider<QuickListRepoInterface>((ref) {
  final NetworkInfoImpl networkInfo = ref.read(networkInfoProvider);
  final IQuickListRemoteDatasource quickListRemoteDataSource = ref.read(quickListRemoteDataSourceProvider);
  final IQuickListLocalDatasource quickListLocalDataSource = ref.read(quickListLocalDataSourceProvider);
  return QuickListRepositoryImpl(   networkInfo:  networkInfo,quickListRemoteDataSource: quickListRemoteDataSource, quickListLocalDataSource: quickListLocalDataSource);
});

class QuickListRepositoryImpl
    with RepositoryErrorHandler
    implements QuickListRepoInterface{
  final IQuickListRemoteDatasource quickListRemoteDataSource;
  final IQuickListLocalDatasource quickListLocalDataSource;
  final NetworkInfoImpl networkInfo;

  QuickListRepositoryImpl({
    required this.networkInfo,
    required this.quickListRemoteDataSource,
    required this.quickListLocalDataSource,
  }
      );


  @override
  Future<List<QuickListModel>> getQuickList({required String spaceId}) async {
    return await safeCall(() async {
      return await quickListLocalDataSource.fetchQuickListItem(spaceId: spaceId);
    });
  }
 @override
  Future<List<QuickListModel>> getQuickListRemote({required String spaceId}) async {
    return await safeCall(() async {
      return await quickListRemoteDataSource.getFromQuickList(spaceId: spaceId);
    });
  }

  Future<List<QuickListModel>> getNonSyncedQuickList() async {
    return await safeCall(() async {
      return await quickListLocalDataSource.fetchNonSyncedQuickListItem();
    });
  }

  Future<List<QuickListModel>> getNonSyncedDeletedQuickList() async {
    return await safeCall(() async {
      return await quickListLocalDataSource.getNonSyncedDeletedQuickList();
    });
  }

  @override
  Future<void> saveToQuickList({required QuickListModel item}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      await quickListLocalDataSource.saveQuickListItem(item: item);
      if (isInternet) await quickListRemoteDataSource.saveToQuickList(item: item);
    });
  }

  @override
  Future<void> removeFromQuickList({
    required String id,
    required String spaceId,
  }) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;

      await quickListLocalDataSource.deleteQuickListItem(id: id, spaceId: spaceId);
      if (isInternet) {
        await quickListRemoteDataSource.deleteFromQuickList(spaceId: spaceId, id: id);
      }
    });
  }


  @override
  Future<void> updateInQuickList({required QuickListModel item}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      await quickListLocalDataSource.saveQuickListItem(item: item);
      if (isInternet) await quickListRemoteDataSource.saveToQuickList(item: item);
    });
  }


  @override
  Stream<List<QuickListModel>> get quickListStream => quickListLocalDataSource.quickListStream;

  @override
  void refreshList({required String spaceId}) {
    quickListLocalDataSource.refreshQuickList(spaceId: spaceId);
  }

  @override
  void addQuickListBatch({required List<QuickListModel> list, required Batch batch}) {
    quickListLocalDataSource.addQuickListBatch(batch: batch,quickList: list);
  }




}
