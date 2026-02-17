import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/validators/validators.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/edit_expense_provider.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/text_form_field.dart';
import '../controllers/expense_controllers.dart';

class EditExpenseForm extends ConsumerStatefulWidget {
  const EditExpenseForm(this.id, {super.key});
  final String? id;
  @override
  ConsumerState<EditExpenseForm> createState() => _EditExpenseFormState();
}

class _EditExpenseFormState extends ConsumerState<EditExpenseForm> {
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    _noteController = TextEditingController();
    _titleController = TextEditingController();
    _amountController = TextEditingController();

    final expenses = ref.read(expenseStreamProvider).value;
    if (widget.id != null && expenses != null) {
      for (final expense in expenses) {
        if (expense.id == widget.id) {
          _noteController.text = expense.note ?? '';
          _amountController.text = expense.amount.toString();
          _titleController.text = expense.title;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _amountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(editExpenseProvider(widget.id).notifier);
    final paidBy = ref.watch(
      editExpenseProvider(widget.id).select((exp) => exp.paidBY),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (_, ref, _) {
                final selected = ref.watch(
                  editExpenseProvider(widget.id).select((exp) => exp.category),
                );
                return Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    border: Border.all(width: 3, color: selected.color),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 3),
                        blurStyle: BlurStyle.outer,
                        blurRadius: 7,
                        color: Colors.grey.shade100,
                      ),
                    ],
                  ),
                  child: Icon(selected.icon, size: 50, color: selected.color),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 8),

                  Icon(Icons.person, color: Colors.grey, size: 25),
                  SizedBox(width: 8),
                  if (paidBy != null)
                    Flexible(
                      child: Text(
                        "Paid by $paidBy",
                        style: Theme.of(context).textTheme.titleMedium!.apply(
                          fontWeightDelta: 4,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 7,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [PriceEditingWidget(_amountController)],
                            ),
                            const SizedBox(height: 16),
                            Consumer(
                              builder: (context, ref, child) {
                                return TextFormFieldWidget(
                                  controller: _titleController,
                                  prefixIcon: const Icon(
                                    Icons.shopping_bag,
                                    color: EColors.accentPrimary,
                                  ),
                                  hint: 'eg. Paid for groceries',
                                  labelText: 'Title',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      var selectedCategory = ref.watch(
                        editExpenseProvider(
                          widget.id,
                        ).select((s) => s.category),
                      );
                      final selected = ExpenseCategory.values.firstWhere(
                            (e) => e == selectedCategory,
                        orElse: () => ExpenseCategory.grocery,
                      );

                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Category",
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            selected.icon,
                            color: EColors.accentPrimary,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ExpenseCategory>(
                            value: selected,
                            isExpanded: true,
                            isDense: true,
                            items: ExpenseCategory.values.map((category) {
                              return DropdownMenuItem<ExpenseCategory>(
                                value: category,
                                child: Text(
                                  category.label,
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .apply(color: category.color),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              selectedCategory = val;
                              ref
                                  .read(editExpenseProvider(widget.id).notifier)
                                  .copyWith(category: val);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 15,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      var selectedDate = ref.watch(
                        editExpenseProvider(
                          widget.id,
                        ).select((s) => s.selectedDate),
                      );
                      return InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                            DateFormat(
                              DateFormatPattern.dateformatPattern,
                            ).tryParse(selectedDate ?? '') ??
                                DateTime.now(),
                            firstDate: DateTime(2001),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            selectedDate = DateFormat(
                              DateFormatPattern.dateformatPattern,
                            ).format(pickedDate);
                            controller.copyWith(selectedDate: selectedDate);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Transaction Date',
                            labelStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: EColors.accentPrimary,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            selectedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      return TextFormFieldWidget(
                        controller: _noteController,
                        hint: 'Add a Note',
                        labelText: 'Note(optional)',
                        prefixIcon: const Icon(
                          Icons.message,
                          color: EColors.accentPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 10),
                onPressed: () async {
                  if (!Validators.validateAmount(
                    amount: _amountController.text,
                  )) {
                    SnackBarService.showMessage('Enter a valid amount');
                    return;
                  }
                  if (!Validators.validateName(name: _titleController.text)) {
                    SnackBarService.showMessage('Enter a title for expense');
                    return;
                  }
                  controller.copyWith(
                    note: _noteController.text,
                    title: _titleController.text,
                    amount: _amountController.text,
                  );
                  await controller.saveExpense();
                  if (context.mounted) context.pop();
                },
                child: Consumer(
                  builder: (_, ref, __) {
                    final isLoading = ref.watch(
                      editExpenseProvider(
                        widget.id,
                      ).select((s) => s.isExpenseSaving),
                    );

                    return isLoading
                        ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                        : Text(
                      'Save Expense',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.apply(color: Colors.white),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriceEditingWidget extends ConsumerWidget {
  const PriceEditingWidget(this.controller, {super.key});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: TextFormFieldWidget(
        controller: controller,
        labelText: 'Amount',
        hint: 'eg.500',
        onChanged: (v) {},
        prefixIcon: const Icon(
          Icons.currency_rupee_outlined,
          color: EColors.accentPrimary,
        ),
        textInputType: const TextInputType.numberWithOptions(
          decimal: false,
          signed: false,
        ),
      ),
    );
  }
}
