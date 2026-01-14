import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../../data/models/item_model.dart';
import 'item_controller.dart';

enum OrderBy{
  expiry,
  added,
  name
}

final allItemsState = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final asyncData = ref.watch(itemsStreamProvider);
  final order = ref.watch(orderProvider); // Sirf Active me sorting chahiye
  final selectedCategory = ref.watch(selectedChipProvider);

  return asyncData.whenData((allItems) {

    final list = List<ItemModel>.from(allItems);
    list.removeWhere((item) => item.finished != 0);

    if (selectedCategory.toLowerCase() != 'all') {
      list.removeWhere((item) =>
      item.category.toUpperCase() != selectedCategory.toUpperCase());
    }

    if (order == OrderBy.expiry) {
      list.sort((a, b) {
        DateTime dateA = DateFormat(DateFormatPattern.dateformatPattern).tryParse(a.expiryDate??'') ?? DateTime(2099);
        DateTime dateB = DateFormat(DateFormatPattern.dateformatPattern).tryParse(b.expiryDate??'') ?? DateTime(2099);
        return dateA.compareTo(dateB);
      });
    } else if (order == OrderBy.added) {
      list.sort((a, b) => b.addedDate!.compareTo(a.addedDate!));
    } else {
      list.sort((a, b) => a.name.compareTo(b.name));
    }
    return list;
  });
});

final finishedItemsState = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final asyncData = ref.watch(itemsStreamProvider);
  final selectedCategory = ref.watch(selectedChipProvider);

  return asyncData.whenData((allItems) {
    // List copy ki
    final list = List<ItemModel>.from(allItems);

    // 1. Logic: Jo item Finished NAHI hai (Active hai), unhe hata do
    list.removeWhere((item) => item.finished == 0);

    // 2. Logic: Category Filter
    if (selectedCategory.toLowerCase() != 'all') {
      list.removeWhere((item) =>
      item.category.toUpperCase() != selectedCategory.toUpperCase());
    }

    // 3. Logic: Sorting (Name only)
    list.sort((a, b) => a.name.compareTo(b.name));

    return list;
  });
});


final allItemsSearchText = StateProvider.autoDispose<String>((ref)=>'');
final orderProvider = StateProvider<OrderBy>((ref)=>OrderBy.expiry);
final isSearchingProvider = StateProvider<bool>((ref)=>false);
final selectedChipProvider = StateProvider.autoDispose<String>((ref)=>'all');
final isItemsSortingProvider = StateProvider<bool>((ref)=>false);

