import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/item_model.dart';
import 'item_controller.dart';

enum OrderBy{
  expiry,
  added,
  name
}

final allItemsState = Provider<AsyncValue<List<ItemModel>>>((ref) {
  final asyncData = ref.watch(itemsStreamProvider);

  final order = ref.watch(orderProvider);



  // print('selected category is => $selectedCategory');

  final selectedCategory = ref.watch(selectedChipProvider);
  return asyncData.whenData((allItems) {
    {
      final list = List<ItemModel>.from(allItems);
      print(list);
      if(selectedCategory!='all') {
        list.removeWhere((item){
        print('item => ${item.category.toUpperCase()}  selected=>${selectedCategory.toUpperCase()}');
        return item.category.toUpperCase()!=selectedCategory.toUpperCase();
      });
      }
      if (order == OrderBy.expiry) {
        list.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a.expiryDate) ?? DateTime(2099);
          DateTime dateB = DateTime.tryParse(b.expiryDate) ?? DateTime(2099);

          return dateA.compareTo(dateB);
        });
      } else if (order == OrderBy.added) {

          list.sort((a, b) => b.addedDate!.compareTo(a.addedDate!));

      } else {

          list.sort((a, b) => a.name.compareTo(b.name));

      }

      return list;
    }
  });
});

final allItemsSearchText = StateProvider.autoDispose<String>((ref)=>'');
final orderProvider = StateProvider<OrderBy>((ref)=>OrderBy.expiry);
final isSearchingProvider = StateProvider<bool>((ref)=>false);
final selectedChipProvider = StateProvider.autoDispose<String>((ref)=>'all');
final isItemsSortingProvider = StateProvider<bool>((ref)=>false);

