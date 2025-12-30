import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/item_model.dart';


final recentlyItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref){

  final allItemsAsync = ref.watch(itemsStreamProvider);
  
  
  return allItemsAsync.whenData(
      (list){
        final recent = List<ItemModel>.from(list);
        recent.sort((a,b){
          final dateA = DateTime.parse(a.addedDate!);
          final dateB = DateTime.parse(b.addedDate!);
          return dateA.compareTo(dateB);
        });
        
        return recent.take(10).toList();
      }
  );
});


final expiredItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref)  {

  final allItemsAsync = ref.watch(itemsStreamProvider);

  return allItemsAsync.whenData(
          (list){
        final now = DateTime.now();    
        final expired = list.where((item){
          final dateA = DateTime.parse(item.expiryDate);
          return now.isAfter(dateA);
        }).toList();
        expired.sort((a,b){
          final dateA = DateTime.parse(a.expiryDate);
          final dateB = DateTime.parse(b.expiryDate);
           Future.delayed(Duration(seconds: 1));
          return dateA.compareTo(dateB);
        });

        return expired;
      }
  );
});

final expiringSoonItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref){

  final allItemsAsync = ref.watch(itemsStreamProvider);


  return allItemsAsync.whenData(
          (list){
        final now = DateTime.now();
        final expiring = list.where((item){
          final dateA = DateTime.parse(item.expiryDate);
          return now.isBefore(dateA) && dateA.isBefore(now.add(Duration(days: 7)));
        }).toList();
        expiring.sort((a,b){
          final dateA = DateTime.parse(a.addedDate!);
          final dateB = DateTime.parse(b.addedDate!);
          return dateA.compareTo(dateB);
        });

        return expiring;
      }
  );
});


final selectedContainerProvider = StateProvider<SelectedContainer>((ref)=>SelectedContainer.expired);

enum SelectedContainer{
  expired,expiring,recent
}