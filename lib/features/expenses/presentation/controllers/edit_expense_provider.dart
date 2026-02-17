import 'package:collection/collection.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/services/expense_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../User/presentation/controllers/user_controller.dart';
import 'edit_expense_state.dart';

final editExpenseProvider = NotifierProvider.autoDispose
    .family<EditExpenseController, EditExpenseState, String?>((exp) {
      return EditExpenseController(exp);
    });

class EditExpenseController extends Notifier<EditExpenseState> {
  final String? id;
  EditExpenseController(this.id);


  @override
  EditExpenseState build() {
    final expenses = ref.read(expenseStreamProvider).value;
    if (id != null && expenses != null) {
      for (final expense in expenses) {
        if (expense.id == id) {
          return EditExpenseState(
            isExpenseSaving: false,
            paidBY: expense.payerName,
            note: expense.note,
            category: expense.category,
            amount: expense.amount.toString(),
            title: expense.title,
            selectedDate: expense.expenseDate,
          );
        }
      }
    }
    return EditExpenseState.empty();
  }

  ///-----------------------[SAVE_OR_EDIT_EXPENSE]--------------------------

  Future<bool> saveExpense() async {
    try {
      if(state.isExpenseSaving) return false;
      state = state.copyWith(isExpenseSaving: true);
      final currUser = ref.read(currentUserProvider).value;
      final currProfileUser = ref.read(currentSpaceProfileProvider);
      final currSpace = ref.read(currentSpaceProvider).value;
      final expenses = ref.read(expenseStreamProvider).value;
      ExpenseModel? expense;
      expense = expenses?.firstWhereOrNull((exp)=>exp.id==id);

      final expenseService = ref.read(expenseServiceProvider);

    await expenseService.saveExpenseFromInputUseCase(currProfileUser: currProfileUser, currUser: currUser, currSpace: currSpace, expense: expense, state: state);
    return true;
    } catch (e) {
      SnackBarService.showError(e.toString());
      return false;
    }finally{
      state = state.copyWith(isExpenseSaving: false);
    }
  }



  ///-----------------------[CREATE_NEW_STATE_WITH_PARAMETERS]---------------------------
  void copyWith({
    String? title,
    String? selectedDate,
    String? amount,
    ExpenseCategory? category,
    String? note,
    String? paidBy,
  }) {
    state = state.copyWith(
      paidBy: paidBy,
      selectedDate: selectedDate,
      amount: amount,
      category: category,
      title: title,
      note: note,
    );
  }
}



