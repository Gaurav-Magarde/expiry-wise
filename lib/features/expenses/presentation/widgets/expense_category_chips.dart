import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/expense_card.dart';

class ExpenseCategoryChips extends StatelessWidget {
  const ExpenseCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children:[
          SizedBox(width: 8,),
          Consumer(
            builder: (_, ref, _) {
              final isSelected =
                  ref.watch(selectedExpenseProvider) == null;
              return ChoiceChip(
                label: Text('All'),
                onSelected: (bool value) {
                  ref.read(selectedExpenseProvider.notifier).state = null;
                  print(ref.read(selectedExpenseProvider));
                },
                selected: isSelected,
                shape: const StadiumBorder(),
                showCheckmark: false,
                backgroundColor: Colors.white,
                selectedColor: EColors.primary,
                labelStyle: Theme.of(context).textTheme.labelMedium!.apply(
                  color: isSelected ? Colors.white : EColors.textSecondary,
                  fontWeightDelta: 2,
                ),
                disabledColor: Colors.black,
              );
            },
          ),

          ...ExpenseCategory.values
              .map(
                (category) => Padding(
              padding: const EdgeInsets.only(left:  8.0),
              child: Consumer(
                builder: (_, ref, _) {
                  final isSelected =
                      ref.watch(selectedExpenseProvider) == category;
                  return ChoiceChip(
                    label: Text(category.label,style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: isSelected ? Colors.white : EColors.textSecondary,
                      fontWeightDelta:2,
                    ),),
                    onSelected: (bool value) {
                      ref.read(selectedExpenseProvider.notifier).state = category;
                      print(ref.read(selectedExpenseProvider));

                    },
                    selected: isSelected,
                    shape: const StadiumBorder(),
                    showCheckmark: false,
                    backgroundColor: Colors.white,
                    selectedColor: EColors.primary,
                    labelStyle: Theme.of(context).textTheme.labelMedium!.apply(
                      color: isSelected ? Colors.white : EColors.secondary,
                      fontWeightDelta:2,
                    ),
                    disabledColor: Colors.black,
                  );
                },
              ),
            ),
          )
              ,
        ]
      ),
    );
  }
}
