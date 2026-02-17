import 'package:sqflite_common/sqlite_api.dart';

import '../models/expense_model.dart';

abstract interface class IExpenseLocalDatasource{
  Stream<List<ExpenseModel>> get expenseStream ;


  Future<void> saveExpense({required ExpenseModel expense});

  Future<void> deleteExpense({required ExpenseModel expense});

  Future<void> loadExpense({required String spaceId});
  Future<List<ExpenseModel>> fetchExpense({required String spaceId});

  Future<List<ExpenseModel>> fetchNonSyncedExpense();
  Future<List<ExpenseModel>> fetchNonSyncedDeletedExpense();

  Future<void> refreshExpense({required String spaceId});

  void addExpensesBatch(List<ExpenseModel> expense, Batch batch);

}