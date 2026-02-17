import '../models/expense_model.dart';

abstract interface class IExpenseRemoteDataSource{


  Future<void> saveExpense({required ExpenseModel expense}) ;

  Future<void> deleteExpense({required ExpenseModel expense});

  Future<List<ExpenseModel>> getExpenses({required String spaceId}) ;
}