import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/edit_expense_form.dart';

class AddNewExpense extends ConsumerWidget {
  final String? id;
  const AddNewExpense(this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        actions: [
          if(id!=null) IconButton(
            onPressed: () async {
              if(id==null){
                return;
              }
              await ref.read(expenseControllerProvider.notifier).deleteExpense(id: id!);
              if(context.mounted) context.pop();
            },
            icon: const Icon(Icons.delete_rounded,color: Colors.redAccent,size: 26,),
          ),
        ],
        title: Text(id == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: EditExpenseForm(id??''),
    );
  }
}


