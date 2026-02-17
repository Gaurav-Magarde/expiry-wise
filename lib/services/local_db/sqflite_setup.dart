import 'dart:async';

import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final sqfLiteSetupProvider = Provider((ref) => SqfLiteSetup.instance);
final sqfLiteDbProvider = Provider((ref) => SqfLiteSetup.instance._db);

class SqfLiteSetup {
  static SqfLiteSetup instance = SqfLiteSetup._();
  SqfLiteSetup._(){
initDatabase();
}
  Database? _db;

/// ----------------------------------------------------[Database Creation]-----------------------------------


  Future<Database> get getDatabase async {
    if (_db != null) return _db!;
    return _db = await initDatabase();
  }

  Future<Database> initDatabase() async {
    //Get path of the database
    final database = await getDatabasesPath();

    // Join with the name to create overall path
    final path = join(database, 'expiry_wise.db');

    //Open database and perform operation on it
    return _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE users(id TEXT PRIMARY KEY,updated_at TEXT ,name TEXT,email TEXT,photo_url TEXT ,user_type TEXT,is_synced INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0 )',
        );
        await db.execute(
          'CREATE TABLE spaces('
          'id TEXT PRIMARY KEY,'
          'name TEXT,updated_at TEXT,'
          'user_id TEXT NOT NULL,is_synced INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0)',
        );
        await db.execute(
          'CREATE TABLE items('
          'id TEXT PRIMARY KEY,'
          'name TEXT,'
          'notify_config TEXT,'
          'expiry_date TEXT,updated_at TEXT,'
          'image TEXT ,image_network TEXT ,'
          'quantity INTEGER,finished INTEGER DEFAULT 0,price REAL,is_expense_linked INTEGER DEFAULT 0,'
          'note TEXT ,unit TEXT,'
          'user_id TEXT NOT NULL,space_id TEXT NOT NULL,'
          'category TEXT,added_date TEXT NOT NULL,is_synced INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0,'
          'FOREIGN KEY (user_id) REFERENCES users (id) ,'
          'FOREIGN KEY (space_id) REFERENCES spaces (id))',
        );
        await db.execute(
          'CREATE TABLE members(id TEXT PRIMARY KEY,name TEXT,user_id TEXT NOT NULL,role TEXT NOT NULL,email TEXT,space_id TEXT NOT NULL,photo TEXT ,is_synced INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0 )',
        );


        await db.execute(
          'CREATE TABLE expenses(id TEXT PRIMARY KEY,title TEXT,updated_at TEXT,category TEXT,note TEXT,amount double,payer_name TEXT,payer_id TEXT,expense_date TEXT,space_id TEXT NOT NULL,is_synced INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0)',
        );

