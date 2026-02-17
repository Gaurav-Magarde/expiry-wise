import 'package:expiry_wise_app/features/home/presentation/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../inventory/domain/item_model.dart';

class DetailCard extends ConsumerWidget {
  const DetailCard(
    this.color,
    this.icon,
    this.content,
    this.currentContainer, {
    super.key,
  });
  final Gradient color;
  final IconData icon;
  final String content;
  final SelectedContainer currentContainer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(selectedContainerProvider) == currentContainer;
    int quantity = 0;
    final selected = ref.watch(selectedContainerProvider);
    if (currentContainer == SelectedContainer.expired) {
      List<ItemModel> list = <ItemModel>[];
      list = ref.watch(expiredItemsProvider).value ?? [];
      quantity = list.length;
    } else if (currentContainer == SelectedContainer.expiring) {
      List<ItemModel> list = <ItemModel>[];
      list = ref.watch(expiringSoonItemsProvider).value ?? [];
      quantity = list.length;
    } else {
      List<ItemModel> list = <ItemModel>[];
      list = ref.watch(recentlyItemsProvider).value ?? [];
      quantity = list.length;
    }
    return Expanded(
      flex: isSelected ? 10 : 9,
      child: InkWell(
        onTap: () {
          final selected = ref.read(selectedContainerProvider);
          if (selected == currentContainer) return;
          ref.read(selectedContainerProvider.notifier).state = currentContainer;
        },
        child: Container(
          padding:const  EdgeInsets.all(4),
          decoration: BoxDecoration(
            border: Border.all(
              width: isSelected ? 0 : 0,
              color: isSelected ? color.colors.first : Colors.white,
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 5,
                blurStyle: BlurStyle.outer,
                color: isSelected ?  color.colors.first : Colors.white,
              ),
            ],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            // width: 100,
            padding: const EdgeInsets.all(8),
            height: isSelected ? 160 : 150,
            decoration: BoxDecoration(
              gradient: color,
              // border: Border.all(),
              boxShadow: [],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white),
                const  SizedBox(height: 8),
                Text(
                  quantity.toString(),
                  style: Theme.of(context).textTheme.headlineMedium!.apply(
                    color: Colors.white,
                    fontWeightDelta: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.apply(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
