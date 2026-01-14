import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/core/utils/helpers/helper.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/expense_model.dart';

class ExpenseCard extends ConsumerWidget{
  const ExpenseCard({required this.expense, super.key});
  final ExpenseModel expense;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.read(currentUserProvider).value?.id;
    return InkWell(
      onTap: (){
        context.pushNamed(MYRoute.addNewExpense,queryParameters: {'id':expense.id});
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [

            Container(
              height: 45, width: 45,
              decoration: BoxDecoration(color:expense.category.backgroundColor, shape: BoxShape.circle),
              child: Icon(expense.category.icon, color: expense.category.color),
            ),

            SizedBox(width: 12),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Helper.titleCase(expense.title), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14,color: EColors.textPrimary),maxLines: 1,overflow: TextOverflow.ellipsis,),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey),
                      Text( userName!=null && userName==expense.payerId ? "You":" ${expense.payerName} ", style: TextStyle(fontSize: 12, color: Colors.grey)),

                      // Smart Tag Logic
                      if (expense.note!=null)
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: EColors.secondary, borderRadius: BorderRadius.circular(4)),
                          child: Text("Task", style: TextStyle(fontSize: 10, color: EColors.primary)),
                        )
                    ],
                  )
                ],
              ),
            ),

            // 3. Amount & Date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Helper.formatCurrency(expense.amount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red[700])),
                SizedBox(height: 4),
                Text(expense.expenseDate, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

}