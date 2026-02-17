import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../../domain/item_model.dart';

abstract interface class IInventoryRemoteDataSource {
  Future<void> insertItemToFirebase(
    String userId,
    String spaceId,
    ItemModel item,
  );

  Future<List<ItemModel>> fetchAllItemsFirebase(String? userId, String spaceId);

  Future<void> deleteItemFromFirebase({
    required String id,
    required String spaceId,
  });


  Future<void> deleteAllItemFromSpace({required String spaceId});
}


final inventoryRemoteDataSourceProvider = Provider<IInventoryRemoteDataSource>((ref){
  return InventoryFirebaseDataSource();
});