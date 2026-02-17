
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/domain/quick_list_repo_interface.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_quick_list_model.dart';
import 'package:expiry_wise_app/services/local_db/local_transaction_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:uuid/uuid.dart';

import '../../../data/models/quicklist_model.dart';
import '../quick_list_controller.dart';

final quickListServiceProvider = Provider((ref){
  final quickListRepo = ref.read(quickListRepoProvider);
  final localTransaction = ref.read(providerLocalTransactionManager);
  return QuickListServices(quickListRepo: quickListRepo,localTransaction: localTransaction);
});

class QuickListServices{
  final QuickListRepoInterface quickListRepo;
  final LocalTransactionManager localTransaction;

  QuickListServices({required this.quickListRepo,required this.localTransaction});
  Future<void> addNewItem({required QuickListState state,required String? currentSpace,}) async {
    try {
      final title = state.title;
      if (title == null || title.isEmpty) {
        throw Exception('Enter title');
      }
      final id = state.editingId ?? const Uuid().v4();
      if (currentSpace == null || currentSpace.isEmpty) {
        throw Exception('no space found');
      }
      final item = QuickListModel(
        id: id,
        spaceId: currentSpace,
        title: title,
        isCompleted: false,
        isSynced: false,
        updatedAt: DateTime.now().toIso8601String(),
      );
      await quickListRepo.saveToQuickList(item: item);
    } catch (e) {
      throw Exception('Item Added failed.${e.toString()}');
    }
  }

  Future<void> deleteItem({required String id, String? currentSpace}) async {
    try {

      if (currentSpace == null || currentSpace.isEmpty) {
        throw Exception('no space found');
      }
      await quickListRepo.removeFromQuickList(id: id,spaceId: currentSpace);
    } catch (e) {
      throw Exception('QuickList Added failed.${e.toString()}');
    }
  }


  Future<void> addItemFromVoiceCommand({required List<AiQuickListModel> items, required UserModel? user,required SpaceModel? space,}) async {
    try{
      if(space==null) return;
      final spaceId = space.id;
      List<QuickListModel> quickList = [];
      for(final quickDto in items){
        final id = const Uuid().v4();
        final title = quickDto.title;
        final updatedAt = DateTime.now().toIso8601String();
        final listItem = QuickListModel(id: id, spaceId: spaceId, title: title, isCompleted: false, isSynced: false, updatedAt: updatedAt);
        quickList.add(listItem);
      }
      await localTransaction.executeAtomic(action: (batch){
        quickListRepo.addQuickListBatch(list: quickList, batch: batch);
      });
    }catch(e){

    }
  }
}