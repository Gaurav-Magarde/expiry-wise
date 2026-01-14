import 'package:expiry_wise_app/features/inventory/data/models/quicklist_model.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final quickListRepositoryProvider = Provider((ref){
  final _sqfLiteSetup = ref.read(sqfLiteSetupProvider);
  return QuickList(_sqfLiteSetup);
});

class QuickList {
  QuickList(this._sqfLiteSetup);
  final SqfLiteSetup _sqfLiteSetup;
  Future<void> addQuickListItem({required QuickListModel item}) async {
    try {
      await _sqfLiteSetup.saveQuickListItem(item: item);
    } catch (e) {

    }
  }

  // Future<void> updateQuickListItem({required QuickListModel item}) async {
  //   await _sqfLiteSetup.(item: item);
  //
  // }
}
