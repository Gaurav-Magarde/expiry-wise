import 'dart:async';

import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/quick_list/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/presentation/controllers/services/quick_list.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final allQuickListProvider = StreamProvider((ref) async* {
  final quickListRepo = ref.read(quickListRepoProvider);
  final spaceId = ref.watch(currentSpaceProvider).value?.id;
  quickListRepo.refreshList(spaceId: spaceId??'');
  yield* quickListRepo.quickListStream;
});

final quickListItemsControllerProvider = AsyncNotifierProvider.autoDispose(
  () => QuickListItemsController(),
);
final quickListControllerProvider = NotifierProvider.autoDispose(
  () => QuickListController(),
);

class QuickListItemsController extends AsyncNotifier<List<QuickListModel>> {
  @override
  Future<List<QuickListModel>> build() async {
    final allQuickList = await ref.watch(allQuickListProvider.future);
    return allQuickList;
  }
}

class QuickListController extends Notifier<QuickListState> {
  @override
  QuickListState build() {
    return QuickListState.emptyState();
  }

  Future<void> addNewItem() async {
    try {
      final spaceId = ref.read(currentSpaceProvider).value?.id;

      final quickListService = ref.read(quickListServiceProvider);
      await quickListService.addNewItem(state: state, currentSpace: spaceId);

    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }
  Future<void> deleteItem({required String id}) async {
    try {
      final spaceId = ref.read(currentSpaceProvider).value?.id;
      final quickListService = ref.read(quickListServiceProvider);
      await quickListService.deleteItem(id: id, currentSpace: spaceId);
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }

  Future<void> saveItemControl() async {
    try {
      state = state.copyWith(isSaving: true);
      await addNewItem();
    } catch (e) {
      SnackBarService.showError('QuickList Added failed.${e.toString()}');
    }
     finally{
       state = state.copyWith(editingId: '',isEditing: false,isSaving: false,title: '');
     }
  }

  void copyWith({
    String? title,
    String? editingId,
    bool? isEditing,
    bool? isSaving,}) {
    state = state.copyWith(title: title,isSaving: isSaving,editingId: editingId,isEditing: isEditing);
  }

  Future<void> toggleCompleted({required QuickListModel item}) async {
    final isCompleted = item.isCompleted;
    final newItem = QuickListModel(
      id: item.id,
      spaceId: item.spaceId,
      title: item.title,
      isCompleted: !isCompleted,
      isSynced: false,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await ref.read(quickListRepoProvider).saveToQuickList(item: newItem);
  }

}

class QuickListState {
  final String? title;
  final bool isEditing;
  final bool isSaving;
  final String? editingId;
  QuickListState({
    required this.isEditing,
    required this.isSaving,
    this.title,
    required this.editingId,
  });

  factory QuickListState.emptyState() {
    return QuickListState(
      editingId: null,
      isEditing: false,
      title: null,
      isSaving: false,
    );
  }

  QuickListState copyWith({
    String? title,
    String? editingId,
    bool? isEditing,
    bool? isSaving,
  }) {
    return QuickListState(
      isEditing: isEditing ?? this.isEditing,
      editingId: editingId ?? this.editingId,
      title: title ?? this.title,
      isSaving: isSaving??this.isSaving,
    );
  }


}
