import 'dart:async';
import 'dart:core';
import 'package:expiry_wise_app/core/utils/exception/repository_error_handler.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_inteface.dart';
import 'package:expiry_wise_app/features/inventory/data/models/api_product_model.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/services/api_services/food_api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../../../core/network/network_info_impl.dart';
import '../../domain/item_model.dart';

final inventoryRepoProvider = Provider<InventoryRepository>((ref) {
  final FoodApiService apiService = ref.read(foodApiProvider);
  final NetworkInfoImpl networkInfo = ref.read(networkInfoProvider);
  final IInventoryRemoteDataSource remoteInventoryDataSource = ref.read(inventoryRemoteDataSourceProvider);
  final IInventoryLocalDataSource localInventoryDataSource = ref.read(inventoryLocalDataSourceProvider);
  return ItemRepositoryImpl( apiService:apiService, networkInfo:  networkInfo,remoteInventoryDataSource: remoteInventoryDataSource, localInventoryDataSource: localInventoryDataSource);
});

class ItemRepositoryImpl
    with RepositoryErrorHandler
    implements InventoryRepository {
  final FoodApiService apiService;
  final IInventoryRemoteDataSource remoteInventoryDataSource;
  final IInventoryLocalDataSource localInventoryDataSource;
  final NetworkInfoImpl networkInfo;

  ItemRepositoryImpl({

    required this.apiService,
    required this.networkInfo,
    required this.remoteInventoryDataSource,
    required this.localInventoryDataSource,
  }
  );

  @override
  Future<ApiProductModel?> fetchItemByBarcode(String next) async {
    return await safeCall(() async {
      final data = await apiService.getProductByBarcode(next);
      if (data == null) {
        return null;
      }
      final ApiProductModel product = ApiProductModel.fromMap(data);
      return product;

    });
  }

  @override
  Future<List<ItemModel>> getInventoryItems({required String spaceId}) async {
    return await safeCall(() async {
      return await localInventoryDataSource.fetchItemsBySpace(spaceId);
    });
  }


  @override
  Future<void> updateItem({required ItemModel item}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;

      await localInventoryDataSource.updateItem(item);
      if (isInternet) {
          await remoteInventoryDataSource.insertItemToFirebase(item.userId!, item.spaceId!, item);
          unawaited(markItemAsSynced(item.id));
      }
    });
  }

  @override
  Future<void> addItem({required ItemModel item}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      await localInventoryDataSource.insertItem(item);
      if (isInternet) {
        await remoteInventoryDataSource.insertItemToFirebase(item.userId!, item.spaceId!, item);
        markItemAsSynced(item.id);

      }
      refreshItems(spaceId: item.spaceId);
    });
  }

  @override
  Future<void> addItemRemote({required ItemModel item}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      if (isInternet) {
        await remoteInventoryDataSource.insertItemToFirebase(item.userId!, item.spaceId!, item);
        markItemAsSynced(item.id);

      }
      refreshItems(spaceId: item.spaceId);
    });
  }

  @override
  Future<void> removeItemLocal({required String id, required String spaceId}) async {
    return await safeCall(() async {
      await localInventoryDataSource.deleteItem(spaceId: spaceId, itemId: id);
    });
  }
  @override
  Future<void> removeItemRemote({required String id, required String spaceId}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      if (isInternet) {
        await remoteInventoryDataSource.deleteItemFromFirebase(spaceId: spaceId, id: id);
      }
    });
  }


  @override
  Future<void> removeAllSpaceItem({ required String spaceId}) async {
    return await safeCall(() async {
      final isInternet = await networkInfo.checkInternetStatus;
      await localInventoryDataSource.deleteAllSpaceItem(spaceId: spaceId);
      if (isInternet) {
        await remoteInventoryDataSource.deleteAllItemFromSpace(spaceId: spaceId);
      }
    });
  }


  @override
  Future<List<ItemModel>>  fetchRemoteItemInSpace({required String spaceId}) async {
    final isInternet = await networkInfo.checkInternetStatus;
  if(isInternet){
    return await remoteInventoryDataSource.fetchAllItemsFirebase(null, spaceId);
  }
  throw Exception('no internet connection');
  }

  @override
  void removeLocalSpaceItemAtomic({required Batch batch, required String spaceId}) {
    localInventoryDataSource.deleteItemsBatch(batch: batch, spaceId: spaceId);
  }

  @override
  Future<ItemModel?> getItemByIdLocal({required String itemId}) async {
    return await localInventoryDataSource.fetchItemById(itemId);
  }

  @override
  Future<void> insertItemsLocally({required List<ItemModel> items,required Batch batch,}) async {
    await localInventoryDataSource.insertItems(items,batch);
  }

  @override
  void refreshItems({String? spaceId}) {
    localInventoryDataSource.refreshItems(spaceId: spaceId);
  }

  @override
  Stream<List<ItemModel>> get itemStream => localInventoryDataSource.itemsStream;

  @override
  Future<void> markItemAsUnSynced(String id) async {
    await localInventoryDataSource.markItemAsUnSynced(id);
  }

  @override
  Future<void> markItemAsSynced(String id) async {
    await localInventoryDataSource.markItemAsSynced(id);
  }

  @override
  Future<int> fetchCountItemInSpaceLocal({required String spaceId}) async {
    return await localInventoryDataSource.getItemCount(spaceId:spaceId);
  }

  @override
  Future<double> getInventoryValue({required String? spaceId}) {
    return localInventoryDataSource.getInventoryValue(spaceId:spaceId);
  }


  Future<List<ItemModel>> getNonSyncedItems() async {
    final listMap = await localInventoryDataSource.fetchNonSyncedItemQuery();
    final itemList = listMap.map((map)=>ItemModel.fromMap(item: map)).toList();
    return itemList;
  }

  Future getNonSyncedDeletedItems() async {
    final listMap = await localInventoryDataSource.fetchNonSyncedDeletedItem();
    final itemList = listMap.map((map)=>ItemModel.fromMap(item: map)).toList();
    return itemList;
  }



}
