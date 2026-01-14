import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/utils/loaders/image_api.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/Member/data/models/member_model.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/expenses/presentation/controllers/expense_controllers.dart';
import '../Connectivity/internet_connectivity.dart';

final syncProvider = Provider((ref) {
  final sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  final fireStoreService = ref.read(fireStoreServiceProvider);

  return LocalFirebaseSyncing(sqfLiteSetup, fireStoreService, ref);
});

class LocalFirebaseSyncing {
  final Ref ref;
  final SqfLiteSetup _sqfLiteSetup;
  final FireStoreService _fireStoreService;
  LocalFirebaseSyncing(this._sqfLiteSetup, this._fireStoreService, this.ref);

  Future<void> performAutoSync({bool isAllSync = false}) async {
    try {
      bool isAutoSync = await ref.read(prefsServiceProvider).getAutoSync();
      if (!isAllSync && !isAutoSync) return;
      final firebaseStreams = ref.read(firebaseStreamProvider);
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null ||
          currentUser.id.isEmpty ||
          currentUser.userType == 'guest')
        return;
      final isInternet = ref.read(isInternetConnectedProvider);
      if (!isInternet) {
        SnackBarService.showToast(
          'Auto sync failed.please check internet connection',
        );
        return;
      }
      await syncAllItemsNotSync();

      await firebaseStreams.syncAllData(currentUser.id, SyncType.auto);
      SnackBarService.showToast('Auto sync completed');
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentSpaceProvider);
    } catch (e) {}
  }

  Future<void> performManualSync() async {
    try {
      final firebaseStreams = ref.read(firebaseStreamProvider);
      final currentUser = await ref.read(currentUserProvider.future);
      if (currentUser == null || currentUser.id.isEmpty) {
        SnackBarService.showMessage('user not found');

        return;
      }
      if (currentUser.userType == 'guest') {
        SnackBarService.showMessage('login with google to sync the items');

        return;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      if (!isInternet) {
        SnackBarService.showMessage(
          'sync failed.please check internet connection',
        );
        return;
      }
      await syncAllItemsNotSync();
      await firebaseStreams.syncAllData(currentUser.id, SyncType.manual);
      SnackBarService.showToast('All items synced successfully');
      ref.invalidate(currentUserProvider);
      ref.invalidate(currentSpaceProvider);
    } catch (e) {
      SnackBarService.showMessage('sync failed.please try again later');
    }
  }

  Future<void> syncAllItemsNotSync() async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null ||
        currentUser.id.isEmpty ||
        currentUser.userType == 'guest')
      return;
    final users = await _sqfLiteSetup.getUserNotSynced();
    for (var user in users) {
      try {
        if (user.userType == 'guest') continue;
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'sync failed.please check internet connection',
          );
          return;
        }
        await _fireStoreService.saveUserTOFirebase(user);
        await _sqfLiteSetup.markUserAsSynced(user.id);
      } catch (e) {}
    }

    final spaces = await _sqfLiteSetup.findNonSyncedSpace();
    for (var space in spaces) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'sync failed.please check internet connection',
          );
          return;
        }
        await _fireStoreService.insertSpaceTOFirebase(space.userId, space);
        // SUCCESS: Local DB update
      } catch (e) {}
    }

    // 3.
    final members = await _sqfLiteSetup.fetchAllNonSyncedMember();
    for (var mem in members) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'Auto sync failed.please check internet connection',
          );
          return;
        }
        await _fireStoreService.addMemberToSpace(member: mem);
      } catch (e) {}
    }

    // 4. Finally ITEMS
    final items = await _sqfLiteSetup.fetchNonSyncedItemQuery();
    for (var itemMap in items) {
      try {
        final im = ItemModel.fromMap(item: itemMap); //

        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'Auto sync failed.please check internet connection',
          );
          return;
        } //
        await _fireStoreService.insertItemToFirebase(
          im.userId ?? '',
          im.spaceId!,
          im,
        );
      } catch (e) {}
    }

    final expenses = await _sqfLiteSetup.fetchNonSyncedExpense();
    for (var expense in expenses) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'Auto sync failed.please check internet connection',
          );
          return;
        } //
        await _fireStoreService.saveExpense(expense: expense);
      } catch (e) {}
    }
  }
}

final firebaseStreamProvider = Provider((ref) {
  final inst = ref.read(fireStoreServiceProvider).instance;
  final sqf = ref.read(sqfLiteSetupProvider);
  final user = ref.read(currentUserProvider).value!;
  final fire = ref.read(fireStoreServiceProvider);
  return FirebaseStreams(inst, sqf, user, fire, ref);
}); //Provider

class FirebaseStreams {
  final FirebaseFirestore _fireStore;
  final FireStoreService _fireStoreService;
  final SqfLiteSetup _sqfLiteSetup;
  final Ref ref;
  final UserModel _userRepository;

  FirebaseStreams(
    this._fireStore,
    this._sqfLiteSetup,
    this._userRepository,
    this._fireStoreService,
    this.ref,
  );

