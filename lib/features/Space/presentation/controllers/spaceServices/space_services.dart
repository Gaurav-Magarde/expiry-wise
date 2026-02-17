import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Member/data/repository/member_repository.dart';
import 'package:expiry_wise_app/features/Member/domain/member_repository_interface.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_card_model.dart';
import 'package:expiry_wise_app/features/Space/domain/space_repository_interface.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/domain/expense_repository_interface.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/domain/inventory_repository.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/domain/quick_list_repo_interface.dart';
import 'package:expiry_wise_app/services/local_db/local_transaction_manager.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/remote_db/remote_transaction_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../Member/data/models/member_model.dart';
import '../../../../User/data/models/user_model.dart';
import '../../../../User/domain/user_repository_interface.dart';
import '../../../../User/presentation/controllers/user_controller.dart';
import '../../../../expenses/data/models/expense_model.dart';
import '../../../../quick_list/data/models/quicklist_model.dart';
import '../../../data/model/space_model.dart';
import '../../../data/repository/space_repository.dart';

final spaceUseCaseProvider = Provider((ref) {
  final spaceRepo = ref.read(spaceRepoProvider);
  final memberRepo = ref.read(memberRepoProvider);
  final userRepo = ref.read(userRepoProvider);
  final quickListRepo = ref.read(quickListRepoProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);

  final prefs = ref.read(prefsServiceProvider);
  final localTransactionManager = ref.read(providerLocalTransactionManager);
  final remoteTransactionManager = ref.read(providerRemoteTransactionManager);
  final itemRepo = ref.read(inventoryRepoProvider);
  return SpaceUseCases(
    expenseRepository: expenseRepo,
    quickListRepo: quickListRepo,
    localTransactionManager: localTransactionManager,
    remoteTransactionManager: remoteTransactionManager,
    itemRepository: itemRepo,
    prefs: prefs,
    spaceRepo: spaceRepo,
    memberRepo: memberRepo,
    userRepo: userRepo,
  );
});

class SpaceUseCases {
  final ISpaceRepository spaceRepo;
  final LocalTransactionManager localTransactionManager;
  final RemoteTransactionManager remoteTransactionManager;
  final QuickListRepoInterface quickListRepo;
  final IExpenseRepository expenseRepository;
  final IMemberRepository memberRepo;
  final IUserRepository userRepo;
  final PrefsService prefs;
  final InventoryRepository itemRepository;
  SpaceUseCases({
    required this.itemRepository,
    required this.expenseRepository,
    required this.quickListRepo,
    required this.localTransactionManager,
    required this.remoteTransactionManager,
    required this.userRepo,
    required this.spaceRepo,
    required this.prefs,
    required this.memberRepo,
  });

  Future<SpaceModel> addNewSpaceUseCase({
    required String? name,
    required UserModel? user,
  }) async {
    if (name != null && name.trim().isEmpty) {
      throw Exception('Enter space name');
    }
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found!.please try again later');
    }

    final id = const Uuid().v4();
    final mId = const Uuid().v4();

    final space = SpaceModel(
      userId: user.id,
      name: name ?? 'My Space',
      id: id,
      updatedAt: DateTime.now().toIso8601String(),
    );
    final newSpace = await spaceRepo.createSpace(space: space, user: user);

    final member = MemberModel(
      photo: user.photoUrl,
      name: user.name,
      spaceID: space.id,
      id: mId,
      userId: user.id,
      role: MemberRole.admin.name,
    );
    await memberRepo.addMemberLocal(member: member, user: user);
    if(user.userType!='guest'){
      await userRepo.addSpaceToUserRemote(spaceId: space.id, user: user);
      await memberRepo.addMemberToSpaceRemote(member: member);
    }
    await prefs.changeCurrentSpace(space.id);
    if (newSpace == null) {
      throw Exception('space created failed');
    }

