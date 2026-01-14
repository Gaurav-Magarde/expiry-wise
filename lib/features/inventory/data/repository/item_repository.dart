import 'package:expiry_wise_app/services/api_services/food_api_service.dart';
import 'package:expiry_wise_app/core/utils/loaders/image_api.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';
import '../../../../services/local_db/sqflite_setup.dart';
import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';

final itemRepoProvider = Provider((ref)

{
  final fireStoreProvider = ref.read(fireStoreServiceProvider);
  final sqfLite = ref.read(sqfLiteSetupProvider);
  final foodApi = ref.read(foodApiProvider);
  return ItemRepository(fireStoreProvider,ref, sqfLite,foodApi);
});

class ItemRepository {
  final Ref ref;
  final SqfLiteSetup _sqfLite;
  final FoodApiService _foodApiService;
  final FireStoreService fireStoreService;
  ItemRepository(this.fireStoreService ,this.ref,  this._sqfLite, this._foodApiService);


  Future<bool> deleteItem({required String userId,required String itemPath,required String itemId}) async {
    try{
      final spaceId = ref.read(currentSpaceProvider.select((s) => s.value?.id));
      if(spaceId==null){
        SnackBarService.showError('No space found');
        return false;
      }
      final fireStore = ref.read(fireStoreServiceProvider);
      final user = ref.read(currentUserProvider);
      if(user.isLoading || user.hasError || user.value == null || user.value!.id.isEmpty) {
        SnackBarService.showError('No user found');
        return false;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if(!isInternet && user.value!.userType=='google'){
        SnackBarService.showMessage('check your internet connection');
        return false;
      }
      if(isInternet && user.value!.userType=='google') await fireStore.deleteItemFromFirebase(spaceId: spaceId,id: itemId);
      final deleted = await _sqfLite.deleteItem(itemId : itemId,spaceId: spaceId);
      await ref.read(apiImageProvider).deleteLocalImage(itemPath);
      return deleted;
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }

  Future<void> getDetailByBarcode(String barcode) async{
    try{

      final isInternet = ref.read(isInternetConnectedProvider);
      if(isInternet) final item = await _foodApiService.getProductByBarcode(barcode);

    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code).message;
    } on PlatformException catch (e){
      throw TPlatformException(e.code).message;
    } on FormatException catch (e){
      throw TFormatException(e.message).message;
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code).message;
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }

}
