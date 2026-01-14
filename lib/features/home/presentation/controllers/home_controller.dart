import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';

import '../../../inventory/data/models/item_model.dart';


final recentlyItemsProvider = Provider<AsyncValue<List<ItemModel>>>((ref){

  final allItemsAsync = ref.watch(itemsStreamProvider);

  
  return allItemsAsync.whenData(
      (list){
        final recent = list.where((item)=>item.finished==0).toList();
        recent.sort((a,b){
          final dateA = DateFormat(DateFormatPattern.dateformatPattern).tryParse(a.addedDate!)??DateTime.now();
          final dateB = DateFormat(DateFormatPattern.dateformatPattern).tryParse(b.addedDate!)??DateTime.now();
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
          if(item.expiryDate==null) return false;
          final dateA = DateFormat(DateFormatPattern.dateformatPattern).tryParse(item.expiryDate??'')??DateTime(1099);
          return item.finished==0&& item.expiryDate!=null && dateA.isBefore(now.subtract(const Duration(days: 1)));
        }).toList();
        expired.sort((a,b){

          final dateA = DateFormat(DateFormatPattern.dateformatPattern).tryParse(a.expiryDate??'')??DateTime(2099);
          final dateB = DateFormat(DateFormatPattern.dateformatPattern).tryParse(b.expiryDate??'')??DateTime(2099);
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
          final dateA = DateFormat(DateFormatPattern.dateformatPattern).tryParse(item.expiryDate??'')??DateTime(2099);
          return item.finished==0 && item.expiryDate!=null && dateA.isAfter(now.subtract(const Duration(days: 0))) && dateA.isBefore(now.add(const Duration(days: 7)));
        }).toList();
        expiring.sort((a,b){
          final dateA = DateFormat(DateFormatPattern.dateformatPattern).parse(a.expiryDate!);
          final dateB = DateFormat(DateFormatPattern.dateformatPattern).parse(b.expiryDate!);
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