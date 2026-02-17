import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_inteface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../domain/item_model.dart';

class InventoryFirebaseDataSource implements IInventoryRemoteDataSource {
  static const String inventoryCollection = 'items';
  static const String spaceCollection = 'spaces';
  static const String spaceIdKey = 'space_id';
  static const String userIdKey = 'user_id';
  static const String isDeletedKey = 'is_deleted';
  static const String updatedAtKey = 'updated_at';
  static const String isSyncedKey = 'is_synced';

  final instance = FirebaseFirestore.instance;
  @override
  Future<void> insertItemToFirebase(
    String userId,
    String spaceId,
    ItemModel item,
  ) async {
    try {
      final itemInMap = item.toMap();
      itemInMap[isSyncedKey] = 1;
      itemInMap['image'] = '';
      await instance
          .collection(spaceCollection)
          .doc(spaceId)
          .collection(inventoryCollection)
          .doc(item.id)
          .set(itemInMap, SetOptions(merge: true));
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  Future<List<ItemModel>> fetchAllItemsFirebase(
    String? userId,
    String spaceId,
  ) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(spaceCollection)
          .doc(spaceId)
          .collection(inventoryCollection).where(spaceIdKey,isEqualTo: spaceId).where(isDeletedKey,isNotEqualTo: true)
          .get();
      List<ItemModel> list = [];
      for (final s in snapshot.docs) {
        final map = s.data() as Map<String, dynamic>;

        if (map.isEmpty) continue;
        map[isSyncedKey] = 1;

        map['image'] = '';
        list.add(ItemModel.fromMap(item: map));
      }
      return list;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong $e';
    }
  }

  @override
  Future<void> deleteItemFromFirebase({
    required String id,
    required String spaceId,
  }) async {
    try {
      final docRef = await instance
          .collection(spaceCollection)
          .doc(spaceId)
          .collection(inventoryCollection)
          .doc(id);
      final doc = await docRef.get();
      if (doc.exists) {
        await docRef.update({isDeletedKey: true});
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }

  @override
  Future<void> deleteAllItemFromSpace({required String spaceId}) async {
    try {
      final docRef = instance
          .collection(spaceCollection)
          .doc(spaceId)
          .collection(inventoryCollection);
      final docs = await docRef.get();
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (final doc in docs.docs) {
        batch.update(doc.reference,{isDeletedKey:true});
      }
      await batch.commit();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e) {
      throw TPlatformException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on Exception {
      throw const TExceptions().message;
    } catch (e) {
      throw 'some went wrong';
    }
  }
}
