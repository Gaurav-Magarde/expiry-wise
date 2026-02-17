import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_local_datasource_impl.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';
import 'package:sqflite/sqflite.dart';

import '../models/quicklist_model.dart';

abstract interface class IQuickListLocalDatasource{
  Stream<List<QuickListModel>> get quickListStream;

  Future<void> saveQuickListItem({required QuickListModel item});
  void addQuickListBatch({required List<QuickListModel> quickList,required Batch batch,});

  Future<void> deleteQuickListItem({required String id,required String spaceId});

  Future<void> loadQuickListItem({required String spaceId});

  Future<List<QuickListModel>> fetchQuickListItem({required String spaceId});

  Future<List<QuickListModel>> fetchNonSyncedQuickListItem();

  Future<void> refreshQuickList({required String spaceId});

  Future<List<QuickListModel>> getNonSyncedDeletedQuickList();

}
final quickListLocalDataSourceProvider = Provider<IQuickListLocalDatasource>((ref){
  final sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  return QuickListLocalDataSourceImpl(sqfLiteSetup: sqfLiteSetup);
});