  Future<void> syncAllData(String? usersId, SyncType type) async {
    print("🚀 Starting Manual Sync...");

    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null ||
        currentUser.id.isEmpty ||
        currentUser.userType == 'guest') {
      return;
    }

    final userId = _userRepository.id;

    try {
      // 1. Sync User Profile
      await _syncUsers(usersId ?? userId);

      // 2. Fetch Spaces List first
      final list = await _fireStoreService.fetchSpacesFromUser(userId);
      final localSpaces = await _sqfLiteSetup.fetchAllSpace(userId: userId);
      final idList = list.map((sp) => sp.id).toList();
      for (final space in localSpaces) {
        if (idList.contains(space['id'] ?? '')) continue;
        await _sqfLiteSetup.deleteSpace(spaceId: space['id'] ?? '');
      }
      if (idList.isNotEmpty) {
        // 3. Sync Spaces Data
        await _syncSpaces(idList);

        if (type == SyncType.auto) {
          await _syncItems(idList);
          await _syncExpenses(idList);
        } else {
          final currentSpace = ref.read(currentSpaceProvider).value;
          if (currentSpace == null) {
            SnackBarService.showMessage('No space selected');
            return;
          } else {
            await _syncItems([currentSpace.id]);
            await _syncExpenses([currentSpace.id]);
          }
        }
      }
    } catch (e) {}
  }

  Future<void> _syncItems(List<String> listSpace) async {
    for (String spaceId in listSpace) {
      try {
        final snapshot = await _fireStore
            .collection('spaces')
            .doc(spaceId)
            .collection('items')
            .get();

        final local = await _sqfLiteSetup.fetchItemsBySpace(spaceId);
        final listNew = snapshot.docs
            .map((item) => item.data()['id'] ?? '')
            .toSet();
        for (final item in local) {
          if (listNew.contains(item.id)) {
            continue;
          }
          await ref.read(itemControllerProvider).deleteItem(item: item);
        }
        for (var doc in snapshot.docs) {
          final data = doc.data();

          // Data Conversion
          final item = ItemModel.fromMap(item: data, isSynced: true);
          final local = await _sqfLiteSetup.fetchItemById(item.id);

          if (local != null && local.updatedAt == item.updatedAt) {
            continue;
          }

          await ref
              .read(itemControllerProvider)
              .insertItemFromFirebase(item: item, prev: local);
        }

        ref.read(apiImageProvider).startSmartSync();
      } catch (e) {}
    }
  }

  Future<void> _syncExpenses(List<String> listSpace) async {
    final controller = ref.read(expenseStateController.notifier);
    for (String spaceId in listSpace) {
      try {
        final local = await _sqfLiteSetup.fetchExpense(spaceId: spaceId);
        final remoteItems = await _fireStoreService.getExpenses(
          spaceId: spaceId,
        );
        final idList = remoteItems.map((expense) => expense.id).toList();
        for (final expense in local) {
          if (idList.contains(expense.id)) {
            continue;
          }
          await controller.deleteExpense(id: expense.id);
        }
        for (ExpenseModel exp in remoteItems) {
          await controller.saveExpense(expense: exp);
        }
      } catch (e) {}
    }
  }

  // --- SPACES SYNC LOGIC ---
  Future<void> _syncSpaces(List<String> listSpace) async {
    List<String> targetSpaces = listSpace;
    if (listSpace.length > 10) {
      targetSpaces = listSpace.sublist(0, 10);
    }

    try {
      final snapshot = await _fireStore
          .collection('spaces')
          .where('id', whereIn: targetSpaces)
          .get(); //

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final space = SpaceModel.fromMap(map: data, userId: data['user_id']);
        final localSpace = await _sqfLiteSetup.findSpaceBySpaceId(
          spaceId: space.id,
        );
        if (localSpace != null && localSpace.updatedAt == space.updatedAt) {
          print('space continued $localSpace');
          continue;
        }
        await _sqfLiteSetup.createSpace(space: space);
        List members = await _fireStoreService.fetchMembersFromSpace(
          spaceId: space.id,
        );

        for (MemberModel mem in members) {
          final newM = MemberModel(
            role: mem.role,
            name: mem.name,
            spaceID: mem.spaceID,
            id: mem.id,
            userId: mem.userId,
            photo: mem.photo,
          );
          await _sqfLiteSetup.addMemberToMembers(member: newM);
        }
      }
    } catch (e) {}
  }

  // --- USERS SYNC LOGIC ---
  Future<void> _syncUsers(String userId) async {
    try {
      final snapshot = await _fireStore
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final user = UserModel.fromMap(data);
        final localUser = await _sqfLiteSetup.getUserFromId(user.id);
        if (localUser != null && localUser.updatedAt == user.updatedAt) {
          continue;
        }
        await _sqfLiteSetup.insertUser(user);
        await _sqfLiteSetup.markUserAsSynced(userId);
      }
    } catch (e) {}
  }
}

enum SyncType { manual, auto }
