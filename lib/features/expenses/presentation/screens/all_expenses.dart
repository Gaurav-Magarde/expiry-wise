import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/expenses/presentation/widgets/total_expense_info.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors.dart';
import '../widgets/all_expense_appbar_widget.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_category_chips.dart';

class AllExpenses extends ConsumerWidget {
  const AllExpenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const AllExpenseAppBarWidget(),
      body: Column(
        children: [
          const ExpenseCategoryChips(),
          const SizedBox(height: 16),
          const TotalExpenseInfo(),
          Flexible(
            child: Consumer(
              builder: (_, ref, _) {
                ref.watch(filteredExpensesProvider);
                return ref
                    .watch(filteredExpensesProvider)
                    .when(
                      data: (expenses) {
                        if (expenses.isEmpty) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/no_items_img.webp'),
                              const SizedBox(height: 16),
                              Text(
                                'No Expenses Found!',
                                style: Theme.of(context).textTheme.titleLarge!
                                    .apply(
                                      color: EColors.primaryDark,
                                      fontWeightDelta: 3,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try Adjusting your filters',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .apply(
                                      color: EColors.primaryDark,
                                      fontWeightDelta: 2,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        return ListView.separated(
                          itemBuilder: (con, index) {
                            final expense = expenses[index];
                            return ExpenseCard(expense: expense);
                          },
                          padding: const EdgeInsets.only(bottom: 100),
                          separatorBuilder: (_, index) =>
                              index == expenses.length - 1
                              ? const SizedBox(height: 200)
                              : const SizedBox(height: 4),
                          itemCount: expenses.length,
                        );
                      },
                      error: (e, s) =>
                          const Center(child: Text('something went wrong')),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
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
        'Add Expense',
      ),
    );
  }
}
