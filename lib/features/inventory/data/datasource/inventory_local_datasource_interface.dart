import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_impl.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../../domain/item_model.dart';

abstract interface class IInventoryLocalDataSource{
  Stream<List<ItemModel>> get itemsStream;


  Future<void> insertItem(ItemModel item);


  Future<void> insertItems(List<ItemModel> items,Batch batch);


  Future<void> refreshItems({required String? spaceId}) ;


  Future<ItemModel?> fetchItemById(String id);


  Future<List<ItemModel>> fetchItemsBySpace(String spaceId) ;


  Future<List<ItemModel>> fetchAllItems() ;


  Future<String?> updateItem(ItemModel item);


  Future<List<Map<String, dynamic>>> fetchNonSyncedItemQuery() ;

  Future<List<Map<String, dynamic>>> fetchNonSyncedDeletedItem() ;

  Future<bool> deleteItem({required String spaceId, required String itemId});

  Future<void> deleteAllSpaceItem({required String spaceId });

Future<void> addItemsToBatch({required Batch batch,required List<ItemModel> items});

  void deleteItemsBatch({required Batch batch, required String spaceId});

  Future<void> markItemAsUnSynced(String id);

  Future<void> markItemAsSynced(String id);

  Future<int> getItemCount({required String spaceId});

  Future<double> getInventoryValue({String? spaceId});
}



final inventoryLocalDataSourceProvider = Provider<IInventoryLocalDataSource>((ref){
  final sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  return InventorySqfLiteDataSource(sqfLiteSetup: sqfLiteSetup);
});