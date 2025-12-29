

import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/add_item_reposotory.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/loaders/image_api.dart';
import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../data/models/item_model.dart';

final itemControllerProvider = Provider((ref)=>ItemController(ref));

class ItemController {
  final Ref ref;
  final ItemRepository _itemRepo;
  ItemController(this.ref): _itemRepo = ref.read(itemRepoProvider);


  Future<void> deleteItem({required ItemModel item}) async {

    try{
      final user = ref.read(currentUserProvider);
      if(user.isLoading || user.hasError || user.value == null || user.value!.id.isEmpty) {
        SnackBarService.showError('No user found');
        return;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if(!isInternet && user.value!.userType=='google'){
        SnackBarService.showMessage('check your internet connection');
        return;
      }
      final itemId = item.id;
      final userId = item.userId;
      final itemRepo = ref.read(itemRepoProvider);
      print('approx deleted => ${item.name}');

      await itemRepo.deleteItem(userId : userId??"",itemId: itemId,itemPath: item.image);
      SnackBarService.showSuccess('Product ${item.name} successfully deleted');

    }catch(e){
      SnackBarService.showError('Product ${item.name} delete failed $e');
    }
  }
  Future<void> insertItemFromFirebase({required ItemModel item,required ItemModel? prev,}) async {

    try{
      final itemRepo = ref.read(addItemRepoProvider);
      if(prev==null) {
        print('itemmm  inserted   ==>>>  ${item.name}');

        await itemRepo.insertItem(image: item.image, imageNetwork: item.imageNetwork, name: item.name, category: item.category, quantity: item.quantity, note: item.note, expiryDate: item.expiryDate, unit: item.unit,id: item.id,addedDate: item.addedDate,updatedAt: item.updatedAt,);
      } else {
        print('itemmm  updated   ==>>>  ${item.name}');

        if(prev.image.isNotEmpty && prev.image!=item.image){
          await ref
              .read(apiImageProvider)
              .deleteLocalImage(prev.image);
        }
        await itemRepo.updateItem(image: item.image, imageNetwork: item.imageNetwork, name: item.name, category: item.category, quantity: item.quantity, note: item.note, expiryDate: item.expiryDate, unit: item.unit,id: item.id,addedDate: item.addedDate,updatedAt: item.updatedAt);
      }
    }catch(e){
      SnackBarService.showError('Product ${item.name} delete failed $e');
    }
  }
}

final itemsStreamProvider = StreamProvider<List<ItemModel>>((ref){

  final localStorage = ref.read(sqfLiteSetupProvider);
  final currentSpaceId = ref.watch(currentSpaceProvider).value?.id;
  localStorage.refreshItems(spaceId: currentSpaceId);

  return localStorage.itemStream;
});