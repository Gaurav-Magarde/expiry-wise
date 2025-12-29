import 'package:expiry_wise_app/features/inventory/data/models/api_product_model.dart';
import 'package:expiry_wise_app/services/api_services/food_api_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/exception/exceptions.dart';
import 'package:expiry_wise_app/core/utils/exception/firebase_auth_exceptions.dart';
import 'package:expiry_wise_app/core/utils/exception/firebase_exceptions.dart';
import 'package:expiry_wise_app/core/utils/exception/format_exceptions.dart';
import 'package:expiry_wise_app/core/utils/exception/platform_exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';
import '../models/item_model.dart';

final addItemRepoProvider = Provider<AddItemRepository>((ref) {
  final FoodApiService apiService = ref.read(foodApiProvider);
  return AddItemRepository(ref, apiService);
});

class AddItemRepository {
  final Ref ref;
  final SqfLiteSetup _sqfLite;
  final FoodApiService _apiService;

  AddItemRepository(this.ref, this._apiService)
    : _sqfLite = ref.read(sqfLiteSetupProvider)
;
  Future<ItemModel?> insertItem({
    String? id,
    String? image,
    required String? imageNetwork,
    required String name,
    required String category,
    required int quantity,
    required String note,
    String? addedDate,
    String? updatedAt,
    required String expiryDate,
    required String unit,
  }) async {
    try {
      final user = ref.read(currentUserProvider);
      final currentUser = user.when(
        data: (data) => data,
        error: (e, s) => null,
        loading: () => null,
      );
      if(currentUser==null) return null;
      final currentUserId = currentUser.id;
      final isInternet = ref.read(isInternetConnectedProvider);
      final fireStoreService = ref.read(fireStoreServiceProvider);
      final currentSpace = ref.read(currentSpaceProvider);
      String? currentSpaceId = currentSpace.when(
        data: (space) => space?.id,
        error: (e, s) => '',
        loading: () => '',
      );
      if (currentSpaceId == null) {
        SnackBarService.showError('Adding product failed no space found');
        return null;
      }
      if (expiryDate.isEmpty ||
          name.isEmpty ||
          category.isEmpty ||
          currentSpaceId.isEmpty ||
          currentUserId.isEmpty) {
        return null;
      }
      ItemModel item = ItemModel(
        updatedAt: updatedAt?? DateTime.now().toString(),
        imageNetwork: imageNetwork??'',
        unit: unit,
        id: id,
        image: image ?? "",
        name: name,
        expiryDate: expiryDate,
        category: category,
        quantity: quantity,
        note: note,
        addedDate: addedDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        userId: currentUserId,
        spaceId: currentSpaceId,

      );
      print('Added product added date is= > ${item.addedDate}');
      await _sqfLite.insertItem(item);
      if (isInternet && currentUser.userType=='google') {
        await fireStoreService.insertItemToFirebase(
          currentUserId,
          currentSpaceId,
          item,
        );
      }
      return item;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<ItemModel?> updateItem({
    String? id,
    required String? image,
    required String? imageNetwork,
    required String name,
    required String category,
    required int quantity,
    required String note,
    String? addedDate,
    String?  updatedAt,
    required String expiryDate,
    required String unit,

  }) async {
    try {
      final user = ref.read(currentUserProvider);
      final currentUser =  user.when(
        data: (data) => data,
        error: (e, s) => null,
        loading: () => null,
      );
      final currentSpace = ref.read(currentSpaceProvider);
      final isInternet = ref.read(isInternetConnectedProvider);
      final currentSpaceId = currentSpace.when(
        data: (space) => space?.id,
        error: (e, s) => '',
        loading: () => '',
      );
      if (currentSpaceId == null) {
        SnackBarService.showError('Adding product failed no space found');
        return null;
      }
      if (expiryDate.isEmpty ||
          name.isEmpty ||
          category.isEmpty ||
          currentSpaceId.isEmpty ||
          currentUser == null ||
          currentUser.id.isEmpty) {
        return null;
      }
      ItemModel item = ItemModel(
        updatedAt: updatedAt?? DateTime.now().toString(),
        imageNetwork: imageNetwork??'',
        unit: unit,
        id: id,
        image: image ?? "",
        name: name,
        expiryDate: expiryDate,
        category: category,
        quantity: quantity,
        note: note,
        addedDate: addedDate,
        userId: currentUser.id,
        spaceId: currentSpaceId,
      );
      final fireStoreService = ref.read(fireStoreServiceProvider);

         await _sqfLite.updateItem(item);
     if(isInternet && currentUser.userType=='google') {
       await fireStoreService.updateItemFromFirebase(
        map: item.toMap(),
        id: item.spaceId ?? '',
      );

     }
      return item;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions();
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<ApiProductModel> fetchItemByBarcode(String next) async {
    try {
      final data = await _apiService.getProductByBarcode(next);
      final ApiProductModel product = ApiProductModel.fromMap(data!);
      return product;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } on FormatException catch (e) {
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }
}
