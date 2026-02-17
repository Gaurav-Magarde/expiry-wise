import 'dart:async';
import 'package:collection/collection.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/services/item_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/item_model.dart';
import 'add_item_state.dart';

final addItemStateProvider = NotifierProvider.autoDispose
    .family<AddItemController, AddItemState, String?>((item) {
      return AddItemController(item);
    });

class AddItemController extends Notifier<AddItemState> {
  late InventoryRepository addItemRepository;
  final String? id;
  AddItemController(this.id);
  @override
  AddItemState build() {
    addItemRepository = ref.read(inventoryRepoProvider);

    if (id == null) {
      return AddItemState.empty();
    }
    List? items = ref.read(itemsStreamProvider).value;
    if (items == null || items.isEmpty) return AddItemState.empty();
    ItemModel? item = items.firstWhereOrNull((e) => e.id == id);
    if (item == null) return AddItemState.empty();
    return AddItemState.newStateByItem(item: item);
  }

  Future<void> saveItem() async {
    try {
      /// dependency
      if(state.isSaving){
        return;
      }
      state = state.copyWith(isSaving: true);
      final currentUser = ref.read(currentUserProvider).value;
      final currentSpace = ref.read(currentSpaceProvider).value;

      final currentStateData = state;

      await ref.read(inventoryServiceProvider).addItemUseCase(currentSpace: currentSpace,currentStateData: currentStateData,currentUser: currentUser, itemId: id);

    } on TimeoutException catch (e) {
      SnackBarService.showError('Product added failed. ${e.message}');
    } catch (e) {
      SnackBarService.showError('Product added failed. ${e.toString()}');
    }finally{
      state = state.copyWith(isSaving: false);
    }
  }

  void copyWith({
    String? category,
    String? expiryDate,
    String? unit,
    bool? isExpenseLinked,
    String? price,
    String? name,
    String? image,
    List<int>? selectedDays,
    String? quantity,
    String? note,
    String? barcode,
  }) {
    state = state.copyWith(
      scannedBarcode: barcode,
      note: note,
      quantity: quantity,
      name: name,
      isExpenseLinked: isExpenseLinked,
      price: price != null && price.isEmpty ? 0 : double.tryParse(price ?? '0'),
      expiryDate: expiryDate,
      category: category,
      unit: unit,
      image: image,
      selectedDays: selectedDays,
    );
  }

  Future<void> fetchItemByBarcode(String next) async {
    try {
      final apiProduct = await addItemRepository.fetchItemByBarcode(next);
      if (apiProduct == null) return;
      state = state.copyWith(
        image: apiProduct.photoUrl,
        unit: apiProduct.unit,
        name: apiProduct.name,
        quantity: apiProduct.quantity.toString(),
      );
      if (apiProduct.name.isEmpty &&
          apiProduct.photoUrl.isEmpty &&
          apiProduct.unit.isEmpty) {
        SnackBarService.showMessage('product Not found');
      } else {
        SnackBarService.showMessage('product found');
      }
    } catch (e) {
      SnackBarService.showError('Item fetch failed. ${e.toString()}');
    }
  }










}
