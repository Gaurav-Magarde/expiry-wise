import 'dart:async';

import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_local_datasource_interface.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quicklist_model.dart';

class QuickListLocalDataSourceImpl implements IQuickListLocalDatasource {
  final _quickListStreamController =
      StreamController<List<QuickListModel>>.broadcast();
  @override
  Stream<List<QuickListModel>> get quickListStream =>
      _quickListStreamController.stream;

  static const String quickListTable = 'quick_list';
  static const String itemsTable = ' items';
  static const String isDeletedColumn = ' is_deleted';
  static const String isSyncedColumn = ' is_synced';
  static const String spaceIdColumn = 'space_id';
  static const String quickListIdColumn = 'id';

  final SqfLiteSetup sqfLiteSetup;
  QuickListLocalDataSourceImpl({required this.sqfLiteSetup});

  @override
  Future<void> saveQuickListItem({required QuickListModel item}) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.insert(
      quickListTable,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
   final res = await db.query(
      quickListTable,
    );

    refreshQuickList(spaceId: item.spaceId);
  }

  @override
  Future<void> deleteQuickListItem({
    required String id,
    required String spaceId,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.update(quickListTable, where: '$quickListIdColumn = ?', whereArgs: [id],{isDeletedColumn:1});
    refreshQuickList(spaceId: spaceId);
  }

  @override
  Future<void> loadQuickListItem({required String spaceId}) async {
    refreshQuickList(spaceId: spaceId);
  }

  @override
  Future<List<QuickListModel>> fetchQuickListItem({
    required String spaceId,
  }) async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      quickListTable,
      whereArgs: [spaceId,0],
      where: '$spaceIdColumn = ? AND $isDeletedColumn = ?',
    );
    return list.map((item) => QuickListModel.fromMap(map: item)).toList();
  }

  @override
  Future<List<QuickListModel>> fetchNonSyncedQuickListItem() async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      quickListTable,
      whereArgs: [0],
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 0',
    );
    return list.map((item) => QuickListModel.fromMap(map: item)).toList();
  }

  @override
  Future<List<QuickListModel>> getNonSyncedDeletedQuickList() async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      quickListTable,
      whereArgs: [0],
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 1',
    );
    return list.map((item) => QuickListModel.fromMap(map: item)).toList();
  }

  @override
  Future<void> refreshQuickList({required String spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;

    final list = await db.query(
      quickListTable,
      whereArgs: [spaceId,0],
      where: '$spaceIdColumn = ? AND $isDeletedColumn = ?',
    );
    final itemList = list
        .map((item) => QuickListModel.fromMap(map: item))
        .toList();
    _quickListStreamController.sink.add(itemList);
  }

  @override
  void addQuickListBatch({required List<QuickListModel> quickList,required Batch batch,}) {
    for(final item in quickList){
      batch.insert(quickListTable,item.toMap());
    }
  }
}
