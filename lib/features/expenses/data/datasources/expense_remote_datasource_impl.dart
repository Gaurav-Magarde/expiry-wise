import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_remote_datasource_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../models/expense_model.dart';

class ExpenseRemoteDataSourceImpl implements IExpenseRemoteDataSource{
  static const String spaceCollection = 'spaces';
  static const String expenseCollection = 'expenses';
  static const String isDeletedKey = 'is_deleted';
  final FirebaseFirestore instance;
  ExpenseRemoteDataSourceImpl({required this.instance});

  Future<void> saveExpense({required ExpenseModel expense}) async {
    await instance
        .collection(spaceCollection)
        .doc(expense.spaceId)
        .collection(expenseCollection)
        .doc(expense.id)
        .set(expense.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteExpense({required ExpenseModel expense}) async {
    await instance
        .collection(spaceCollection)
        .doc(expense.spaceId)
        .collection(expenseCollection)
        .doc(expense.id)
        .update({isDeletedKey: true});
  }

  Future<List<ExpenseModel>> getExpenses({required String spaceId}) async {
    QuerySnapshot snapshot = await instance
        .collection(spaceCollection)
        .doc(spaceId)
        .collection(expenseCollection).where(isDeletedKey,isNotEqualTo: true)
        .get();

    List<ExpenseModel> expenseList = [];
    for (final doc in snapshot.docs) {
      final expense = ExpenseModel.fromMap(
        map: doc.data() as Map<String, dynamic>,
      );
      expenseList.add(expense);
    }
    return expenseList;
  }
}


final expenseRemoteDataSourceProvider = Provider<IExpenseRemoteDataSource>((ref){
  final instance = FirebaseFirestore.instance;
  return ExpenseRemoteDataSourceImpl(instance: instance);
});