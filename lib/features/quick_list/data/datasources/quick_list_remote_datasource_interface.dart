
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/quick_list/data/datasources/quick_list_remote_datasouce_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../models/quicklist_model.dart';

abstract interface class IQuickListRemoteDatasource{
  Future<void> saveToQuickList({required QuickListModel item});
  Future<List<QuickListModel>> getFromQuickList({
    required String spaceId,
  });
  Future<void> deleteFromQuickList({required String spaceId,required String id,}) ;
}
final quickListRemoteDataSourceProvider = Provider<IQuickListRemoteDatasource>((ref){
  final instance = FirebaseFirestore.instance;
  return QuickListRemoteDatasourceImpl(instance: instance);
});