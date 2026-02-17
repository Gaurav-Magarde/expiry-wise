import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/remote_firebase_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../model/space_model.dart';

abstract interface class ISpaceRemoteDataSource{

  Future<void> insertSpaceTOFirebase(String userId, SpaceModel space);

  Future<void> deleteSpaceFromFirebase({required String spaceId});
  void deleteSpaceFromFirebaseBatch({required String spaceId,required WriteBatch batch});


  Future<void> updateSpaceFromFirebase({required Map<String,dynamic> map,required String id});

  Future<SpaceModel?> spaceDetailById({required String id});

  Future<List<SpaceModel>> getSpaces(List<String> spaceId);
}


final spaceRemoteDataSourceProvider = Provider<ISpaceRemoteDataSource>((ref) {
  return SpaceFirebaseDataSource();
});