import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/domain/expense_repository_interface.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/edit_expense_state.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_expense_model.dart';
import 'package:expiry_wise_app/services/local_db/local_transaction_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../User/data/models/user_model.dart';
import '../../../../inventory/data/models/category_helper_model.dart';
import '../../../../inventory/domain/item_model.dart';

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  final expenseRepository = ref.read(expenseRepositoryProvider);
  final expenseStream = ref.read(expenseStreamProvider);
  final localTransaction = ref.read(providerLocalTransactionManager);
  return ExpenseService(
    localTransactionManager: localTransaction,
    expenseRepository: expenseRepository,
    expenseStream: expenseStream,
  );
});

class ExpenseService {
  ExpenseService({
    required this.expenseRepository,
    required this.localTransactionManager,
    required this.expenseStream,
  });
  final IExpenseRepository expenseRepository;
  final AsyncValue<List<ExpenseModel>> expenseStream;
  final LocalTransactionManager localTransactionManager;
  Future<void> addExpenseFromItemService({
    required ItemModel item,
    required UserModel? currentUser,
  }) async {
    try {
      if (item.price == null || item.price! <= 0) return;
      if (currentUser == null) {
        throw Exception('user not found');
      }
      final expense = _expenseFromItemUser(
        item: item,
        currentUser: currentUser,
      );
      await expenseRepository.addExpense(expense: expense);
    } catch (E) {
      throw Exception('Expense added failed.${E.toString()}');
    }
  }

  Future<void> deleteExpense({
    required String id,
    required UserModel? currUser,
    required MemberRole currProfileUser,
  }) async {
    try {
      final expenses = expenseStream.value;
      ExpenseModel? exp;
      if (expenses != null) {
        for (final expense in expenses) {
          if (expense.id == id) {
            exp = expense;
            break;
          }
        }
      }
      if (exp == null) {
        throw Exception('No such expense found.please try again');
      }
      if (currUser == null) {
        throw Exception('user not found');
      }
      final userId = currUser.id;
      if (currProfileUser == MemberRole.member) {
        if (exp.payerId != userId) {
          throw Exception('Only admin can edit others expense');
        }
      }
      await expenseRepository.deleteExpense(expense: exp);
    } catch (E) {
      throw Exception('Expense deleted failed. ${E.toString()}');
    }
  }



  Future<void> addItemFromVoiceCommandUseCase({required List<AiExpenseModel> expenses,required SpaceModel? space,required UserModel? user}) async {
    try{
      if(user==null || space==null) return;
      List<ExpenseModel> expenseList = [];
      for(final expDto in expenses){
        if(expDto.amount==null || expDto.amount!<0) continue;
        final spaceId = space.id;
        final title = expDto.title;
        final id = const Uuid().v4();
        final amount = expDto.amount!;
        final category = ExpenseCategory.values.firstWhere((category)=>category.name==expDto.category,orElse: ()=>ExpenseCategory.others);
        final expenseDate = DateFormat(DateFormatPattern.dateformatPattern).format(DateTime.tryParse(expDto.paidDate??'')??DateTime.now());
        final updatedAt = DateTime.now().toIso8601String();
        final payerName = user.name;
        final payerId = user.id;
        final expense  = ExpenseModel(payerName: payerName,payerId: payerId,spaceId: spaceId, title: title, id: id, amount: amount, category: category, expenseDate: expenseDate, updatedAt: updatedAt, isSynced: false);
        expenseList.add(expense);
      }
      await localTransactionManager.executeAtomic(action: (batch){
        expenseRepository.addExpensesBatch(expense: expenseList, batch: batch);
      });
    }catch(e){

    }
  }
  // Future<List<ExpenseModel>> loadExpenses() async {
  //   final startDate = ref.watch(startDateInterval);
  //   final lastDate = ref.watch(lastDateInterval);
  //   expenseRepo = ref.read(expenseRepositoryProvider);
  //
  //   final selectedCategory = ref.watch(selectedExpenseProvider);
  //   List<ExpenseModel> list = List.from(expenses);
  //   if (selectedCategory != null) {
  //     list.removeWhere((exp) => exp.category != selectedCategory);
  //   }
  //
  //   list.removeWhere((exp) {
  //     DateTime expDate = DateFormat(
  //       DateFormatPattern.dateformatPattern,
  //     ).parse(exp.expenseDate);
  //     return expDate.isBefore(startDate);
  //   });
  //   if (lastDate != null) {
  //     list.removeWhere((exp) {
  //       DateTime expDate = DateFormat(
  //         DateFormatPattern.dateformatPattern,
  //       ).parse(exp.expenseDate);
  //       return expDate.isAfter(lastDate);
  //     });
  //   }
  //   final searched = ref.watch(searchControllerExpense).toLowerCase();
  //   double total = 0.0;
  //   List<ExpenseModel> newList = [];
  //   for(final exp in list){
  //     if(!exp.title.toLowerCase().contains(searched)){
  //       continue;
  //     }
  //     newList.add(exp);
  //     total += exp.amount;
  //   }
  //   ref.read(totalAmount.notifier).state = total;
  //   return newList;
  // }


