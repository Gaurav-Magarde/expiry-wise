import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../User/presentation/controllers/user_controller.dart';

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

  ///-----------------------[SAVE OR EDIT EXPENSE]--------------------------
  Future<void> saveExpense() async {
    try {
      final amount = double.tryParse(state.amount);
      if (amount == null) {
        SnackBarService.showMessage("Enter a valid amount");
        return;
      }
      if (amount <= 0) {
        SnackBarService.showMessage("Enter amount more than 0");
        return;
      }

      final expenses = ref.read(expenseStreamProvider).value;
      ExpenseModel? exp;
      String currName = '';
      String expenseId = '';
      String userId = '';
      String payerId = '';
      String currSpaceId = '';
      final currProfileUser = ref.read(currentSpaceProfileProvider);
      final currTime = DateTime.now().toString();
      
      if (expenses != null) {
        for (final expense in expenses) {
          if (expense.id == id) {
            exp = expense;
            currName = expense.payerName ?? '';
            expenseId = expense.id;
            payerId = expense.payerId ?? '';
            currSpaceId = expense.spaceId;
            break;
          }
        }
      }

      if (exp == null) {
        final currUser = ref.read(currentUserProvider).value;
        if (currUser == null) return;
        final currSpace = ref.read(currentSpaceProvider).value;
        if (currSpace == null) return;
        expenseId = Uuid().v4();
        currName = currUser.name;
        userId = currUser.id;
        payerId = currUser.id;
        currSpaceId = currSpace.id;
      }
      
      if(exp!=null){
        if(currProfileUser==MemberRole.member){
          if(exp.payerId!=userId){
            SnackBarService.showMessage("Only admin can edit others expense");
            return;
          }
        }
      }

      final expense = ExpenseModel(
        spaceId: currSpaceId,
        title: state.title,
        id: expenseId,
        amount: amount,
        category: state.category,
        expenseDate: state.selectedDate,
        updatedAt: currTime,
        isSynced: false,
        note: state.note,
        payerId: payerId,
        payerName: currName,
      );
      await ref.read(expenseRepositoryProvider).addExpense(expense: expense);
    } catch (e) {

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


///------------------------------[EditExpenseState_state]-[CREATE_NEW_STATE]-------------------------------------
class EditExpenseState {
  final String title;
  final ExpenseCategory category;
  final String selectedDate;
  final String amount;
  final String? note;
  final String? paidBY;

  EditExpenseState( {
    required this.paidBY,
    required this.note,
    required this.category,
    required this.amount,
    required this.title,
    required this.selectedDate,
  });

  factory EditExpenseState.empty() {
    return EditExpenseState(
      note: '',
      category: ExpenseCategory.household,
      amount: '',
      title: '',
      selectedDate: '', paidBY: 'You',
    );
  }

  EditExpenseState copyWith({
    String? title,
    String? selectedDate,
    String? amount,
    ExpenseCategory? category,
    String? note,
    String? paidBy,
  }) {
    return EditExpenseState(
      paidBY: paidBy??this.paidBY,
      note: note ?? this.note,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