        await db.execute(
          'CREATE TABLE quick_list(id TEXT PRIMARY KEY,title TEXT,updated_at TEXT,space_id TEXT NOT NULL,is_synced INTEGER NOT NULL DEFAULT 0,is_completed INTEGER NOT NULL DEFAULT 0,is_deleted INTEGER NOT NULL DEFAULT 0)',
        );
      },
    );
  }

  Future<void> deleteDataBase() async {
    final databasePath = await getDatabasesPath();
    if (_db != null && _db!.isOpen) {
      await _db!.close();
    }
    final path = join(databasePath, 'expiry_wise.db');
    if (await databaseExists(path)) {
      await deleteDatabase(path);
    }
    _db = null;
  }

  /// -----------------------------------------------[Users Section]------------------------------------------

  //
  // Future<void> insertUser(UserModel user) async {
  //   try {
  //     final db = await getDatabase;
  //     final map = user.toMap();
  //     db.insert(
  //       "users",
  //        map,
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   } catch (e) {
  //     throw Exception("DB ERROR");
  //   }
  // }

  // Future<UserModel?> getUserFromId(String currentUserId) async {
  //   try {
  //     final db = await getDatabase;
  //
  //
  //     final List<Map<String, dynamic>> map = await db.query(
  //       'users',
  //       where: 'id = ? And is_deleted = ?',
  //       whereArgs: [currentUserId,0],
  //       limit: 1,
  //     );
  //
  //     if (map.isEmpty) {
  //       return null;
  //     } else {
  //
  //       return UserModel.fromMap(map.first);
  //     }
  //   } catch (e) {
  //        throw Exception(e);
  //   }
  // }
  // Future<List<UserModel>> getUsersDeleted() async {
  //   try {
  //     final db = await getDatabase;
  //
  //     final List<Map<String, dynamic>> map = await db.query(
  //       'users',
  //       where: 'is_deleted = ?',
  //       whereArgs: [1]
  //     );
  //     final list = map.map((user){
  //       return UserModel.fromMap(user);
  //     }).toList();
  //     return list;
  //   } catch (e) {
  //     throw Exception("");
  //   }
  // }
  // Future<List<UserModel>> getUserNotSynced() async {
  //   try {
  //     final db = await getDatabase;
  //
  //     final List<Map<String, dynamic>> map = await db.query(
  //       'users',
  //       where: 'is_synced = ?',
  //       whereArgs: [0]
  //     );
  //     final list = map.map((user){
  //       return UserModel.fromMap(user);
  //     }).toList();
  //     return list;
  //   } catch (e) {
  //     throw Exception("");
  //   }
  // }

/// ---------------------------------------------------[Items Section]-------------------------------------

  // Future<void> insertItem(ItemModel item) async {
  //   try {
  //     final Map<String, dynamic> mapItem = item.toMap();
  //     if (          item.name.isEmpty ||
  //         item.category.isEmpty ||
  //         item.spaceId ==null ||
  //         item.userId == null ||
  //         item.spaceId!.isEmpty ||
  //         item.userId!.isEmpty) {
  //       return;
  //     }
  //     final db = await getDatabase;
  //     await db.insert('items', mapItem, conflictAlgorithm: ConflictAlgorithm.replace);
  //     refreshItems(spaceId: item.spaceId!);
  //   } catch (e) {
  //     return;
  //   }
  // }
  //

  // Future<void> insertItems(List<ItemModel> items) async {
  //   try {
  //       final db = await getDatabase;
  //       final spaceId = items.first.spaceId;
  //       for(ItemModel item in items) {
  //         if (
  //             item.name.isEmpty ||
  //             item.category.isEmpty ||
  //             item.spaceId ==null ||
  //             item.userId == null ||
  //             item.spaceId!.isEmpty ||
  //             item.userId!.isEmpty) {
  //           return;
  //         }
  //         final Map<String, dynamic> mapItem = item.toMap();
  //         await db.insert('items', mapItem, conflictAlgorithm: ConflictAlgorithm.replace);
  //
  //       }
  //
  //     refreshItems(spaceId: spaceId!);
  //   } catch (e) {
  //     return;
  //   }
  // }
  //
  // Future<void> refreshItems({required String? spaceId}) async {
  //   try{
  //     List<ItemModel> items = [];
  //     if(spaceId!=null && spaceId.isNotEmpty){
  //       final db = await getDatabase;
  //       final maps = await db.query(
  //         'items',
  //         where: "space_id = ?",
  //         whereArgs: [spaceId],
  //       );
  //
  //       items = maps
  //           .map((item) => ItemModel.fromMap(item: item))
  //           .toList();
  //     }
  //
  //     _itemController.sink.add(items);
  //   }catch(e){
  //     throw "exception in refresh ";
  //   }
  // }


  // Future<ItemModel?> fetchItemById(String id) async {
  //   final db = await getDatabase;
  //
  //   final List<Map<String, dynamic>> maps = await db.query('items',where: 'id=?',whereArgs: [id],limit: 1);
  //
  //   if (maps.isEmpty) {
  //
  //     return null;
  //   } else {
  //     final list = ItemModel.fromMap(item: maps.first);
  //     return list;
  //   }
  // }
  // Future<List<ItemModel>> fetchItemsBySpace(String spaceId) async {
  //   final db = await getDatabase;
  //
  //   final List<Map<String, dynamic>> maps = await db.query('items',where: 'space_id=?',whereArgs: [spaceId]);
  //
  //   if (maps.isEmpty) {
  //
  //     return [];
  //   } else {
  //     final list = maps.map((item)=>ItemModel.fromMap(item: item)).toList();
  //
  //     return list;
  //   }
  // }
  // Future<List<ItemModel>> fetchAllItems() async {
  //   final db = await getDatabase;
  //
  //   final List<Map<String, dynamic>> maps = await db.query('items');
  //
  //   if (maps.isEmpty) {
  //
  //     return [];
  //   } else {
  //     final list = maps.map((item)=>ItemModel.fromMap(item: item)).toList();
  //
  //     return list;
  //   }
  // }



  // Future<String?> updateItem(ItemModel item) async {
  //   try {
  //     print("now updating ${item.toMap()}");
  //     final Map<String, dynamic> mapItem = item.toMap();
  //     final db = await getDatabase;
  //     final prev = await db.query(
  //         'items',
  //         where: "id =?",
  //         whereArgs: [item.id]
  //     );
  //     await db.update('items',where: "id = ?",whereArgs: [item.id], mapItem);
  //     refreshItems(spaceId: item.spaceId!,);
  //     final string  = prev.first['image_network'] as String?;
  //     return string ;
  //   } catch (e) {
  //     return null;
  //   }
  // }


  // Future<List<Map<String, dynamic>>> fetchNonSyncedItemQuery() async {
  //   final db = await getDatabase;
  //   final map = await db.query(
  //     'items',
  //     where: "is_synced = ?",
  //     whereArgs: [0]
  //   );
  //   return map;
  // }

  // Future<bool> deleteItem({required String spaceId, required String itemId}) async {
  //   try{
  //     final db = await getDatabase;
  //     final affect = await db.update('items',whereArgs: [itemId],where: 'id = ?',{'is_deleted' : 0});
  //     markItemAsUnSynced(itemId);
  //     refreshItems(spaceId: spaceId,);
  //    return affect == 1;
  //   }catch(e){
  //     return false;
  //   }
  // }

  // Future<void> deleteAllSpaceItem({required String spaceId }) async {
  //   try{
  //     final db = await getDatabase;
  //     await db.update('items',whereArgs: [spaceId],where: 'space_id = ?',{'is_deleted' : 0});
  //     markItemAsUnSynced(spaceId);
  //    refreshItems(spaceId: spaceId,);
  //   }catch(e){
  //     throw " ";
  //   }
  // }

/// ---------------------------------------------------[Space Section]---------------------------------------
//
//
//   Future<void> createSpace({required SpaceModel space}) async {
//     final db = await _getDatabase;
//     final map = space.getMap();
//     await db.insert('spaces', map,conflictAlgorithm: ConflictAlgorithm.replace);
//   }

  // Future<List<Map<String, dynamic>>> fetchAllSpace({
  //   required String userId,
  // }) async {
  //   final db = await _getDatabase;
  //   final map = await db.query(
  //     "spaces",
  //   );
  //   return map;
  // }

//
//   Future<SpaceModel?> findFirstSpace({required String userId}) async {
//     final db = await _getDatabase;
// // 2. Query all rows (Equivalent to SELECT * FROM tableName)
//     final List<Map<String, dynamic>> result = await db.query('spaces');
//
//     // 3. Print the results
//     if (result.isEmpty) {
//       print("Table 'spaces'' is empty.");
//     } else {
//       print("--- Data in spaces' ---");
//       for (var row in result) {
//         print(row);
//       }
//       print("----------------------------");
//     }
//     final map = await db.query(
//       'spaces',
//       where: "user_id = ? AND is_deleted = ?",
//       whereArgs: [userId,0],
//       limit: 1,
//     );
//     if (map.isEmpty) return null;
//     final space = SpaceModel.fromMap(map: map.first,userId: userId);
//
//     return space;
//   }

  // Future<List<SpaceModel>> findNonSyncedSpace() async {
  //   final db = await _getDatabase;
  //
  //   final map = await db.query(
  //     'spaces',
  //     where: "is_synced = ?",
  //     whereArgs: [0]
  //   );
  //   final list = map.map((space)=>SpaceModel.fromMap(map: space,userId:space['user_id'] as String )).toList();
  //
  //   return list;
  // }
  //
  // Future<SpaceModel?> findSpace({
  //   required String userId,
  //   required String spaceId,
  //   int limit = 1,
  // }) async {
  //   final db = await _getDatabase;
  //
  //   final map = await db.query(
  //     'spaces',
  //     where: "user_id = ? AND id = ?",
  //     whereArgs: [userId, spaceId],
  //     limit: limit,
  //   );
  //   if (map.isEmpty) return null;
  //   final space = SpaceModel.fromMap(map: map.first,userId: userId);
  //
  //   return space;
  // }
  // Future<SpaceModel?> findSpaceBySpaceId({
  //
  //   required String spaceId,
  //   int limit = 1,
  // }) async {
  //   final db = await _getDatabase;
  //
  //   final map = await db.query(
  //     'spaces',
  //     where: " id = ?",
  //     whereArgs: [ spaceId],
  //     limit: limit,
  //   );
  //   if (map.isEmpty) return null;
  //   return SpaceModel.fromMap(map:  map.first ,userId: '');
  // }



  // Future<int> deleteSpace({required String spaceId}) async {
  //   final db = await _getDatabase;
  //
  //
  //   await deleteAllSpaceItem(spaceId: spaceId);
  //   await db.delete(
  //     'spaces',where: 'id = ?',whereArgs: [spaceId],
  //   );
  //   refreshItems(spaceId: spaceId);
  //   return await markSpaceAsUnSynced(spaceId);
  // }

/// -------------------------------------------[Member Section]-----------------------------------------

  //
  // Future<void> addMemberToMembers({required MemberModel member})async {
  //   try{
  //     final db = await getDatabase;
  //     Map<String ,dynamic> memberMap = member.toMap();
  //     db.insert('members', memberMap,conflictAlgorithm: ConflictAlgorithm.replace);
  //   }catch(e){
  //     throw " ";
  //   }
  // }

  // Future<SpaceCardModel> fetchMemberBySpace({required String spaceId}) async {
  //   final db = await getDatabase;
  //
  //   // final listMem = await db.rawQuery(
  //   //   'SELECT COUNT(*) FROM members WHERE space_id = ? ',
  //   //   [spaceId],
  //   // );
  //   final listItem = await db.rawQuery(
  //     'SELECT COUNT(*) FROM items WHERE space_id = ?AND is_deleted = ?',
  //     [spaceId,0],
  //   );
  //
  //
  //   final item = Sqflite.firstIntValue(listItem)??0;
  //   final ob =  SqfLiteSetup._();
  //   final mem = await .fetchMemberFromLocal(spaceId: spaceId);
  //   return SpaceCardModel(mem.length, item);
  // }

  // Future<List<MemberModel>> fetchMemberFromLocal({required String spaceId})async {
  //   try{
  //     final db = await getDatabase;
  //     final mem = await db.query('members', where: "space_id = ? AND is_deleted = ?",whereArgs: [spaceId,0]);
  //     final list = mem.map((member){
  //       return MemberModel.fromLocal(member);
  //     }).toList();
  //     return list;
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  // Future<MemberModel?> fetchSingleMemberFromLocal({required String spaceId,required String userId,})async {
  //   try{
  //     final db = await getDatabase;
  //     final mem = await db.query('members', where: "space_id = ? AND user_id = ?",whereArgs: [spaceId,userId]);
  //      for(final member in mem){
  //       return MemberModel.fromLocal(member);
  //     };
  //     return null;
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  //
  // Future<List<MemberModel>> fetchAllNonSyncedMember()async{
  //   try{
  //     final db = await getDatabase;
  //     final mem = await db.query('members', where: ' is_synced = ?',whereArgs: [0]);
  //     final list = mem.map((member){
  //       return MemberModel.fromLocal(member);
  //     }).toList();
  //     return list;
  //   }catch(e){
  //     throw " ";
  //   }
  // }

  //
  // Future<int> deleteMember({required String memberId}) async {
  //   try{
  //     final db = await getDatabase;
  //     final affected =  await db.delete('members',where: 'id = ?',whereArgs: [memberId] );
  //     await markMemberAsUnSynced(memberId);
  //     return affected;
  //   }catch(e){
  //     throw " ";
  //   }
  // }

  // Future<void> markUserAsSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('users',whereArgs: [id],where: 'id = ?',{'is_synced' : 1});
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  //
  // Future<void> markUserAsUnSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('users',whereArgs: [id],where: 'id = ?',{'is_synced' : 0});
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  //
  // Future<void> markSpaceAsSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('spaces',whereArgs: [id],where: 'id = ?',{'is_synced' : 1});
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  // Future<int> markSpaceAsUnSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     return await db.update('spaces',whereArgs: [id],where: 'id = ?',{'is_synced' : 0});
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  // Future<void> markMemberAsSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('members',whereArgs: [id],where: 'id = ?',{'is_synced' : 1});
  //   }catch(e){
  //     throw " ";
  //   }
  // }

  // Future<void> markItemAsSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('items',whereArgs: [id],where: 'id = ?',{'is_synced' : 1});
  //   }catch(e){
  //     throw " ";
  //   }
  // }


  // Future<void> markMemberAsUnSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('members',whereArgs: [id],where: 'id = ?',{'is_synced' : 0});
  //   }catch(e){
  //     throw " ";
  //   }
  // }

  // Future<void> markItemAsUnSynced(String id) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('items',whereArgs: [id],where: 'id = ?',{'is_synced' : 0});
  //   }catch(e){
  //     throw " ";
  //   }
  // }
  //
  // Future<void> updateUser(Map<String, dynamic> map,userId) async {
  //   try{
  //    final db = await getDatabase;
  //    db.update('users', where: 'id = ?',whereArgs: [userId],map);
  //   }catch(e){
  //     print("user not updated");
  //   }
  // }


  // Future<void> printDatabase()async{
  //   final db  = await getDatabase;
  //   final List<Map<String, dynamic>> result = await db.query('spaces');
  //
  //   // 3. Print the results
  //   if (result.isEmpty) {
  //     print("Table 'spaces'' is empty.");
  //   } else {
  //     print("--- Data in spaces' ---");
  //     for (var row in result) {
  //       print(row);
  //     }
  //     print("----------------------------");
  //   }
  //   final List<Map<String, dynamic>> result1 = await db.query('members');
  //
  //   // 3. Print the results
  //   if (result.isEmpty) {
  //     print("Table 'members'' is empty.");
  //   } else {
  //     print("--- Data in members' ---");
  //     for (var row in result1) {
  //       print(row);
  //     }
  //     print("----------------------------");
  //   }
  //
  //   final List<Map<String, dynamic>> result4 = await db.query('users');
  //
  //   // 3. Print the results
  //   if (result.isEmpty) {
  //     print("Table 'users' is empty.");
  //   } else {
  //     print("--- Data in users' ---");
  //     for (var row in result4) {
  //       print(row);
  //     }
  //     print("----------------------------");
  //   }
  //
  //   final List<Map<String, dynamic>> result2 = await db.query('items');
  //
  //   // 3. Print the results
  //   if (result.isEmpty) {
  //     print("Table 'items'' is empty.");
  //   } else {
  //     print("--- Data in items' ---");
  //     for (var row in result2) {
  //       print(row);
  //     }
  //     print("----------------------------");
  //   }
  // }

  // Future<void> updateMember({required MemberModel member, required Map<String, String> map}) async {
  //   try{
  //     final db = await getDatabase;
  //     db.update('members',whereArgs: [member.id],where: 'id = ?',map);
  //   }catch(e){
  //     throw " ";
  //   }
  // }


  Future<void> changeUserIdOnTransaction({required String oldId,required String email, required UserModel newUser}) async {
    try{
      final newId = newUser.id;
      final name = newUser.name;
      final photo = newUser.photoUrl;
      final db = await getDatabase;
      await db.transaction((txn) async {
        await txn.update('spaces', where: 'user_id = ? AND is_deleted = ?',whereArgs: [oldId,0],{'user_id':newId,'is_synced':0});
        await txn.update('items', where: 'user_id = ? AND is_deleted = ?',whereArgs: [oldId,0],{'user_id':newId,'is_synced':0});
        await txn.update('members', where: 'user_id = ? AND is_deleted = ?',whereArgs: [oldId,0],{'user_id':newId,'is_synced':0,'name' : name,'email':email,'photo':photo});
      });
    }catch(e){

    }
  }

  ///----------------------------[EXPENSE]------------------------------------------
  // Future<void> saveExpense({required ExpenseModel expense})async{
  //   final db = await getDatabase;
  //   await db.insert('expenses', expense.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  //   refreshExpense(spaceId: expense.spaceId);
  // }

  // Future<void> deleteExpense({required ExpenseModel expense})async{
  //   final db = await getDatabase;
  //   await db.delete('expenses', where: 'id = ?',whereArgs: [expense.id]);
  //   refreshExpense(spaceId: expense.spaceId);
  // }

  // Future<void> loadExpense({required String spaceId})async{
  //   refreshExpense(spaceId: spaceId);
  // }

  // Future<List<ExpenseModel>> fetchExpense({required String spaceId})async{
  //   final db = await getDatabase;
  //   final list = await db.query('expenses',whereArgs: [spaceId],where: 'space_id = ?');
  //   return list.map((expense)=>ExpenseModel.fromMap(map: expense)).toList();
  // }

  // Future<List<ExpenseModel>> fetchNonSyncedExpense()async{
  //   final db = await getDatabase;
  //   final list = await db.query('expenses',whereArgs: [0],where: 'is_synced = ?');
  //   return list.map((expense)=>ExpenseModel.fromMap(map: expense)).toList();
  // }

  // Future<void> refreshExpense({required String spaceId})async{
  //   final db = await getDatabase;
  //
  //   final list = await db.query('expenses',whereArgs: [spaceId],where: 'space_id = ?');
  //   final expenses = list.map((expense)=>ExpenseModel.fromMap(map: expense)).toList();
  //   _expensesStreamController.sink.add(expenses);
  // }
  //
  //
  // Future<void> saveQuickListItem({required QuickListModel item})async{
  //   final db = await getDatabase;
  //   await db.insert('quick_list', item.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  //   refreshQuickList(spaceId: item.spaceId);
  // }

  // Future<void> deleteQuickListItem({required String id,required String spaceId})async{
  //   final db = await getDatabase;
  //   await db.delete('quick_list', where: 'id = ?',whereArgs: [id]);
  //   refreshQuickList(spaceId: spaceId);
  // }

  // Future<void> loadQuickListItem({required String spaceId})async{
  //   refreshQuickList(spaceId: spaceId);
  // }
  //
  // Future<List<QuickListModel>> fetchQuickListItem({required String spaceId})async{
  //   final db = await getDatabase;
  //   final list = await db.query('quick_list',whereArgs: [spaceId],where: 'space_id = ?');
  //   return list.map((item)=>QuickListModel.fromMap(map: item)).toList();
  // }

  // Future<List<QuickListModel>> fetchNonSyncedQuickListItem()async{
  //   final db = await getDatabase;
  //   final list = await db.query('quick_list',whereArgs: [0],where: 'is_synced = ?');
  //   return list.map((item)=>QuickListModel.fromMap(map: item)).toList();
  // }

  // Future<void> refreshQuickList({required String spaceId})async{
  //   final db = await getDatabase;
  //
  //   final list = await db.query('quick_list',whereArgs: [spaceId],where: 'space_id = ?');
  //   final itemList = list.map((item)=>QuickListModel.fromMap(map: item)).toList();
  //   _quickListStreamController.sink.add(itemList);
  // }

}


