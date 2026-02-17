import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/utils/loaders/image_api.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_data_source.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/domain/user_repository_interface.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/domain/expense_repository_interface.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_remote_datasource_inteface.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/Member/data/datasource/member_remote_datasource_impl.dart';
import '../../features/Member/data/models/member_model.dart';
import '../../features/Space/data/datasource/space_remote_data_source.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/expenses/presentation/controllers/expense_controllers.dart';
import '../../features/inventory/data/datasource/inventory_local_datasource_interface.dart';
import '../Connectivity/internet_connectivity.dart';

final syncProvider = Provider((ref) {
  final sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  final ISpaceLocalDataSource spaceLocalData = ref.read(
    spaceLocalDataSourceProvider,
  );
  final IMemberLocalDataSource memberLocalData = ref.read(
    memberLocalDataSourceProvider,
  );
  final IUserLocalDataSource userLocalDataSource = ref.read(
    userLocalDataSourceProvider,
  );
  final IInventoryRemoteDataSource remoteInventoryDataSource = ref.read(
    inventoryRemoteDataSourceProvider,
  );
  final IExpenseRepository expenseRepository = ref.read(
    expenseRepositoryProvider,
  );
  final IInventoryLocalDataSource localInventoryDataSource = ref.read(
    inventoryLocalDataSourceProvider,
  );
  final memberRemoteDataSource = ref.watch(memberRemoteDataSourceProvider);
  final remoteDataBase = ref.watch(spaceRemoteDataSourceProvider);
  final userRepository = ref.watch(userRepoProvider);

  return LocalFirebaseSyncing(
    expenseRepository: expenseRepository,
    localInventoryDataSource: localInventoryDataSource,
    sqfLiteSetup: sqfLiteSetup,
    ref: ref,
    localSpaceDataSource: spaceLocalData,
    remoteDataSource: remoteDataBase,
    localMemberDataSource: memberLocalData,
    remoteMemberDataSource: memberRemoteDataSource,
    remoteInventoryDataSource: remoteInventoryDataSource,
    userLocalDataSource: userLocalDataSource, userRepository: userRepository,
  );
});

class LocalFirebaseSyncing {
  final Ref ref;
  final SqfLiteSetup sqfLiteSetup;
  final IUserLocalDataSource userLocalDataSource;
  final IExpenseRepository expenseRepository;
  final ISpaceLocalDataSource localSpaceDataSource;
  final IMemberLocalDataSource localMemberDataSource;
  final IMemberRemoteDataSource remoteMemberDataSource;
  final IInventoryRemoteDataSource remoteInventoryDataSource;
  final IInventoryLocalDataSource localInventoryDataSource;
  final ISpaceRemoteDataSource remoteDataSource;
  final IUserRepository userRepository;
  LocalFirebaseSyncing({
    required this.localInventoryDataSource,
    required this.expenseRepository,
    required this.remoteMemberDataSource,
    required this.userLocalDataSource,
    required this.remoteInventoryDataSource,
    required this.sqfLiteSetup,
    required this.remoteDataSource,
    required this.ref,
    required this.localSpaceDataSource,
    required this.localMemberDataSource,
    required this.userRepository,
  });

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
    final users = await userLocalDataSource.getUserNotSynced();
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
        await userRepository.saveUserToRemote(user: user);
        await userRepository.markUserAsSynced(user.id);
      } catch (e) {}
    }

    final spaces = await localSpaceDataSource.findNonSyncedSpace();
    for (var space in spaces) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'sync failed.please check internet connection',
          );
          return;
        }
        await remoteDataSource.insertSpaceTOFirebase(space.userId, space);
        // SUCCESS: Local DB update
      } catch (e) {}
    }

    // 3.
    final members = await localMemberDataSource.fetchAllNonSyncedMember();
    for (var mem in members) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'Auto sync failed.please check internet connection',
          );
          return;
        }
        await remoteMemberDataSource.addMemberToSpace(member: mem);
      } catch (e) {}
    }

    // 4. Finally ITEMS
    final items = await localInventoryDataSource.fetchNonSyncedItemQuery();
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
        await remoteInventoryDataSource.insertItemToFirebase(
          im.userId ?? '',
          im.spaceId!,
          im,
        );
      } catch (e) {}
    }

    final expenses = await expenseRepository.fetchNonSyncedExpense();
    for (var expense in expenses) {
      try {
        final isInternet = ref.read(isInternetConnectedProvider);
        if (!isInternet) {
          SnackBarService.showToast(
            'Auto sync failed.please check internet connection',
          );
          return;
        } //
        await expenseRepository.saveExpenseRemote(expense: expense);
      } catch (e) {}
    }
  }
}

