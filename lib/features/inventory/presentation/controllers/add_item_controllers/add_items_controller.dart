import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/add_item_reposotory.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v4.dart';

import '../../../../../core/utils/loaders/image_api.dart';
import '../../../../../services/Connectivity/internet_connectivity.dart';
import '../../../../../core/utils/validators/validators.dart';
import '../../../data/models/item_model.dart';
import 'add_item_state.dart';

final addItemStateProvider = NotifierProvider.autoDispose
    .family<AddItemController, AddItemState, String?>((item) {
      return AddItemController(item);
    });

class AddItemController extends Notifier<AddItemState> {
  late AddItemRepository addItemRepository;
  late ImageService _saveImageRepo;
  final String? id;
  AddItemController(this.id);
  @override
  AddItemState build() {
    addItemRepository = ref.read(addItemRepoProvider);
    _saveImageRepo = ref.read(apiImageProvider);

    if (id == null) {
      return AddItemState.empty();
    }
    List? list = ref.read(itemsStreamProvider).value;
    if (list == null || list.isEmpty) return AddItemState.empty();
    ItemModel? item = list.firstWhereOrNull((e) => e.id == id);
    if (item == null) return AddItemState.empty();
    return AddItemState.newStateByParameter(
      price: item.price,
      isExpenseLinked: item.isExpenseLinked??false,
      finished: item.finished,
      prevImage: item.image,
      category: item.category,
      unit: item.unit,
      expiryDate: item.expiryDate,
      addedDate: item.addedDate ?? '',
      name: item.name,
      note: item.note,
      quantity: item.quantity.toString(),
      image: item.image,
      selectedDays: item.notifyConfig,
    );
  }

  Future<void> loadAsyncDependencies() async {
    if(id==null && state.selectedDays.isEmpty){
      final list = await ref.read(prefsServiceProvider).getNotificationDays();
      state = state.copyWith(selectedDays: list);
    }
  }

