import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/add_item_reposotory.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/utils/loaders/image_api.dart';
import '../../../../../services/Connectivity/internet_connectivity.dart';
import '../../../data/models/item_model.dart';

final itemControllerProvider = Provider((ref) => ItemController(ref));

class ItemController {
  final Ref ref;
  final ItemRepository _itemRepo;
  ItemController(this.ref) : _itemRepo = ref.read(itemRepoProvider);

  Future<bool> deleteItem({required ItemModel item}) async {
    try {
      final user = ref.read(currentUserProvider);
      if (user.isLoading ||
          user.hasError ||
          user.value == null ||
          user.value!.id.isEmpty) {
        SnackBarService.showError('No user found');
        return false;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if (!isInternet && user.value!.userType == 'google') {
        SnackBarService.showMessage('check your internet connection');
        return false;
      }
      final itemId = item.id;
      final userId = item.userId;
      final itemRepo = ref.read(itemRepoProvider);

      final deleted = await itemRepo.deleteItem(
        userId: userId ?? "",
        itemId: itemId,
        itemPath: item.image,
      );
      if(!deleted) return false;
      final notify = ref.read(notificationServiceProvider);
      await notify.cancelNotificationFor(item);
      SnackBarService.showSuccess('Product ${item.name} successfully deleted');
      return true;
    } catch (e) {
      SnackBarService.showError('Product ${item.name} delete failed $e');
      return false;
    }
  }

  Future<bool> insertItemFromFirebase({
    required ItemModel item,
    required ItemModel? prev,
  }) async {
    try {
      final itemRepo = ref.read(addItemRepoProvider);
      final prefs = ref.read(prefsServiceProvider);
      final isNotifyOn = await prefs.getIsNotificationOn();
      if (prev == null) {
        final item2 = await itemRepo.insertItem(item: item
        );
        if(isNotifyOn && item.finished==0){
          ref.read(notificationServiceProvider).scheduleNotificationFor(item);

        }else{
          ref.read(notificationServiceProvider).cancelNotificationFor(item);
        }
          return item2!=null;

      } else {
        if (prev.image.isNotEmpty && prev.image != item.image) {
          await ref.read(apiImageProvider).deleteLocalImage(prev.image);
        }

        final item2 = await itemRepo.updateItem(
          price: item.price,
          isExpenseLinked: item.isExpenseLinked,
          finished: item.finished,
          image: item.image,
          imageNetwork: item.imageNetwork,
          name: item.name,
          category: item.category,
          quantity: item.quantity,
          note: item.note,
          expiryDate: item.expiryDate,
          unit: item.unit,
          id: item.id,
          addedDate: item.addedDate,
          updatedAt: item.updatedAt,
          notificationDays: item.notifyConfig,
        );
        if(isNotifyOn && item.finished==0) {
          ref.read(notificationServiceProvider).scheduleNotificationFor(item);
        }else{
          ref.read(notificationServiceProvider).cancelNotificationFor(item);
        }
          return item2!=null;
      }

    } catch (e) {
      SnackBarService.showError('Product ${item.name} delete failed $e');
      return false;
    }
  }


}

final itemsStreamProvider = StreamProvider<List<ItemModel>>((ref) async* {
  final localStorage = ref.read(sqfLiteSetupProvider);
  final currentSpaceId = ref.watch(currentSpaceProvider).value?.id;
  localStorage.refreshItems(spaceId: currentSpaceId);
  yield* localStorage.itemStream;
});
