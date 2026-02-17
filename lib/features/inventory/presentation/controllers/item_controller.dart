import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/services/item_services.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/item_model.dart';
import 'all_item_controller.dart';
part 'item_controller.freezed.dart';

final itemControllerProvider = NotifierProvider(() => ItemController());

///Inventory State
@freezed
sealed class InventoryScreenState with _$InventoryScreenState {
  const factory InventoryScreenState({
    required OrderBy order,
    String? searchText,
    required bool isItemLoading,
    String? selectedChip,
  }) = _InventoryScreenState;
}

/// [Inventory] [Controller]

class ItemController extends Notifier<InventoryScreenState> {
  ItemController();
  @override
  InventoryScreenState build() {
    return const InventoryScreenState(
      searchText: null,
      order: OrderBy.name,
      isItemLoading: false,
      selectedChip: null,
    );
  }

  void changeSearchText({String? searchText}) {
    state = state.copyWith(searchText: searchText);
  }

  void changeSelectedChip({String? selected}) {
    state = state.copyWith(selectedChip: selected);
  }

  void changeOrder({required OrderBy order}) {
    state = state.copyWith(order: order);
  }

  void toggleIsItemLoading({required bool isItemLoading}) {
    state = state.copyWith(isItemLoading: isItemLoading);
  }

  Future<bool> deleteItem({required ItemModel item}) async {
    try {
      /// Dependencies
      final user = ref.read(currentUserProvider).value;
      final itemId = item.id;
      await ref
          .read(inventoryServiceProvider)
          .deleteItemUseCase(user: user, itemId: itemId);

      /// Call Repo

      SnackBarService.showSuccess('Product ${item.name} successfully deleted');
    } catch (e) {
      SnackBarService.showError('Product ${item.name} delete failed $e');
    }
    return true;
  }

  Future<bool> insertItemByItemModel({
    required ItemModel item,
    required ItemModel? prev,
  }) async {
    try {
      await ref
          .read(inventoryServiceProvider)
          .addItemByModelUseCase(item: item, prevItem: prev);
      return true;
    } catch (e) {
      SnackBarService.showError('Product ${item.name} delete failed $e');
      return false;
    }
  }
  Future<double> getInventoryValue() async {
    try {
      final space = ref.read(currentSpaceProvider).value;
      if(space==null || space.id.isEmpty) return 0;
      final spaceId = space.id;
      return await ref
          .read(inventoryRepoProvider)
          .getInventoryValue(spaceId: spaceId);
    } catch (e) {
      SnackBarService.showError(e.toString());
      return 0;
    }
  }

}

final itemsStreamProvider = StreamProvider<List<ItemModel>>((ref) async* {
  final localStorage = ref.read(inventoryRepoProvider);
  final currentSpaceId = ref.watch(currentSpaceProvider).value?.id;
  localStorage.refreshItems(spaceId: currentSpaceId);
  yield* localStorage.itemStream;
});
