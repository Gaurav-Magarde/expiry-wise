import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref){
 final sqf = ref.read(sqfLiteSetupProvider);
 final fireStore = ref.read(fireStoreServiceProvider);
 return ExpenseRepository(fireStore,sqf);
}
);

class ExpenseRepository{
 final FireStoreService _fireStoreService;
 final SqfLiteSetup _localService;
 const ExpenseRepository(this._fireStoreService, this._localService);


 Future<void> addExpense({required ExpenseModel expense})async {
   try{
     await _fireStoreService.saveExpense(expense: expense);
     await _localService.saveExpense(expense:expense);
   }catch(e){

   }
 }

 Future<void> deleteExpense({required ExpenseModel expense})async {
   try{
     await _fireStoreService.deleteExpense(expense: expense);
     await _localService.deleteExpense(expense:expense);
   }catch(e){

   }
 }
}