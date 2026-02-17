import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/Space/data/datasource/space_remote_data_source.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../model/space_model.dart';

class SpaceFirebaseDataSource implements ISpaceRemoteDataSource{


  static const String spaceTable = 'spaces';
  static const String isDeletedColumn = 'is_deleted';
  static const String updatedAtColumn = 'updated_at';
  static const String isSyncedColumn = 'is_synced';
  static const String userIdColumn = 'user_id';
  static const String spaceIdColumn = 'id';
  final FirebaseFirestore instance = FirebaseFirestore.instance;
  @override
  Future<void> insertSpaceTOFirebase(String userId, SpaceModel space) async {
    try {
      final spaceToMap = space.toMap();
      await instance
          .collection(spaceTable)
          .doc(space.id).set(spaceToMap,SetOptions(merge: true));

    }  on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }catch (e){
      throw 'some went wrong';
    }
  }


  @override
  Future<void> deleteSpaceFromFirebase({required String spaceId}) async {
    try {
      await instance
          .collection(spaceTable)
          .doc(spaceId).update({isDeletedColumn:true});
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }catch (e){
      throw 'some went wrong';
    }
  }


  @override
  Future<void> updateSpaceFromFirebase({required Map<String,dynamic> map,required String id}) async {
    try{
     await instance.collection(spaceTable).doc(id).update(map);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }catch (e){
      throw 'some went wrong';
    }
  }

  @override
  Future<SpaceModel?> spaceDetailById({required String id}) async
  {
    try{
      final docRef = instance.collection(spaceTable).doc(id);
      DocumentSnapshot doc =  await docRef.get();
      if(doc.exists){
        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return null;
        final space = SpaceModel.fromMap(map: data, userId: data[userIdColumn]);
        return space;
      }


    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }catch (e){
      throw 'some went wrong';
    }
    return null;
  }

  @override
  void deleteSpaceFromFirebaseBatch({required String spaceId, required WriteBatch batch}){
    final spaceRef = instance.collection(spaceTable).doc(spaceId);
    batch.update(spaceRef,{isDeletedColumn:true});
  }

  @override
  Future<List<SpaceModel>> getSpaces(List<String> spaceId) async{

    final snapQuery = await instance.collection(spaceTable).where(FieldPath.documentId,whereIn: spaceId).get();
   final List<SpaceModel> spaceList = [];
    for(final doc in snapQuery.docs){
      final spaceMap = doc.data();
      final space = SpaceModel.fromMap(map: spaceMap);
      spaceList.add(space);
    }
    return spaceList;
  }

}