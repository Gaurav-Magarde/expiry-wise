import 'dart:io';

import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_item_model.dart';
import 'package:expiry_wise_app/services/local_db/local_transaction_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../../core/constants/constants.dart';
import '../../../../../core/utils/loaders/image_api.dart';
import '../../../../Space/data/model/space_model.dart';
import '../../../../User/data/models/user_model.dart';
import '../../../domain/item_model.dart';
import '../add_item_state.dart';

final inventoryServiceProvider = Provider<AddItemsUseCase>((ref) {
  final inventoryRepository = ref.read(inventoryRepoProvider);
  final expenseController = ref.read(expenseControllerProvider.notifier);
  final imageService = ref.read(apiImageProvider);
  final localTransaction = ref.read(providerLocalTransactionManager);

  return AddItemsUseCase(
    inventoryRepository: inventoryRepository,
    expenseController: expenseController,
    imageService: imageService,
      localTransaction:localTransaction
  );
});

class AddItemsUseCase {
  final InventoryRepository inventoryRepository;
  final ExpenseStateController expenseController;

  final ImageService imageService;
  final LocalTransactionManager localTransaction;
  const AddItemsUseCase({
    required this.inventoryRepository,
    required this.expenseController,
    required this.imageService,
    required this.localTransaction,
  });
  Future<ItemModel?> addItemUseCase({
    required AddItemState currentStateData,
    required UserModel? currentUser,
    required SpaceModel? currentSpace,
    required String? itemId,
  }) async {
    try {
      _handleAllValidations(
        currentStateData: currentStateData,
        currentUser: currentUser,
        currentSpace: currentSpace,
      );
      final localPath = await _handleLocalImage(currentStateData);
      final item = _itemByCurrentState(
        itemId: itemId,
        currentStateData: currentStateData,
        currentSpaceId: currentSpace!.id,
        currentUserId: currentUser!.id,
        localPath: localPath,
        url: null,
      );
      if (currentStateData.isItemEditing) {
        await inventoryRepository.updateItem(item: item);
      } else {
        await inventoryRepository.addItem(item: item);
      }
      try {
        _handleCloudImage(currentStateData, currentUser, item);
      } catch (e) {}
      try {
        await _handleImageDeletion(currentStateData);
      } catch (e) {
        throw Exception('Image deletion failed');
      }
      try {
        await expenseController.addExpenseFromItem(item: item);
      } catch (e) {}
      return item;
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addItemByModelUseCase({
    required ItemModel item,
    required ItemModel? prevItem,
  }) async {
    try {
      if (prevItem == null) {
        await inventoryRepository.addItem(item: item);
      } else {
        await inventoryRepository.updateItem(item: item);
        if (prevItem.image.isNotEmpty && prevItem.image != item.image) {
          await imageService.deleteLocalImage(prevItem.image);
        }
      }
    } catch (e) {}
  }

  Future<void> deleteItemUseCase({
    required UserModel? user,
    required String itemId,
  }) async {
    try {
      ItemModel? item = await inventoryRepository.getItemByIdLocal(
        itemId: itemId,
      );
      if (item == null) {
        throw Exception('No user or space found');
      }
      if (user == null ||
          user.id.isEmpty ||
          item.spaceId == null ||
          item.spaceId!.isEmpty) {
        throw Exception('No user or space found');
      }
      await inventoryRepository.removeItemLocal(
        id: item.id,
        spaceId: item.spaceId!,
      );

      try {
        if (user.userType == 'google') {
          await inventoryRepository.removeItemRemote(
            id: item.id,
            spaceId: item.spaceId!,
          );
        }
      } catch (e) {}
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addItemFromVoiceCommand({
    required List<AiItemModel> items,
    required SpaceModel? space,
    required UserModel? user,

  }) async {
    if(user==null ||space==null) return;
    final userId = user.id;
    final spaceId = space.id;
    try {
      List<ItemModel> itemsList = [];
      for (final itemDto in items) {
        final price = itemDto.price;
        final name = itemDto.name;
        final quantity = itemDto.quantity;
        final id = const Uuid().v4();
        final addedDate = DateFormat(DateFormatPattern.dateformatPattern).format(DateTime.now());
        final expiryDate = itemDto.expiry;
        final updatedAt = DateTime.now().toIso8601String();
        final category = ItemCategory.values.firstWhere((category)=>category.name==itemDto.category,orElse: ()=>ItemCategory.others);
        final item = ItemModel(

          id: id,
          addedDate: addedDate,
          finished: 0,
          isExpenseLinked: false,
          image: '',
          imageNetwork: '',
          userId: userId,
          price: price,
          spaceId: spaceId,
          name: name,
          expiryDate: expiryDate,
          updatedAt: updatedAt,
          category: category.toString(),
          quantity: 1,
          note: '',
          unit: 'kg',
          notifyConfig: [],
        );
        itemsList.add(item);
      }
      await localTransaction.executeAtomic(action: (batch){
        inventoryRepository.insertItemsLocally(items: itemsList, batch: batch);
      });
    } catch (e) {}
  }

  void _handleAllValidations({
    required AddItemState currentStateData,
    required UserModel? currentUser,
    required SpaceModel? currentSpace,
  }) {
    /// Validating user and space
    if (currentUser == null || currentSpace == null) {
      throw Exception('user or space not found ');
    }

    ///Checking input fields
    if (currentStateData.itemName == null ||
        currentStateData.itemName!.isEmpty) {
      throw Exception(' Enter the product name');
    }
  }

  Future<void> _handleCloudImage(
    AddItemState currentStateData,
    UserModel currentUser,
    ItemModel item,
  ) async {
    if (currentUser.userType == 'google' &&
        currentStateData.prevImage != currentStateData.image) {
      final url =
          currentStateData.image == null || currentStateData.image!.isEmpty
          ? ''
          : await imageService.uploadImage(File(currentStateData.image!));
      final syncedItem = _itemByCurrentState(
        itemId: item.id,
        currentStateData: currentStateData,
        currentSpaceId: item.id,
        currentUserId: currentUser.id,
        localPath: item.image,
        url: url,
      );
      if (url != null) await inventoryRepository.updateItem(item: syncedItem);
    }
  }

  Future<String?> _handleLocalImage(AddItemState currentStateData) async {
    final localPath =
        currentStateData.image == null || currentStateData.image!.isEmpty
        ? ''
        : await imageService.saveImage(File(currentStateData.image!));

    return localPath;
  }

  Future<void> _handleImageDeletion(AddItemState currentStateData) async {
    if (currentStateData.prevImage != currentStateData.image) {
      await imageService.deleteLocalImage(currentStateData.prevImage);
    }
  }

  ItemModel _itemByCurrentState({
    required AddItemState currentStateData,
    required String? localPath,
    required String? url,
    required String? itemId,
    required String currentUserId,
    required String currentSpaceId,
  }) {
    return ItemModel(
      isExpenseLinked: currentStateData.isExpenseLinked,
      price: currentStateData.price,
      finished: currentStateData.finished,
      notifyConfig: currentStateData.selectedDays,
      unit: currentStateData.unit,
      image: localPath ?? '',

      name: currentStateData.itemName!,
      expiryDate: currentStateData.expiryDate,
      category: currentStateData.category,
      quantity: int.tryParse(currentStateData.itemQty ?? '') ?? 1,
      note: currentStateData.note ?? '',
      addedDate:
          currentStateData.addedDate ??
          DateFormat(
            DateFormatPattern.dateformatPattern,
          ).format(DateTime.now()),
      imageNetwork: url ?? '',
      userId: currentUserId,
      spaceId: currentSpaceId,
      updatedAt: DateTime.now().toString(),
      id: itemId ?? const Uuid().v4(),
    );
  }
}
