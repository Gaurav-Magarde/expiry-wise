import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/inventory/data/models/api_product_model.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/quick_list/data/models/quicklist_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

abstract class InventoryRepository {
  Stream<List<ItemModel>> get itemStream;

  Future<void> addItem({required ItemModel item});

  Future<void> addItemRemote({required ItemModel item});

  Future<ApiProductModel?> fetchItemByBarcode(String next);

  Future<void> removeItemLocal({required String id, required String spaceId});

  Future<void> removeItemRemote({required String id, required String spaceId});

  Future<void> removeAllSpaceItem({ required String spaceId});

  Future<void> updateItem({required ItemModel item});

  Future<List<ItemModel>> getInventoryItems({required String spaceId});

  Future<List<ItemModel>>  fetchRemoteItemInSpace({required String spaceId});

  void removeLocalSpaceItemAtomic({required Batch batch, required String spaceId});

  Future<ItemModel?> getItemByIdLocal({required String itemId});

  Future<void> insertItemsLocally({required List<ItemModel> items,required Batch batch});

  void refreshItems({String? spaceId});

  Future<void> markItemAsUnSynced(String id) ;

  Future<void> markItemAsSynced(String id);

  Future<int> fetchCountItemInSpaceLocal({required String spaceId});

  Future<double> getInventoryValue({required String? spaceId});
}


