import 'dart:async';

import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../Member/data/models/member_model.dart';

final expenseStateController =
    AsyncNotifierProvider<ExpenseStateController, List<ExpenseModel>>(() {
      return ExpenseStateController();
    });

final expenseStreamProvider = StreamProvider<List<ExpenseModel>>((ref) async* {
  final space = ref.watch(currentSpaceProvider).value;
  await ref
      .read(sqfLiteSetupProvider)
      .loadExpense(spaceId: space == null ? "" : space.id);
  yield* ref.read(sqfLiteSetupProvider).expenseStream;
});

class ExpenseStateController extends AsyncNotifier<List<ExpenseModel>> {
  @override
  Future<List<ExpenseModel>> build() async {
    final expenses = await ref.watch(expenseStreamProvider.future);
    final startDate = ref.watch(startDateInterval);
    final lastDate = ref.watch(lastDateInterval);

    final selectedCategory = ref.watch(selectedExpenseProvider);
    List<ExpenseModel> list = List.from(expenses);
    if (selectedCategory != null) {
      list.removeWhere((exp) => exp.category != selectedCategory);
    }

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
    final searched = ref.watch(searchControllerExpense).toLowerCase();
    double total = 0.0;
    List<ExpenseModel> newList = [];
    for(final exp in list){
      if(!exp.title.toLowerCase().contains(searched)){
        continue;
      }
      newList.add(exp);
      total += exp.amount;
    }
    ref.read(totalAmount.notifier).state = total;
    return newList;
  }

  Future<void> addExpenseFromItem({required ItemModel item}) async {
    try {
      if (item.price == null || item.price! <= 0) return;
      final expenseCategory = ItemCategory.values
          .firstWhere(
            (categ) => categ.name == item.category,
            orElse: () => ItemCategory.others,
          )
          .toExpenseCategory;

      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        return;
      }
      String note = "${item.name} added from inventory.";
      final currDate = DateFormat(
        DateFormatPattern.dateformatPattern,
      ).format(DateTime.now());
      final currTime = DateTime.now().toString();
      final id = Uuid().v4();
      ExpenseModel expense = ExpenseModel(
        payerName: currentUser.name,
        payerId: currentUser.id,
        title: "${item.name}(${item.quantity} ${item.unit})",
        id: id,
        amount: item.price ?? 0,
        category: expenseCategory,
        expenseDate: currDate,
        isSynced: false,
        updatedAt: currTime,
        spaceId: item.spaceId ?? '',
        note: note,
      );
      await ref.read(expenseRepositoryProvider).addExpense(expense: expense);
    } catch (E) {
      SnackBarService.showMessage("Expense added failed");
    }
  }

  Future<void> saveExpense({required ExpenseModel expense}) async {
    try {
      await ref.read(expenseRepositoryProvider).addExpense(expense: expense);
    } catch (E) {
      SnackBarService.showMessage("Expense added failed");
    }
  }

  Future<void> deleteExpense({required String id}) async {
    try {
      final expenses = ref.read(expenseStreamProvider).value;
      ExpenseModel? exp;
      if (expenses != null) {
        for (final expense in expenses) {
          if (expense.id == id) {
            exp = expense;

            break;
          }
        }
      }
      if(exp==null){
        SnackBarService.showMessage("No such expense found.please try again");
        return;
      }
      final currProfileUser = ref.read(currentSpaceProfileProvider);

      final currUser = ref.read(currentUserProvider).value;
      if (currUser == null) {
        SnackBarService.showMessage("user not found");
        return;
      }
      final userId = currUser.id;
      if(currProfileUser==MemberRole.member){
          if(exp.payerId!=userId){
            SnackBarService.showMessage("Only admin can edit others expense");
            return;
          }
        }
        await ref.read(expenseRepositoryProvider).deleteExpense(expense: exp);
      SnackBarService.showSuccess("Expense deleted");
    } catch (E) {
      SnackBarService.showMessage("Expense deleted failed");
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
final totalAmount = StateProvider<double>((ref) => 0);
