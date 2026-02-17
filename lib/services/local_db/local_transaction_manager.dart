import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';


final providerLocalTransactionManager = Provider<LocalTransactionManager>((ref){

  final sqfLite = ref.read(sqfLiteSetupProvider);
  final inventoryLocalDataSource = ref.read(inventoryLocalDataSourceProvider);
  final memberLocalDataSource = ref.read(memberLocalDataSourceProvider);
  final spaceLocalDataSource = ref.read(spaceLocalDataSourceProvider);
  return LocalTransactionManager(sqfLite: sqfLite, inventoryLocalDataSource: inventoryLocalDataSource, memberLocalDataSource: memberLocalDataSource, spaceLocalDataSource: spaceLocalDataSource);
});

class LocalTransactionManager{
  final IInventoryLocalDataSource inventoryLocalDataSource;
  final IMemberLocalDataSource memberLocalDataSource;
  final ISpaceLocalDataSource spaceLocalDataSource;
  final SqfLiteSetup sqfLite;
  const LocalTransactionManager(
      {required this.sqfLite,required this.inventoryLocalDataSource, required this.memberLocalDataSource, required this.spaceLocalDataSource});

  Future<void> spaceJoinDataAtomic({
    required List<ItemModel> items,
    required List<SpaceModel> spaces,
    required List<MemberModel> members,
}) async {
    try{
      final database = await sqfLite.getDatabase;
      await database.transaction((txn) async {
        final batch = txn.batch();
        await spaceLocalDataSource.addSpacesToBatch(batch: batch, spaces: spaces);
        await inventoryLocalDataSource.addItemsToBatch(batch: batch, items: items);
        await memberLocalDataSource.addMembersToBatch(batch: batch, members: members);
        await batch.commit();
      });
    }catch(e){};
  }


  Future<void> deleteDataAtomic({
    required String spaceId,
}) async {
    try{
      final database = await sqfLite.getDatabase;
      await database.transaction((txn) async {
        final batch = txn.batch();
        inventoryLocalDataSource.deleteItemsBatch(batch: batch, spaceId: spaceId);
        memberLocalDataSource.deleteMembersToBatch(batch: batch, spaceId: spaceId);
        spaceLocalDataSource.deleteSpaceBatch(batch: batch, spaceId: spaceId );
        await batch.commit();
      });
    }catch(e){};
  }


  Future<void> executeAtomic({
    required Function(Batch batch) action
}) async {
    try{
      final database = await sqfLite.getDatabase;
      await database.transaction((txn) async {
        final batch = txn.batch();
        print("transaction done ");
        action(batch);
        await batch.commit();
      });
    }catch(e){};
  }
}