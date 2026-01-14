import 'dart:async';

import 'package:expiry_wise_app/features/Space/data/repository/space_repository.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/inventory/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/quick_list_repository.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final allQuickListProvider = StreamProvider((ref) async* {
  final sqfLite = ref.read(sqfLiteSetupProvider);
  final spaceId = ref.read(currentSpaceProvider).value?.id;
  sqfLite.refreshQuickList(spaceId: spaceId ?? '');
  yield* sqfLite.quickListStream;
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
      final title = state.title;
      if (title == null || title.isEmpty) {
        return;
      }
      final id = Uuid().v4();
      final spaceId = ref.read(currentSpaceProvider).value?.id;
      if (spaceId == null || spaceId.isEmpty) {
        return;
      }
      final item = QuickListModel(
        id: id,
        spaceId: spaceId,
        title: title,
        isCompleted: false,
        isSynced: false,
        updatedAt: DateTime.now().toIso8601String(),
      );
      ref.read(quickListRepositoryProvider).addQuickListItem(item: item);
    } catch (e) {}
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
      isCompleted: isCompleted,
      isSynced: false,
      updatedAt: DateTime.now().toString(),
    );
    await ref.read(quickListRepositoryProvider).addQuickListItem(item: newItem);
  }
  Future<void> saveItem() async {

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
