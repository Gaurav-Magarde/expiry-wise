import '../../../../../../core/theme/colors.dart';
import '../../../../data/models/category_helper_model.dart';
import '../../../controllers/add_items_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class CategorySelectorWidget extends ConsumerWidget {
  const CategorySelectorWidget({super.key, required this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final AddItemController stateController = ref.read(provider.notifier);
    return Consumer(
      builder: (context, ref, child) {
        final selectedCategory = ref.watch(provider.select((s) => s.category));
        final selected = ItemCategory.values.firstWhere(
              (e) => e.name == selectedCategory,
          orElse: () => ItemCategory.grocery,
        );

        return InputDecorator(
          decoration: InputDecoration(
            labelText: 'Category',
            labelStyle: const TextStyle(color: Colors.grey),
            prefixIcon: Icon(selected.icon, color: EColors.accentPrimary),
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
            child: DropdownButton<ItemCategory>(
              value: selected,
              isExpanded: true,
              isDense: true,
              items: ItemCategory.values.map((category) {
                return DropdownMenuItem<ItemCategory>(
                  value: category,
                  child: Text(
                    category.label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.apply(color: category.color),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val == null) return;
                stateController.copyWith(category: val.name);
              },
            ),
          ),
        );
      },
    );
  }
}