  Future<void> saveExpenseFromInputUseCase({
    required MemberRole currProfileUser,
    required UserModel? currUser,
    required SpaceModel? currSpace,
    required ExpenseModel? expense,
    required EditExpenseState state,
  }) async {
    try {
      final amount = double.tryParse(state.amount);
      if (amount == null) {
        throw Exception('Enter a valid amount');
      }
      if (amount <= 0) {
        throw Exception('Enter amount more than 0');
      }
      final updatedAt = DateTime.now().toIso8601String();
      if (currUser == null) {
        throw Exception('user not found');
      }
      if (currSpace == null) {
        throw Exception('space not found');
      }
      if (expense != null) {
        if (currProfileUser == MemberRole.member) {
          if (expense.payerId != currUser.id) {
            throw Exception('Only admin can edit others expense');
          }
        }
            expense = ExpenseModel(
              spaceId: expense.spaceId,
              title: state.title,
              id: expense.id,
              amount: amount,
              category: state.category,
              expenseDate: state.selectedDate,
              updatedAt: updatedAt,
              isSynced: false,
              payerId: expense.payerId,
              payerName: expense.payerName,
              note: state.note,
            );

      }else{
        String expenseId = const Uuid().v4();
        String currName = currUser.name;
        String payerId = currUser.id;
        String expenseDate = DateFormat(
          DateFormatPattern.dateformatPattern,
        ).format(DateTime.now());
        String currSpaceId = currSpace.id;
        expense = ExpenseModel(
          note: state.note,
          payerName: currName,
          payerId: payerId,
          spaceId: currSpaceId,
          title: state.title,
          id: expenseId,
          amount: amount,
          category: state.category,
          expenseDate: expenseDate,
          updatedAt: updatedAt,
          isSynced: false,
        );
      }
      await expenseRepository.addExpense(expense: expense);
    } catch (e) {
      throw Exception('expense save failed. $e');
    }
  }

  ExpenseModel _expenseFromItemUser({
    required ItemModel item,
    required UserModel currentUser,
  }) {
    final expenseCategory = ItemCategory.values
        .firstWhere(
          (category) => category.name == item.category,
          orElse: () => ItemCategory.others,
        )
        .toExpenseCategory;
    String note = '${item.name} added from inventory.';
    final currDate = DateFormat(
      DateFormatPattern.dateformatPattern,
    ).format(DateTime.now());
    final currTime = DateTime.now().toIso8601String();
    final id = const Uuid().v4();
    final title = '${item.name}(${item.quantity} ${item.unit})';
    ExpenseModel expense = ExpenseModel(
      payerName: currentUser.name,
      payerId: currentUser.id,
      title: title,
      id: id,
      amount: item.price!,
      category: expenseCategory,
      expenseDate: currDate,
      isSynced: false,
      updatedAt: currTime,
      spaceId: item.spaceId!,
      note: note,
    );
    return expense;
  }
}
