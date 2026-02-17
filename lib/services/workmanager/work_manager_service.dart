import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/core/network/network_info_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/datasource/member_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/remote_firebase_datasource.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_local_datasource_implementation.dart';
import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/User/data/repository/user_repository_impl.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_local_dataSsource_impl.dart';
import 'package:expiry_wise_app/features/expenses/data/datasources/expense_remote_datasource_impl.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_local_datasource_impl.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_remote_datasouce_impl.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/services/api_services/food_api_service.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart'; // REQUIRED for Background

import '../../core/constants/constants.dart';
import '../../features/inventory/data/datasource/inventory_remote_datasource_impl.dart';

const String taskExpiryCheck = 'expiry_check';
const String taskSyncCheck = 'sync_data';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName,  inputData) async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      print('Firebase Init Error (Might be already initialized): $e');
    }

    switch (taskName) {
      case taskExpiryCheck:
        await _initializePlugin();
        await _checkDatabaseAndNotify();
        break;
      case taskSyncCheck:
        await _syncData();
        break;
    }
    return Future.value(true);
  });
}

Future<void> _initializePlugin() async {
    const AndroidInitializationSettings androidSetting =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidSetting,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> _checkDatabaseAndNotify() async {
  try {
    Database db = await SqfLiteSetup.instance.getDatabase;
    final allItemsMap = await db.query('items', where: 'is_deleted = 0');
    List<ItemModel> allItems = allItemsMap
        .map((item) => ItemModel.fromMap(item: item))
        .toList();

    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    List<String> lines = [];
    int todayCount = 0;
    int tomorrowCount = 0;
    int soonCount = 0;
    bool shouldNotify = false;

    for (final item in allItems) {
      final expiry = item.expiryDate;
      if (expiry == null) continue;
      final parsedDate = DateTime.tryParse(expiry);
      final parsedDate2 = DateFormat(DateFormatPattern.dateformatPattern).tryParseUtc(expiry);
      if (parsedDate2 == null) continue;
      final expiryDateOnly = DateTime(
        parsedDate2.year,
        parsedDate2.month,
        parsedDate2.day,
      );
      if (expiryDateOnly.isBefore(todayDate)) continue;
      final diff = expiryDateOnly.difference(todayDate).inDays;
      if (item.notifyConfig.contains(diff)) {
        shouldNotify = true;
        if (diff == 0) {
          todayCount++;
        } else if (diff == 1) {
          tomorrowCount++;
        } else {
          soonCount++;
        }
      }
    }

    if (!shouldNotify) return;

    if (todayCount > 0) lines.add('⚠️ $todayCount Item(s) Expiring Today');
    if (tomorrowCount > 0) {
      lines.add('📅 $tomorrowCount Item(s) Expiring Tomorrow');
    }
    if (soonCount > 0) lines.add('⏳ $soonCount Item(s) Expiring Soon');

    String summaryText = lines.join(' • ');

    final InboxStyleInformation inboxStyleInformation = InboxStyleInformation(
      lines,
      contentTitle: 'Expiry Alert',
      summaryText: 'Action Required',
    );

    await flutterLocalNotificationsPlugin.show(
      888,
      'Expiry Update',
      summaryText,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'expiry_channel_ALARM_V1',
          'Expiry Notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF673AB7),
          styleInformation: inboxStyleInformation,
          playSound: true,
        ),
      ),
    );
  } catch (e) {}
}

