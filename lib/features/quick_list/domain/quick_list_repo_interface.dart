import 'package:expiry_wise_app/features/quick_list/data/models/quicklist_model.dart';
import 'package:sqflite_common/sqlite_api.dart';

abstract class QuickListRepoInterface {
  Stream<List<QuickListModel>> get quickListStream;

  Future<void> saveToQuickList({required QuickListModel item});

  Future<void> removeFromQuickList({required String id,required String spaceId});

  Future<void> updateInQuickList({required QuickListModel item});

  Future<List<QuickListModel>> getQuickList({required String spaceId});

  Future<List<QuickListModel>> getQuickListRemote({required String spaceId});

  void refreshList({required String spaceId});

  void addQuickListBatch({required List<QuickListModel> list, required Batch batch});
}


