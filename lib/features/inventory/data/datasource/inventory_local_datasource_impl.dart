import 'dart:async';

import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_interface.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/item_model.dart';

class InventorySqfLiteDataSource implements IInventoryLocalDataSource {
  final SqfLiteSetup sqfLiteSetup;
  static const String spaceTable = 'spaces';
  static const String itemsTable = ' items';
  static const String isDeletedColumn = ' is_deleted';
  static const String isSyncedColumn = ' is_synced';
  static const String isFinishedColumn = ' finished';
  static const String spaceIdColumn = 'space_id';
  static const String itemIdColumn = 'id';

  final _itemController = StreamController<List<ItemModel>>.broadcast();
  @override
  Stream<List<ItemModel>> get itemsStream => _itemController.stream;
  InventorySqfLiteDataSource({required this.sqfLiteSetup});
  @override
  Future<void> addItemsToBatch({
    required Batch batch,
    required List<ItemModel> items,
  }) async {
    try {
      for (final item in items) {
        final mapItem = item.toMap();
        batch.insert(
          itemsTable,
          mapItem,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      return;
    }
  }

  @override
  Future<void> insertItems(List<ItemModel> items,Batch batch) async {
    try {
      for (ItemModel item in items) {
        final Map<String, dynamic> mapItem = item.toMap();
        batch.insert(
          itemsTable,
          mapItem,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      return;
    }
  }

  @override
  Future<void> refreshItems({required String? spaceId}) async {
    try {
      List<ItemModel> items = [];
      if (spaceId != null && spaceId.isNotEmpty) {
        final db = await sqfLiteSetup.getDatabase;
        final maps = await db.query(
          itemsTable,
          where: '$spaceIdColumn = ? AND $isDeletedColumn = ?',
          whereArgs: [spaceId,0],
        );

        items = maps.map((item) => ItemModel.fromMap(item: item)).toList();
      }

      _itemController.sink.add(items);
    } catch (e) {
      print('exception in refresh $e');
      throw 'exception in refresh ';
    }
  }

  @override
  Future<ItemModel?> fetchItemById(String id) async {
    final db = await sqfLiteSetup.getDatabase;

    final List<Map<String, dynamic>> maps = await db.query(
      itemsTable,
      where: '$itemIdColumn = ? AND $isDeletedColumn = ?',
      whereArgs: [id, 0],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    } else {
      final list = ItemModel.fromMap(item: maps.first);
      return list;
    }
  }

  @override
  Future<List<ItemModel>> fetchItemsBySpace(String spaceId) async {
    final db = await sqfLiteSetup.getDatabase;

    final List<Map<String, dynamic>> maps = await db.query(
      itemsTable,
      where: '$spaceIdColumn=? AND $isDeletedColumn = ?',
      whereArgs: [spaceId, 0],
    );

    if (maps.isEmpty) {
      return [];
    } else {
      final list = maps.map((item) => ItemModel.fromMap(item: item)).toList();

      return list;
    }
  }

  @override
  Future<String?> updateItem(ItemModel item) async {
    try {
      final Map<String, dynamic> mapItem = item.toMap();
      final db = await sqfLiteSetup.getDatabase;
      final prev = await db.query(
        itemsTable,
        where: '$itemIdColumn =?',
        whereArgs: [item.id],
      );
      await db.update(
        itemsTable,
        where: '$itemIdColumn = ?',
        whereArgs: [item.id],
        mapItem,
      );
      refreshItems(spaceId: item.spaceId!);
      final string = prev.first['image_network'] as String?;
      return string;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNonSyncedItemQuery() async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      itemsTable,
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 0',
            whereArgs: [0],
    );
    return map;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchNonSyncedDeletedItem() async {
    final db = await sqfLiteSetup.getDatabase;
    final map = await db.query(
      itemsTable,
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 1',
      whereArgs: [0],
    );
    return map;
  }

  @override
  Future<bool> deleteItem({
    required String spaceId,
    required String itemId,
  }) async {
    try {
      final db = await sqfLiteSetup.getDatabase;
      final affect = await db.update(
        itemsTable,
        whereArgs: [itemId],
        where: 'id = ?',
        {isDeletedColumn: 1},
      );
      markItemAsUnSynced(itemId);
      refreshItems(spaceId: spaceId);
      return affect == 1;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteAllSpaceItem({required String spaceId}) async {
    try {
      final db = await sqfLiteSetup.getDatabase;
      await db.update(
        itemsTable,
        whereArgs: [spaceId],
        where: '$spaceIdColumn = ?',
        {isDeletedColumn: 1},
      );
      markItemAsUnSynced(spaceId);
      refreshItems(spaceId: spaceId);
    } catch (e) {
      throw " ";
    }
  }

  Future<void> markItemAsUnSynced(String id) async {
    try {
      final db = await sqfLiteSetup.getDatabase;
      await db.update(
        itemsTable,
        whereArgs: [id],
        where: '$itemIdColumn = ?',
        {isSyncedColumn: 0},
      );
    } catch (e) {
      throw " ";
    }
  }

  @override
  void deleteItemsBatch({required Batch batch, required String spaceId}) {
    batch.update(itemsTable, where: '$spaceIdColumn = ?', whereArgs: [spaceId],{isDeletedColumn:1});
  }

  @override
  Future<List<ItemModel>> fetchAllItems() {
    // TODO: implement fetchAllItems
    throw UnimplementedError();
  }

  @override
  Future<void> insertItem(ItemModel item) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.insert(itemsTable, item.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> markItemAsSynced(String id) async {
    try{
      final db = await sqfLiteSetup.getDatabase;
      db.update(itemsTable,whereArgs: [id],where: '$itemIdColumn = ?',{isSyncedColumn : 1});
    }catch(e){
      throw " ";
    }
  }

  @override
  Future<int> getItemCount({required String spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;
   final result = await db.rawQuery('Select Count(*) From $itemsTable Where $spaceIdColumn = ? AND $isDeletedColumn = 0',[spaceId]);
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  @override
  Future<double> getInventoryValue({String? spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;
    final result = await db.rawQuery('Select SUM(price) as total From $itemsTable Where $spaceIdColumn = ? AND $isDeletedColumn = 0 AND $isFinishedColumn = 0',[spaceId]);
    if(result.isNotEmpty){
      return (result.first['total'] as num?)?.toDouble()??0.0;
    }
    return 0;
  }

}
