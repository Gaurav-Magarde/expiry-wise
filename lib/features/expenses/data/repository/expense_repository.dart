import 'package:expiry_wise_app/features/expenses/data/datasources/expense_local_dataSsource_impl.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../domain/expense_repository_interface.dart';

final expenseRepositoryProvider = Provider<IExpenseRepository>((ref){
 final expenseLocalDatasource = ref.read(expenseLocalDataSourceProvider);
 final expenseRemoteDataSource = ref.read(expenseRemoteDataSourceProvider);
 return ExpenseRepository( expenseRemoteDataSource: expenseRemoteDataSource,expenseLocalDatasource: expenseLocalDatasource);
}
);

class ExpenseRepository implements IExpenseRepository{
 final IExpenseRemoteDataSource expenseRemoteDataSource;
 final IExpenseLocalDatasource expenseLocalDatasource;


 const ExpenseRepository({required this.expenseRemoteDataSource, required this.expenseLocalDatasource});


 @override
  Future<void> addExpense({required ExpenseModel expense})async {
   try{
     await expenseRemoteDataSource.saveExpense(expense: expense);
     await expenseLocalDatasource.saveExpense(expense:expense);
   }catch(e){
    throw Exception(e.toString());
   }
 }

 @override
  Future<void> deleteExpense({required ExpenseModel expense})async {
   try{
     await expenseRemoteDataSource.deleteExpense(expense: expense);
     await expenseLocalDatasource.deleteExpense(expense:expense);
   }catch(e){

   }
 }

 @override
  Future<void> deleteExpenseRemote({required ExpenseModel expense})async {
   try{
     await expenseRemoteDataSource.deleteExpense(expense: expense);
     await expenseLocalDatasource.deleteExpense(expense:expense);
   }catch(e){

   }
 }

  @override
  Future<void> saveExpenseRemote({required ExpenseModel expense}) async {
    await expenseRemoteDataSource.saveExpense(expense: expense);
  }

  @override
  Future<List<ExpenseModel>> getExpensesRemote({required String spaceId}) async {
    return await expenseRemoteDataSource.getExpenses(spaceId: spaceId);
  }

  @override
  Future<List<ExpenseModel>> fetchExpenseLocal({required String spaceId}) async {
    return await expenseLocalDatasource.fetchExpense(spaceId: spaceId);
  }

  @override
  Future<List<ExpenseModel>> fetchNonSyncedExpense() async {
    return await expenseLocalDatasource.fetchNonSyncedExpense();
  }
  @override
  Future<List<ExpenseModel>> fetchNonSyncedDeletedExpense() async {
    return await expenseLocalDatasource.fetchNonSyncedDeletedExpense();
  }

  @override
  Future<void> loadExpense({required String spaceId}) async {
    await expenseLocalDatasource.loadExpense(spaceId: spaceId);
  }

  @override
  Stream<List<ExpenseModel>> get expenseStream => expenseLocalDatasource.expenseStream;

  @override
  void addExpensesBatch({required List<ExpenseModel> expense, required Batch batch}) {
    expenseLocalDatasource.addExpensesBatch(expense,batch);
  }

  @override
  void refreshExpenses(spaceId) {
    expenseLocalDatasource.refreshExpense(spaceId: spaceId);
  }


}