Future<void> _syncData() async {
  final networkInfo = NetworkInfoImpl();

  // 1. Internet Check
  // if (!(await networkInfo.connection)) {
  //   print("No Internet for Background Sync");
  //   return;
  // }

  final sqfLiteSetup = SqfLiteSetup.instance;
  final firebaseInstance = FirebaseFirestore.instance;

  if (kDebugMode) {
    print('🔄 Starting Sync...');
  }

  // 2. User Sync (Critical Step)
  UserModel? user = await performUserSync(
      firebaseInstance: firebaseInstance,
      sqfLiteSetup: sqfLiteSetup,
      networkInfo: networkInfo);

  if (user == null) {
    print("❌ No User Found, Aborting Sync");
    return;
  }

  // 3. Dependent Syncs (Wait for them)
  await performSpaceSync(
      firebaseInstance: firebaseInstance,
      sqfLiteSetup: sqfLiteSetup,
      networkInfo: networkInfo,
      user: user);

  await performMemberSync(
      firebaseInstance: firebaseInstance,
      sqfLiteSetup: sqfLiteSetup,
      networkInfo: networkInfo);

  // 4. Parallel Independent Syncs (Faster) 🚀
  await Future.wait([
    performInventory(
        firebaseInstance: firebaseInstance,
        sqfLiteSetup: sqfLiteSetup,
        networkInfo: networkInfo),
    performExpenseSync(
        firebaseInstance: firebaseInstance,
        sqfLiteSetup: sqfLiteSetup,
        networkInfo: networkInfo),
    performQuickListSync(
        firebaseInstance: firebaseInstance,
        sqfLiteSetup: sqfLiteSetup,
        networkInfo: networkInfo),
  ]);

  print("✅ Background Sync Completed");
}

Future<void> performInventory({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
}) async {
  final remoteInventoryDataSource = InventoryFirebaseDataSource();
  final localInventoryDataSource = InventorySqfLiteDataSource(
    sqfLiteSetup: sqfLiteSetup,
  );
  final apiService = FoodApiService();
  final inventoryRepo = ItemRepositoryImpl(
    apiService: apiService,
    networkInfo: networkInfo,
    remoteInventoryDataSource: remoteInventoryDataSource,
    localInventoryDataSource: localInventoryDataSource,
  );

  try {
    final nonSyncedItem = await inventoryRepo.getNonSyncedItems();
    for (final item in nonSyncedItem) {
      try {
        await inventoryRepo.addItemRemote(item: item);
      } catch (e) {
        print("Item Sync Fail: $e");
      }
    }

    final deleteItems = await inventoryRepo.getNonSyncedDeletedItems();
    for (final item in deleteItems) {
      try {
        await inventoryRepo.removeItemRemote(
            id: item.id, spaceId: item.spaceId);
      } catch (e) {
        print("Item Delete Fail: $e");
      }
    }
  } catch (e) {
    print("Inventory Repo Error: $e");
  }
}

Future<void> performMemberSync({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
}) async {
  final memberRemoteDataSource = MemberRemoteDataSourceImpl();
  final memberLocalDataSource = MemberLocalDataSource(sqfLite: sqfLiteSetup);
  final memberRepo = MemberRepositoryImpl(
    memberRemoteDataSource: memberRemoteDataSource,
    networkInfo: networkInfo,
    memberLocalDataSource: memberLocalDataSource,
  );

  try {
    final nonSyncedMember = await memberRepo.getNonSyncedMember();
    for (final member in nonSyncedMember) {
      try {
        await memberRepo.addMemberToSpaceRemote(member: member);
      } catch (e) {}
    }

    final deletedMember = await memberRepo.getNonSyncedDeletedMember();
    for (final member in deletedMember) {
      try {
        await memberRepo.removeMemberFromSpaceRemote(member: member);
      } catch (e) {}
    }
  } catch (e) {}
}

Future<void> performSpaceSync({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
  required UserModel user,
}) async {
  final spaceRemoteDataSource = SpaceFirebaseDataSource();
  final spaceLocalDataSource = SpaceLocalDataSourceImpl(
    sqfLiteSetup: sqfLiteSetup,
  );
  final prefs = PrefsService.instance;
  final spaceRepo = SpaceRepository(
    localDataSource: spaceLocalDataSource,
    networkConnection: networkInfo,
    remoteDataSource: spaceRemoteDataSource,
    prefs: prefs,
  );

  try {
    final nonSyncedSpaces = await spaceRepo.getNonSyncedSpaces();
    for (final space in nonSyncedSpaces) {
      try {
        await spaceRepo.createSpaceRemote(user: user, space: space);
      } catch (e) {}
    }

    final nonSyncedDeletedSpaces = await spaceRepo.getNonSyncedDeletedSpaces();
    for (final space in nonSyncedDeletedSpaces) {
      try {
        await spaceRepo.deleteRemoteSpace(spaceId: space.id);
      } catch (e) {}
    }
  } catch (e) {}
}

