import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_remote_datasource_interface.dart';

import '../models/quicklist_model.dart';

class QuickListRemoteDatasourceImpl implements IQuickListRemoteDatasource {
  final FirebaseFirestore instance;
  QuickListRemoteDatasourceImpl({required this.instance});
  static const String quickListSubCollection = 'quick_list';
  static const String spaceCollection = 'spaces';
  static const String quickListIdKey = 'id';
  static const String spaceIdKey = 'space_id';
  static const String userIdKey = 'user_id';
  static const String isDeletedKey = 'is_deleted';
  static const String updatedAtKey = 'updated_at';
  static const String isSyncedKey = 'is_synced';
  @override
  Future<void> saveToQuickList({required QuickListModel item}) async {
    await instance
        .collection(spaceCollection)
        .doc(item.spaceId)
        .collection(quickListSubCollection)
        .doc(item.id)
        .set(item.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteFromQuickList({
    required String spaceId,
    required String id,
  }) async {
    await instance
        .collection(spaceCollection)
        .doc(spaceId)
        .collection(quickListSubCollection)
        .doc(id)
        .update({isDeletedKey:true});
  }

  @override
  Future<List<QuickListModel>> getFromQuickList({
    required String spaceId,
  }) async {
    final doc = await instance
        .collection(spaceCollection)
        .doc(spaceId)
        .collection(quickListSubCollection)
        .where(isDeletedKey,isNotEqualTo: true)
        .get();
    final List<QuickListModel> quickList = [];
    for(final docs in doc.docs){
        final data = docs.data();
        final listItem = QuickListModel.fromMap(map: data);
        quickList.add(listItem);
    }
    return quickList;
  }
}
