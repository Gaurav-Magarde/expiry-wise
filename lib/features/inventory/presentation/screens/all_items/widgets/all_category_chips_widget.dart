import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
// Adjust imports as needed
import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';

class AllChips extends ConsumerWidget {
  const AllChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedChip = ref.watch(itemControllerProvider.select((s) => s.selectedChip));

    final List<String?> filterOptions = [null, ...ChipsModel.allChips];

    return SizedBox(
      height: 50,
      // 3. Use ListView.separated for clean spacing
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: filterOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = filterOptions[index];
          final isSelected = selectedChip == category;

          return ChoiceChip(
            label: Text(
              (category ?? 'All').toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.apply(
                color: isSelected ? Colors.white : EColors.textSecondary,
                fontWeightDelta: isSelected ? 2 : 0,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: EColors.primary,
            backgroundColor: Colors.white,
            shape: const StadiumBorder(),
            onSelected: (bool selected) {
              if (selected) {
                ref.read(itemControllerProvider.notifier).changeSelectedChip(selected: category);
              }
            },
          );
        },
      ),
    );
  }
}