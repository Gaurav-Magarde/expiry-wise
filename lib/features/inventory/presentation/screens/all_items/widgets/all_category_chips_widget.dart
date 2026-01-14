import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/item_controller/all_item_controller.dart';

class AllChips extends ConsumerWidget {
  const AllChips({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ChipsModel.allChips
            .map(
              (chip) => Consumer(
                builder: (_, ref, _) {
                  final selected = ref.watch(selectedChipProvider);

                  return Padding(
                    padding:const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(label: Text(chip.toUpperCase(),style: Theme.of(context).textTheme.labelMedium!.apply(color: selected==chip ? Colors.white:EColors.textSecondary),), selected: selected==chip,onSelected: (currSelected){
                     if(currSelected) ref.read(selectedChipProvider .notifier).state = chip;
                    },selectedColor: EColors.primary,backgroundColor: Colors.white,shape:const StadiumBorder(),showCheckmark: false, ),
                  );
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
