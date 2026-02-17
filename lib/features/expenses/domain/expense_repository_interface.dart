
import 'package:sqflite_common/sqlite_api.dart';

import '../data/models/expense_model.dart';

abstract interface class IExpenseRepository{

  Stream<List<ExpenseModel>> get expenseStream ;


  Future<void> addExpense({required ExpenseModel expense});

  Future<void> deleteExpense({required ExpenseModel expense});

  Future<void> deleteExpenseRemote({required ExpenseModel expense});

  Future<void> saveExpenseRemote({required ExpenseModel expense});

  Future<List<ExpenseModel>> getExpensesRemote({required String spaceId});

  Future<List<ExpenseModel>> fetchExpenseLocal({required String spaceId});

  Future<List<ExpenseModel>> fetchNonSyncedExpense();

  Future<void> loadExpense({required String spaceId});

  void addExpensesBatch({required List<ExpenseModel> expense, required Batch batch});

  void refreshExpenses(String id);
}