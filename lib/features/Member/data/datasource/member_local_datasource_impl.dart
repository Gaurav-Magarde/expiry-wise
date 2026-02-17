import 'package:expiry_wise_app/features/Member/data/datasource/member_local_datasource_interface.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../../../Space/data/model/space_card_model.dart';
import '../models/member_model.dart';

final memberLocalDataSourceProvider = Provider<IMemberLocalDataSource>((ref) {
  final sqf = ref.watch(sqfLiteSetupProvider);

  return MemberLocalDataSource(sqfLite: sqf);
});

class MemberLocalDataSource implements IMemberLocalDataSource {
  static const String memberTable = 'members';
  static const String memberIdColumn = 'id';
  static const String spaceIdColumn = 'space_id';
  static const String userIdColumn = 'user_id';
  static const String isDeletedColumn = 'is_deleted';
  static const String updatedAtColumn = 'updated_at';
  static const String isSyncedColumn = 'is_synced';
  final SqfLiteSetup sqfLite;
  MemberLocalDataSource({required this.sqfLite});
  @override
  Future<void> addMemberToMembers({required MemberModel member}) async {
    try {
      final db = await sqfLite.getDatabase;
      Map<String, dynamic> memberMap = member.toMap();
      await db.insert(
        memberTable,
        memberMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<SpaceCardModel> fetchMemberBySpace({required String spaceId}) async {
    final db = await sqfLite.getDatabase;

    final listItem = await db.rawQuery(
      'SELECT COUNT(*) FROM items WHERE $spaceIdColumn = ?AND $isDeletedColumn = ?',
      [spaceId, 0],
    );

    final item = Sqflite.firstIntValue(listItem) ?? 0;
    final mem = await fetchMemberFromLocal(spaceId: spaceId);
    return SpaceCardModel(mem.length, item);
  }

  @override
  Future<List<MemberModel>> fetchMemberFromLocal({
    required String spaceId,
  }) async {
    try {
      final db = await sqfLite.getDatabase;
      final mem = await db.query(
        memberTable,
        where: '$spaceIdColumn = ? AND $isDeletedColumn = ?',
        whereArgs: [spaceId, 0],
      );
      final list = mem.map((member) {
        return MemberModel.fromLocal(member);
      }).toList();
      return list;
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<MemberModel?> fetchSingleMemberFromLocal({
    required String spaceId,
    required String userId,
  }) async {
    try {
      final db = await sqfLite.getDatabase;
      final mem = await db.query(
        memberTable,
        where:
            '$spaceIdColumn = ? AND $userIdColumn = ? AND $isDeletedColumn = ?',
        whereArgs: [spaceId, userId, 0],
      );
      for (final member in mem) {
        return MemberModel.fromLocal(member);
      }
      ;
      return null;
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<List<MemberModel>> fetchAllNonSyncedMember() async {
    try {
      final db = await sqfLite.getDatabase;
      final mem = await db.query(
        memberTable,
        where: ' $isSyncedColumn = ? AND $isDeletedColumn = 0',
        whereArgs: [0],
      );
      final list = mem.map((member) {
        return MemberModel.fromLocal(member);
      }).toList();
      return list;
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<List<MemberModel>> fetchAllNonSyncedDeletedMember() async {
    try {
      final db = await sqfLite.getDatabase;
      final mem = await db.query(
        memberTable,
        where: ' $isSyncedColumn = ? AND $isDeletedColumn = 1',
        whereArgs: [0],
      );
      final list = mem.map((member) {
        return MemberModel.fromLocal(member);
      }).toList();
      return list;
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<int> deleteMember({required String memberId}) async {
    try {
      final db = await sqfLite.getDatabase;
      final affected = await db.update(
        memberTable,
        where: '$memberIdColumn = ?',
        whereArgs: [memberId],
        {isDeletedColumn: 1},
      );
      await markMemberAsUnSynced(memberId);
      return affected;
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<void> markMemberAsSynced(String id) async {
    try {
      final db = await sqfLite.getDatabase;
      await db.update(
        memberTable,
        whereArgs: [id],
        where: '$memberIdColumn = ?',
        {isSyncedColumn: 1},
      );
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<void> markMemberAsUnSynced(String id) async {
    try {
      final db = await sqfLite.getDatabase;
      await db.update(
        memberTable,
        whereArgs: [id],
        where: '$memberIdColumn = ?',
        {isSyncedColumn: 0},
      );
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<void> updateMember({required MemberModel member}) async {
    try {
      final db = await sqfLite.getDatabase;
      await db.update(
        memberTable,
        whereArgs: [member.id],
        where: '$memberIdColumn = ?',
        member.toMap(),
      );
      await markMemberAsUnSynced(member.id);
    } catch (e) {
      throw ' ';
    }
  }

  @override
  Future<void> deleteAllMember({required String spaceId}) async {
    final db = await sqfLite.getDatabase;
    final affected = await db.update(
      memberTable,
      where: '$spaceIdColumn = ?',
      whereArgs: [spaceId],
      {isDeletedColumn: 1},
    );
    await markAllMemberAsUnSynced(spaceId);
    // return affected;
  }

  Future<void> markAllMemberAsUnSynced(String spaceId) async {
    final db = await sqfLite.getDatabase;
    await db.update(
      memberTable,
      whereArgs: [spaceId],
      where: '$spaceIdColumn = ?',
      {isSyncedColumn: 0},
    );
  }

  @override
  Future<void> addMembersLocal({required List<MemberModel> members,required Batch batch,}) async {
    for (final member in members) {
      batch.insert(
        memberTable,
        member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> addMembersToBatch({
    required List<MemberModel> members,
    required Batch batch,
  }) async {
    for (final member in members) {
      batch.insert(
        memberTable,
        member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  void deleteMembersToBatch({required Batch batch, required String spaceId}) {
    batch.update(
      memberTable,
      whereArgs: [spaceId],
      where: '$spaceIdColumn = ?',
      {isDeletedColumn: 1},
    );
  }

  @override
  Future<int> fetchMemberCount({required String spaceId}) async {
    final db = await sqfLite.getDatabase;
    final result = await db.rawQuery('Select Count(*) From $memberTable Where $spaceIdColumn = ? AND $isDeletedColumn = 0',[spaceId]);
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }
}
