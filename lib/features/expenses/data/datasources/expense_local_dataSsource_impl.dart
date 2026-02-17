import 'dart:async';

import 'package:expiry_wise_app/features/expenses/data/datasources/expense_local_datasource_interface.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../models/expense_model.dart';

class ExpenseLocalDataSourceImpl implements IExpenseLocalDatasource {

   final StreamController<List<ExpenseModel>> _expensesStreamController = StreamController<List<ExpenseModel>>.broadcast();
   @override
  Stream<List<ExpenseModel>> get expenseStream => _expensesStreamController.stream;
  ExpenseLocalDataSourceImpl({required this.sqfLiteSetup});
  static const String expenseIdColumn = 'id';
  static const String expensesTable = 'expenses';
  static const String spaceIdColumn = 'space_id';
  static const String isDeletedColumn = 'is_deleted';
  static const String isSyncedColumn = 'is_synced';
  final SqfLiteSetup sqfLiteSetup;


  @override
  Future<void> saveExpense({required ExpenseModel expense}) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    refreshExpense(spaceId: expense.spaceId);
  }

  @override
  Future<void> deleteExpense({required ExpenseModel expense}) async {
    final db = await sqfLiteSetup.getDatabase;
    await db.update(
      expensesTable,
      where: '$expenseIdColumn = ?',
      whereArgs: [expense.id],
      {isDeletedColumn: 1, isSyncedColumn: 0},
    );
    refreshExpense(spaceId: expense.spaceId);
  }

  @override
  Future<void> loadExpense({required String spaceId}) async {
    refreshExpense(spaceId: spaceId);
  }

  @override
  Future<List<ExpenseModel>> fetchExpense({required String spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      expensesTable,
      whereArgs: [spaceId,0],
      where: '$spaceId = ? AND $isDeletedColumn = ?',
    );
    return list.map((expense) => ExpenseModel.fromMap(map: expense)).toList();
  }

  @override
  Future<List<ExpenseModel>> fetchNonSyncedExpense() async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      expensesTable,
      whereArgs: [0],
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 0',
    );
    return list.map((expense) => ExpenseModel.fromMap(map: expense)).toList();
  }

  @override
  Future<List<ExpenseModel>> fetchNonSyncedDeletedExpense() async {
    final db = await sqfLiteSetup.getDatabase;
    final list = await db.query(
      expensesTable,
      whereArgs: [0],
      where: '$isSyncedColumn = ? AND $isDeletedColumn = 1',
    );
    return list.map((expense) => ExpenseModel.fromMap(map: expense)).toList();
  }

  @override
  Future<void> refreshExpense({required String spaceId}) async {
    final db = await sqfLiteSetup.getDatabase;

    final list = await db.query(
      expensesTable,
      whereArgs: [spaceId],
      where: '$spaceIdColumn = ?',
    );
    final expenses = list
        .map((expense) => ExpenseModel.fromMap(map: expense))
        .toList();
    _expensesStreamController.sink.add(expenses);
  }

  @override
  void addExpensesBatch(List<ExpenseModel> expense, Batch batch) {
    for(final exp in expense){
      batch.insert(expensesTable, exp.toMap());
    }
  }
}

final expenseLocalDataSourceProvider = Provider<IExpenseLocalDatasource>((ref){
  final sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  return ExpenseLocalDataSourceImpl(sqfLiteSetup: sqfLiteSetup);
});