    return space;
  }

  Future<void> deleteSpaceUseCase({
    required String spaceId,
    required UserModel? user,
  }) async {
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
    }
    MemberModel? member = await memberRepo.getSpaceMemberFromLocal(userId:user.id,spaceId: spaceId);
    if(member==null || member.role == MemberRole.member.name){
      throw Exception('Space deletion failed');
    }
    await localTransactionManager.deleteDataAtomic(spaceId: spaceId);
    await remoteTransactionManager.deleteSpaceDataAtomic(spaceId: spaceId, userId: user.id);
  }

  Future<void> renameSpaceUseCase({
    required SpaceModel space,
    required UserModel? user,
    required String newName
  }) async {
    if (user == null || user.id.isEmpty) {
      throw Exception('user not fount');
    }
    if (newName.isEmpty) {
      throw Exception('invalid space name');
    }
    MemberModel? member = await memberRepo.getSpaceMemberFromLocal(userId:user.id,spaceId: space.id);
    if(member==null ){
      throw Exception('Member not found');
    }
    if( member.role == MemberRole.member.name){
      throw Exception('Member cannot edit space');
    }
    await spaceRepo.updateSpace(user: user, space: space);

  }

  Future<void> joinSpaceUseCase({
    required String spaceId,
    required UserModel? user,
  }) async {
    try{
      if (user == null || user.id.isEmpty) {
        throw Exception('user not found');
      }
      if (user.userType == 'guest') {
        throw Exception('Please login first to join spaces');
      }

      final isSpace = await spaceRepo.fetchSpaceLocal(
        spaceId: spaceId, userId: user.id,);


      if (isSpace != null) {
        throw Exception('Already part of the space');
      }
      final id = const Uuid().v4();
      final member = MemberModel(
        role: MemberRole.member.name,
        name: user.name,
        spaceID: spaceId,
        id: id,
        userId: user.id,
        photo: user.photoUrl,
      );
      final space = await spaceRepo.fetchSpaceRemote(spaceId: spaceId);
      if (space == null) {
        throw Exception('No space found');
      }
      try{
        await Future.wait([
          userRepo.addSpaceToUserRemote(user: user, spaceId: space.id),
          memberRepo.addMemberToSpaceRemote(member: member)
        ]);
      }catch(e){
        await Future.wait([
          userRepo.removeSpaceFromUser(user: user, spaceId: space.id),
          memberRepo.removeMemberFromSpaceRemote(member: member)
        ]);
        throw Exception('Failed to join remote space: $e');
      }
      await loadSpaceFromRemoteUseCase(space: space);
    }catch(e){
      throw Exception('space joined failed');
    }
  }

  Future<SpaceModel?> defaultSpaceUseCase({required UserModel? user}) async{
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
    }
    final spaceId = await prefs.getString('current_space');

    if (spaceId != null) {
      final space = await spaceRepo.fetchSpaceLocal(userId: user.id, spaceId: spaceId);
      if (space != null) {
        return space;
      }
    }
    final SpaceModel? space = await spaceRepo.getFirstSpace(userId: user.id);
    if (space != null) {
      await prefs.changeCurrentSpace(space.id);
      return space;
    }
    return null;
  }


  Future<void> exitSpaceUseCase({required UserModel? user,required String spaceId,}) async{
    if (user == null || user.id.isEmpty) {
      throw Exception('user not found');
    }
    await localTransactionManager.executeAtomic(action: (batch){
      spaceRepo.deleteLocalSpaceAtomic(spaceId: spaceId,batch: batch);
      itemRepository.removeLocalSpaceItemAtomic(batch:batch,spaceId: spaceId);
      memberRepo.removeLocalMemberFromSpaceAtomic(spaceId: spaceId,batch:batch);
    });

    await remoteTransactionManager.executeAtomic( (batch ){
      memberRepo.removeMemberFromSpaceRemoteBatch(spaceId: spaceId,batch:batch);
      userRepo.removeSpaceFromUserRemoteBatch(user: user, spaceId: spaceId, batch: batch);
    });

  }

  Future<SpaceCardModel> getSpaceCardModel({required String spaceId}) async {
    try{
      final int items = await itemRepository.fetchCountItemInSpaceLocal(spaceId:spaceId);
      final int members = await memberRepo.fetchCountMemberLocal(spaceId:spaceId);
      return SpaceCardModel(members, items);
    }catch(e){
      throw Exception('something went wrong');
    }
  }

  Future<void> loadSpaceFromRemoteUseCase({required SpaceModel space}) async {
    try{
      final result = await Future.wait([
        memberRepo.fetchAllMemberRemote(spaceId: space.id),
        itemRepository.fetchRemoteItemInSpace(spaceId: space.id),
        quickListRepo.getQuickListRemote(spaceId: space.id),
        expenseRepository.getExpensesRemote(spaceId: space.id)
      ]);
      List membersMap = result[0];
      List<ItemModel> items = result[1] as List<ItemModel>;
      List<ExpenseModel> expenses = result[3] as List<ExpenseModel>;
      List<QuickListModel> quickList = result[2] as List<QuickListModel>;

      List<MemberModel> members = [];
      for (MemberModel mem in membersMap) {
        final newM = MemberModel(
          role: mem.role,
          name: mem.name,
          spaceID: mem.spaceID,
          id: mem.id,
          userId: mem.userId,
          photo: mem.photo,
        );
        members.add(newM);
      }

      await localTransactionManager.executeAtomic(
        action: (batch) async {
          memberRepo.addMembersLocal(
            members: members,
            spaceId: space.id,
            batch: batch,
          );
          itemRepository.insertItemsLocally(items: items, batch: batch);
          spaceRepo.createSpaceLocal(space: space, batch: batch);
          expenseRepository.addExpensesBatch(expense: expenses, batch: batch);
          quickListRepo.addQuickListBatch(list: quickList, batch: batch);
        },
      );
    }catch(e){
      throw Exception('something went wrong');
    }
  }

}