Future<void> performQuickListSync({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
}) async {
  final quickListRemoteDataSource = QuickListRemoteDatasourceImpl(
    instance: firebaseInstance,
  );
  final quickListLocalDataSource = QuickListLocalDataSourceImpl(
    sqfLiteSetup: sqfLiteSetup,
  );
  final quickListRepo = QuickListRepositoryImpl(
    networkInfo: networkInfo,
    quickListRemoteDataSource: quickListRemoteDataSource,
    quickListLocalDataSource: quickListLocalDataSource,
  );

  try {
    final nonSyncedList = await quickListRepo.getNonSyncedQuickList();
    for (final item in nonSyncedList) {
      try {
        await quickListRepo.saveToQuickList(item: item);
      } catch (e) {}
    }

    final nonSyncedDeleted = await quickListRepo.getNonSyncedDeletedQuickList();
    for (final item in nonSyncedDeleted) {
      try {
        await quickListRepo.removeFromQuickList(
            id: item.id, spaceId: item.spaceId);
      } catch (e) {}
    }
  } catch (e) {}
}

Future<void> performExpenseSync({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
}) async {
  final expenseRemoteDataSource = ExpenseRemoteDataSourceImpl(
    instance: firebaseInstance,
  );
  final expenseLocalDatasource = ExpenseLocalDataSourceImpl(
    sqfLiteSetup: sqfLiteSetup,
  );
  final expenseRepo = ExpenseRepository(
    expenseRemoteDataSource: expenseRemoteDataSource,
    expenseLocalDatasource: expenseLocalDatasource,
  );

  try {
    final nonSyncedExpenses = await expenseRepo.fetchNonSyncedExpense();
    for (final expense in nonSyncedExpenses) {
      try {
        await expenseRepo.saveExpenseRemote(expense: expense);
      } catch (e) {}
    }

    final nonSyncedDeletedExpenses = await expenseRepo.fetchNonSyncedDeletedExpense();
    for (final expense in nonSyncedDeletedExpenses) {
      try {
        await expenseRepo.deleteExpenseRemote(expense: expense);
      } catch (e) {}
    }
  } catch (e) {}
}

Future<UserModel?> performUserSync({
  required FirebaseFirestore firebaseInstance,
  required SqfLiteSetup sqfLiteSetup,
  required NetworkInfoImpl networkInfo,
}) async {
  final userRemoteDataSource = UserRemoteDataSourceImpl(
    instance: firebaseInstance,
  );
  final userLocalDataSource = UserLocalDataSourceImpl(
    sqfLiteSetup: sqfLiteSetup,
  );
  final userRepo = UserRepositoryImpl(
    userRemoteDataSource: userRemoteDataSource,
    networkConnection: networkInfo,
    userLocalDataSource: userLocalDataSource,
  );

  try {
    final nonSyncedUser = await userRepo.fetchNonSyncedUsers();
    for (final user in nonSyncedUser) {
      await userRepo.saveUserToRemote(user: user);
      return user;
    }

    final nonSyncedDeletedUser = await userRepo.fetchNonSyncedDeletedUsers();
    for (final user in nonSyncedDeletedUser) {
      await userRepo.deleteUserFromRemote(userId: user.id);
    }
  } catch (e) {
    print('User Sync Error: $e');
  }

  final prefs = PrefsService.instance;
  final userId = await prefs.getCurrentUserId();

  if (userId == null) return null;
  final user = await userRepo.getUserFromIdLocal(userId: userId);
  return user;
}