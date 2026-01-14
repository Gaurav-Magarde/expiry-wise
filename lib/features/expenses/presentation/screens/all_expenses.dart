import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/expenses/presentation/widgets/total_expense_info.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../inventory/presentation/screens/all_items/widgets/all_items_search_widget.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_category_chips.dart';

class AllExpenses extends ConsumerWidget {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Consumer(
          builder: (_, ref, _) {
            final isSearching = ref.watch(isSearchingExpense);
            return Row(
              children: [
                !isSearching
                    ? const Text("My Expenses")
                    : Expanded(
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                        .read(searchControllerExpense.notifier)
                                        .state =
                                    '';
                                ref.read(isSearchingExpense.notifier).state =
                                    false;
                              },
                              child: Icon(Icons.arrow_back),
                            ),
                            Expanded(
                              child: SearchWidget(
                                ref.read(searchControllerExpense.notifier),
                                "search by name..",
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            );
          },
        ),
        actions: [
          Consumer(
            builder: (_, ref, _) {
              final isSearching = ref.watch(isSearchingExpense);

              return !isSearching
                  ? IconButton(
                      onPressed: () {
                        ref.read(isSearchingExpense.notifier).state = true;
                      },
                      icon: Icon(Icons.search),
                    )
                  : Center();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const ExpenseCategoryChips(),
          const SizedBox(height: 16),
          const TotalExpenseInfo(),
          Flexible(
            child: Consumer(
              builder: (_, ref, _) {
                ref.watch(selectedExpenseProvider);
                final expenses = ref
                    .watch(expenseStateController)
                    .when(
                      data: (data) => data,
                      error: (e, s) => [],
                      loading: () => [],
                    );
                return ListView.separated(
                  itemBuilder: (con, index) {
                    final expense = expenses[index];
                    return ExpenseCard(expense: expense);
                  },
                  padding: const EdgeInsets.only(bottom: 100),
                  separatorBuilder: (_, index) => index == expenses.length - 1
                      ? SizedBox(height: 200)
                      : SizedBox(height: 4),
                  itemCount: expenses.length,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: AddItemFloatingButton(
        () {
          context.pushNamed(MYRoute.addNewExpense);
        },
        Icons.currency_rupee_outlined,
        "Add Expense",
      ),
    );
  }
}
