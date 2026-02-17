import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/item_model.dart';
import 'item_controller.dart';

enum OrderBy { expiry, added, name }

final allItemsState = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final asyncData = ref.watch(itemsStreamProvider);
  final order = ref.watch(itemControllerProvider.select((s) => s.order));
  final selectedCategory = ref.watch(
    itemControllerProvider.select((s) => s.selectedChip),
  );
  return asyncData.whenData((allItems) {
    final items = List<ItemModel>.from(allItems);
    items.removeWhere((item) => item.finished != 0);

    final visibleItems = items.where((item) {
      if (selectedCategory == null) return true;
      return item.category == selectedCategory;
    }).toList();

    switch (order) {
      case OrderBy.expiry:
        visibleItems.sort((a, b) {
          DateTime dateA =
              DateFormat(
                DateFormatPattern.dateformatPattern,
              ).tryParse(a.expiryDate ?? '') ??
              DateTime(2099);
          DateTime dateB =
              DateFormat(
                DateFormatPattern.dateformatPattern,
              ).tryParse(b.expiryDate ?? '') ??
              DateTime(2099);
          return dateA.compareTo(dateB);
        });
        break;

      case OrderBy.added:
        visibleItems.sort((a, b) => b.addedDate!.compareTo(a.addedDate!));
        break;
      case OrderBy.name:
        visibleItems.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return visibleItems;
  });
});

final finishedItemsState = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final asyncData = ref.watch(itemsStreamProvider);
  final selectedCategory = ref.watch(
    itemControllerProvider.select((s) => s.selectedChip),
  );

  return asyncData.whenData((allItems) {
    final items = List<ItemModel>.from(allItems);
    items.removeWhere((item) => item.finished == 0);
    final visibleItems = items.where((item) {
      if (selectedCategory == null) return true;
      return item.category == selectedCategory;
    }).toList();
    visibleItems.sort((a, b) => a.name.compareTo(b.name));

    return visibleItems;
  });
});