  Future<ItemModel?> insertItem() async {
    try {
      final currentUser = ref.read(currentUserProvider).value;
      final currentSpace = ref.read(currentSpaceProvider).value;
      final notification = ref.read(notificationServiceProvider);
      final prefs= ref.read(prefsServiceProvider);
      if (currentUser == null) {
        SnackBarService.showMessage('No user found');
        return null;
      }
      if (currentSpace == null) {
        SnackBarService.showMessage('No space selected !');
        return null;
      }
      if (state.itemNameController.text.trim().isEmpty) {
        SnackBarService.showError(" Enter the product name");
        return null;
      }
      final local = state.image == null || state.image!.isEmpty
          ? ''
          : await _saveImageRepo.saveImage(File(state.image!));
      String? url = '';
      final isInternet = ref.read(isInternetConnectedProvider);
      if (currentUser.userType == 'google' &&
          isInternet &&
          state.prevImage != state.image) {
        url = state.image == null || state.image!.isEmpty
            ? ''
            : await _saveImageRepo.uploadImage(File(state.image!));

      }
      final item = ItemModel(isExpenseLinked: state.isExpenseLinked,
        price: state.price,
        finished: 0,
        notifyConfig: state.selectedDays,
        unit: state.unit,
        image: local??'',

        name: state.itemNameController.text,
        expiryDate: state.expiryDate,
        category: state.category,
        quantity: int.tryParse(state.itemQtyController.text) ?? 1,
        note: state.noteController.text,
        addedDate: state.addedDate??DateFormat(DateFormatPattern.dateformatPattern).format(DateTime.now()),
        imageNetwork: url??'',
      userId: currentUser.id,
        spaceId: currentSpace.id,
        updatedAt: DateTime.now().toString(),
        id: Uuid().v4()
      );
       await addItemRepository
          .insertItem(
        item: item
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Internet is too slow');
            },
          );
      await ref.read(expenseStateController.notifier).addExpenseFromItem(item: item);


      final isNotification = await prefs.getIsNotificationOn();
      if(isNotification && item.finished==0){
        notification.scheduleNotificationFor(item);      SnackBarService.showSuccess('Product added successfully');
      }else{
        notification.cancelNotificationFor(item);
      }
        return item;
    } on TimeoutException catch (e) {
      SnackBarService.showError('Product added failed. ${e.message}');
    } catch (e) {
      SnackBarService.showError('Product added failed.');
    }
    return null;
  }

  Future<ItemModel?> updateItem(String? id,finished) async {
    final notification = ref.read(notificationServiceProvider);
    final prefs= ref.read(prefsServiceProvider);
    try {
      final currentUser = ref.read(currentUserProvider).value;
      final user = ref.read(currentUserProvider);
      if (user.isLoading ||
          user.hasError ||
          user.value == null ||
          user.value!.id.isEmpty) {
        SnackBarService.showError('No user found');
        return null;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if (!isInternet && user.value!.userType == 'google') {
        SnackBarService.showMessage('check your internet connection');
        return null;
      }
      final currentSpace = ref.read(currentSpaceProvider).value;
      if (currentUser == null) {
        SnackBarService.showMessage('No user found');
        return null;
      }
      if (currentSpace == null) {
        SnackBarService.showMessage('No space selected !');
        return null;
      }
      if (state.itemNameController.text.trim().isEmpty) {
        SnackBarService.showError("Please Enter the product name");
        return null;
      }

      final local = state.prevImage == state.image
          ? state.image
          : state.image == null || state.image!.isEmpty
          ? ''
          : await _saveImageRepo.saveImage(File(state.image!));
      String? url = '';
      if (currentUser.userType == 'google' &&
          isInternet &&
          state.image != state.prevImage) {
        url = state.image == null || state.image!.isEmpty
            ? ''
            : await _saveImageRepo.uploadImage(File(state.image!));
      }
      if (state.prevImage != state.image) {
        await ref.read(apiImageProvider).deleteLocalImage(state.prevImage);
      }
      final item = await addItemRepository
          .updateItem(
        price: state.price,
        isExpenseLinked:state.isExpenseLinked,
        finished: finished,
        notificationDays: state.selectedDays,
            id: id,
            unit: state.unit,
            image: local,
            imageNetwork: url,
            name: state.itemNameController.text,
            expiryDate: state.expiryDate,
            category: state.category,
            quantity: int.tryParse(state.itemQtyController.text) ?? 1,
            note: state.noteController.text,
            addedDate: state.addedDate,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Internet is too slow');
            },
          );
      if (item!=null ) {
        SnackBarService.showSuccess('Product updated successfully');
        final isNotification = await prefs.getIsNotificationOn();
        if(isNotification && item.finished==0) {
          notification.scheduleNotificationFor(item);
        }else{
          notification.cancelNotificationFor(item);
        }
      }

      return item;
    } on TimeoutException catch (e) {
      SnackBarService.showError('Product added failed. ${e.message}');
    } catch (e) {
      SnackBarService.showError('Product updated failed. $e');
    }
    return null;
  }

  void copyWith({
    String? category,
    String? expiryDate,
    String? unit,
    bool? isExpenseLinked,
    String? price,
    String? image,
    List<int>? selectedDays
  }) {
    state = state.copyWith(
      isExpenseLinked: isExpenseLinked,
      price: double.tryParse(price??""),
      expiryDate: expiryDate,
      category: category,
      unit: unit,
      image: image,
      selectedDays: selectedDays
    );
    return;
  }

  void changeState({required ItemModel item}) {
    try {
      state = AddItemState.newStateByParameter(
        isExpenseLinked: item.isExpenseLinked??false,
        price: item.price,
        finished: item.finished,
        prevImage: item.image,
        category: item.category,
        unit: item.unit,
        expiryDate: item.expiryDate,
        addedDate: item.addedDate!,
        name: item.name,
        note: item.note,
        quantity: item.quantity.toString(),
        image: item.image,
        selectedDays: state.selectedDays,
      );
    } catch (e) {
      SnackBarService.showError("$e");
    }
  }

  Future<void> fetchItemByBarcode(String next) async {
    try {
      final apiProduct = await addItemRepository.fetchItemByBarcode(next);
      if(apiProduct==null) return;
      state = state.copyWith(
        image: apiProduct.photoUrl,
        unit: apiProduct.unit,
        name: apiProduct.name,
        quantity: apiProduct.quantity.toString(),
      );
      if (apiProduct.name.isEmpty &&
          apiProduct.photoUrl.isEmpty &&
          apiProduct.unit.isEmpty) {
        SnackBarService.showMessage("product Not found");
      } else {
        SnackBarService.showMessage("product found");
      }
    } catch (e) {
      SnackBarService.showError("Item fetch failed. ${e.toString()}");
    }
  }

  bool validateAllFields() {
    try {
      if (!Validators.validateName(name: state.itemNameController.text)) {
        SnackBarService.showError("Please Enter the product name");
        return false;
      }
      if (!Validators.validateExpiry(expiry: state.expiryDate)) {
        SnackBarService.showError("Please Enter the expiry date");
        return false;
      }
      return true;
    } catch (e) {
      SnackBarService.showMessage('something went wrong');
      return false;
    }
  }
}

final isItemAddingProvider = StateProvider.autoDispose<bool>((ref) => false);

final currentImageProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final scannedBarcodeProvider = StateProvider.autoDispose<String?>((ref) {
  return null;
});
final isProductFindingProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});
