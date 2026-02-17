import 'dart:async';

import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/domain/expense_repository_interface.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/services/expense_services.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';


final expenseControllerProvider =
    AsyncNotifierProvider<ExpenseStateController, void>(() {
      return ExpenseStateController();
    });

final expenseStreamProvider = StreamProvider<List<ExpenseModel>>((ref) async* {
  final space = ref.watch(currentSpaceProvider).value;
  await ref
      .read(expenseRepositoryProvider)
      .loadExpense(spaceId: space == null ? '' : space.id);
  yield* ref.read(expenseRepositoryProvider).expenseStream;
});


final filteredExpensesProvider = Provider<AsyncValue<List<ExpenseModel>>>((ref) {
  final expensesAsync = ref.watch(expenseStreamProvider);
  final startDate = ref.watch(startDateInterval);
  final lastDate = ref.watch(lastDateInterval);
  final selectedCategory = ref.watch(selectedExpenseProvider);

  return expensesAsync.whenData((rawList){
    List<ExpenseModel> list = List.from(rawList);
    ///Categorize
    if(selectedCategory!=null) list = list.where((exp)=>exp.category == selectedCategory).toList();

    /// time interval
    list.removeWhere((exp) {
      DateTime expDate = DateFormat(
        DateFormatPattern.dateformatPattern,
      ).parse(exp.expenseDate);
      return expDate.isBefore(startDate);
    });

    if (lastDate != null) {
      list.removeWhere((exp) {
        DateTime expDate = DateFormat(
          DateFormatPattern.dateformatPattern,
        ).parse(exp.expenseDate);
        return expDate.isAfter(lastDate);
      });
    }

    ///Search
    final searched = ref.watch(searchControllerExpense).toLowerCase();
    list = list.where((exp)=>exp.title.toLowerCase().contains(searched)).toList();

    return list;
  });
});
class ExpenseStateController extends AsyncNotifier<void> {

  late ExpenseService expenseService;
  late IExpenseRepository expenseRepo;
  ExpenseStateController();
  @override
  void build() async {
    expenseRepo = ref.read(expenseRepositoryProvider);
    expenseService = ref.read(expenseServiceProvider);
  }

  Future<void> addExpenseFromItem({required ItemModel item}) async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      await expenseService.addExpenseFromItemService(item: item, currentUser: currentUser);
    } catch (E) {
      SnackBarService.showMessage('Expense added failed ${E.toString()}');
    }
  }

  Future<void> saveExpense({required ExpenseModel expense}) async {
    try {
      await expenseRepo.addExpense(expense: expense);
    } catch (E) {
      SnackBarService.showMessage('Expense added failed');
    }
  }

  Future<void> deleteExpense({required String id}) async {
    try {
      final currProfileUser = ref.read(currentSpaceProfileProvider);
      final currUser = ref.read(currentUserProvider).value;
      await expenseService.deleteExpense(id: id, currUser: currUser, currProfileUser: currProfileUser);
      SnackBarService.showSuccess('Expense deleted');
    } catch (E) {
      SnackBarService.showMessage('Expense deleted failed');
    }
  }
}

final selectedExpenseProvider = StateProvider<ExpenseCategory?>((ref) => null);
final startDateInterval = StateProvider<DateTime>(
  (ref) => DateTime.now().subtract(Duration(days: DateTime.now().day)),
);
final lastDateInterval = StateProvider<DateTime?>((ref) => DateTime.now());
final selectedDateLabelExpense = StateProvider<String>((ref) => 'This Month');
final searchControllerExpense = StateProvider<String>((ref) => '');
final isSearchingExpense = StateProvider<bool>((ref) =>false);
final totalAmount = StateProvider<double>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  return expenses.when(data: (list) => list.fold(0.0, (sum,exp)=>sum+exp.amount)
      ,loading: ()=>0,error: (e,s)=>0);
});