final firebaseStreamProvider = Provider((ref) {
  final sqf = ref.read(sqfLiteSetupProvider);
  final user = ref.read(currentUserProvider).value!;
  final memberRemoteDataSource = ref.watch(memberRemoteDataSourceProvider);
  final IExpenseRepository expenseRepository = ref.read(
    expenseRepositoryProvider,
  );
  final ISpaceLocalDataSource spaceLocalData = ref.read(
    spaceLocalDataSourceProvider,
  );
  final IUserLocalDataSource userLocalDataSource = ref.read(
    userLocalDataSourceProvider,
  );
  final IInventoryLocalDataSource inventoryLocalDataSource = ref.read(
    inventoryLocalDataSourceProvider,
  );
  final IMemberLocalDataSource memberLocalData = ref.read(
    memberLocalDataSourceProvider,
  );
  final IUserRemoteDataSource userRemoteDataSource = ref.read(
    userRemoteDataSourceProvider,
  );
  final IUserRepository userRepository = ref.read(
    userRepoProvider,
  );
  return FirebaseStreams(
    expenseRepository: expenseRepository,
    userLocalDataSource: userLocalDataSource,
    sqfLiteSetup: sqf,
    user: user,
    ref: ref,
    spaceLocalDataSource: spaceLocalData,
    memberLocalDataSource: memberLocalData,
    remoteMemberDataSource: memberRemoteDataSource,
    inventoryLocalDataSource: inventoryLocalDataSource,
    userRemoteDataSource: userRemoteDataSource, fireStore: FirebaseFirestore.instance, userRepository: userRepository,
  );
}); //Provider

class FirebaseStreams {
  final IMemberRemoteDataSource remoteMemberDataSource;
  final IExpenseRepository expenseRepository;
  final FirebaseFirestore fireStore;
  final SqfLiteSetup sqfLiteSetup;
  final ISpaceLocalDataSource spaceLocalDataSource;
  final IUserLocalDataSource userLocalDataSource;
  final IUserRemoteDataSource userRemoteDataSource;
  final IMemberLocalDataSource memberLocalDataSource;
  final IInventoryLocalDataSource inventoryLocalDataSource;
  final Ref ref;
  final UserModel user;
  final IUserRepository userRepository;

  FirebaseStreams({
    required this.fireStore,
    required this.expenseRepository,
    required this.sqfLiteSetup,
    required this.inventoryLocalDataSource,
    required this.userLocalDataSource,
    required this.userRemoteDataSource,
    required this.user,
    required this.userRepository,
    required this.ref,
    required this.spaceLocalDataSource,
    required this.memberLocalDataSource,
    required this.remoteMemberDataSource,
  });

  Future<void> syncAllData(String? usersId, SyncType type) async {
    final currentUser = await ref.read(currentUserProvider.future);
    if (currentUser == null ||
        currentUser.id.isEmpty ||
        currentUser.userType == 'guest') {
      return;
    }

    final userId = user.id;

    try {
      // 1. Sync User Profile
      await _syncUsers(usersId ?? userId);

      // 2. Fetch Spaces List first
      ///TODO:PUT the spaces logic
      List<SpaceModel> list = [];
      final localSpaces = await spaceLocalDataSource.fetchAllSpace(
        userId: userId,
      );
      final idList = list.map((sp) => sp.id).toList();
      for (final space in localSpaces) {
        if (idList.contains(space['id'] ?? '')) continue;
        await spaceLocalDataSource.deleteSpace(spaceId: space['id'] ?? '');
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
        final snapshot = await fireStore
            .collection('spaces')
            .doc(spaceId)
            .collection('items')
            .get();

        final local = await inventoryLocalDataSource.fetchItemsBySpace(spaceId);
        final listNew = snapshot.docs
            .map((item) => item.data()['id'] ?? '')
            .toSet();
        for (final item in local) {
          if (listNew.contains(item.id)) {
            continue;
          }
          await ref
              .read(itemControllerProvider.notifier)
              .deleteItem(item: item);
        }
        for (var doc in snapshot.docs) {
          final data = doc.data();

          // Data Conversion
          final item = ItemModel.fromMap(item: data, isSynced: true);
          final local = await inventoryLocalDataSource.fetchItemById(item.id);

          if (local != null && local.updatedAt == item.updatedAt) {
            continue;
          }

          await ref
              .read(itemControllerProvider.notifier)
              .insertItemByItemModel(item: item, prev: local);
        }

        ref.read(apiImageProvider).startSmartSync();
      } catch (e) {}
    }
  }

  Future<void> _syncExpenses(List<String> listSpace) async {
    final controller = ref.read(expenseControllerProvider.notifier);
    for (String spaceId in listSpace) {
      try {
        final local = await expenseRepository.fetchExpenseLocal(
          spaceId: spaceId,
        );
        final remoteItems = await expenseRepository.getExpensesRemote(
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
      final snapshot = await fireStore
          .collection('spaces')
          .where('id', whereIn: targetSpaces)
          .get(); //

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final space = SpaceModel.fromMap(map: data, userId: data['user_id']);
        final localSpace = await spaceLocalDataSource.findSpaceBySpaceId(
          spaceId: space.id,
        );
        if (localSpace != null && localSpace.updatedAt == space.updatedAt) {
          print('space continued $localSpace');
          continue;
        }
        await spaceLocalDataSource.createSpace(space: space);
        List members = await remoteMemberDataSource.fetchMembersFromSpace(
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
          await memberLocalDataSource.addMemberToMembers(member: newM);
        }
      }
    } catch (e) {}
  }

  // --- USERS SYNC LOGIC ---
  Future<void> _syncUsers(String userId) async {
    try {
      final snapshot = await fireStore
          .collection('users')
          .where('id', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final user = UserModel.fromMap(data);
        final localUser = await userLocalDataSource.getUserFromId(user.id);
        if (localUser != null && localUser.updatedAt == user.updatedAt) {
          continue;
        }
        await userLocalDataSource.insertUser(user);
        await userRepository.markUserAsSynced(userId);
      }
    } catch (e) {}
  }
}

enum SyncType { manual, auto }
