import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/features/User/data/datasources/user_remote_datasource_interface.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/exception/exceptions.dart';
import '../../../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../../../core/utils/exception/firebase_exceptions.dart';
import '../../../../core/utils/exception/format_exceptions.dart';
import '../../../../core/utils/exception/platform_exceptions.dart';
import '../../../Space/data/model/space_model.dart';
import '../models/user_model.dart';

class UserRemoteDataSourceImpl implements IUserRemoteDataSource{

  final FirebaseFirestore instance;

  UserRemoteDataSourceImpl({required this.instance});
  static const String usersCollection = 'users';
  static const String userIdKey = 'id';
  static const String spaceIdKey = 'space_id';
  static const String isDeletedKey = 'is_deleted';
  static const String updatedAtKey = 'updated_at';
  static const String isSyncedKey = 'is_synced';
  
  @override
  Future<void> saveUserTOFirebase(UserModel user) async {
    try {
      final userToMap = user.toMap();
      userToMap[isSyncedKey] = 1;
      await instance
          .collection(usersCollection)
          .doc(user.id)
          .set(userToMap, SetOptions(merge: true));
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<UserModel?> getUserDetail(String userId) async {
    try {

      final docRef = await instance
          .collection(usersCollection)
          // .where(isDeletedKey,isEqualTo: false)
          .doc(userId);
      DocumentSnapshot doc = await docRef.get();
      if(doc.exists) {
        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return null;
        final user = UserModel.fromMap(data);
        return user;
      }
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
    return null;
  }


  @override
  Future<void> addSpaceToUser({
    required String spaceId,
    required String userId,
  }) async {
    try {
      DocumentSnapshot snapshot = await instance
          .collection(usersCollection)
          .doc(userId)
          .get();
      Map<String, dynamic> userInfo = snapshot.data() as Map<String, dynamic>;


      final List spaceList = userInfo[spaceIdKey]  ?? [];
      if(spaceList.contains(spaceId)){
        throw Exception('Already joined');
      }else{
        await instance
            .collection(usersCollection)
            .doc(userId).
        update({spaceIdKey:FieldValue.arrayUnion([spaceId], )});

      }



    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }



  @override
  Future<void> addUserTOFirebase(UserModel user) async {
    try {
      final userToMap = user.toMap();
      userToMap[isSyncedKey] = 1;
      await instance
          .collection(usersCollection)
          .doc(user.id)
          .set(userToMap,
          SetOptions(merge: true));


    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }


  // TODO:HERE LOGIC OF SPACES IS WRITTEN NEED TO SHIFT
  @override
  Future<List<String>> fetchSpacesFromUser(String id) async {
    try {

      final docRef = await instance
          .collection(usersCollection)
          .doc(id);
      DocumentSnapshot doc = await docRef.get();

        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return [];
      List<String> list = List<String>.from(data[spaceIdKey] ?? []);

        return list;

    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw const TExceptions().message;
    }catch (e){
      throw 'some went wrong ${e.toString()}e';
    }
  }


  @override
  Future<void> removeSpaceFromUser({required String spaceId,required String id}) async {
    try{
      final docRef = instance.collection(usersCollection).doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        final data = doc.data();
        List spaces = data?[spaceIdKey] ?? [];
        if(spaces.isNotEmpty){
          spaces.removeWhere((space) => space == spaceId);
          await docRef.update({spaceIdKey : spaces,});
        }else{
          throw Exception('space not Found');
        }
      }
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }


  @override
  void removeSpaceFromUserBatch({required WriteBatch batch, required String spaceId, required String userId}) {
    final userRef = FirebaseFirestore.instance.collection(usersCollection).doc(userId);
    batch.update(userRef, { spaceIdKey: FieldValue.arrayRemove([spaceId])});
  }


  @override
  Future<void> deleteUserFromFirebase({required String userId}) async {
    try {
      await instance
          .collection(usersCollection)
          .doc(userId).update({isDeletedKey:true});
    } on FirebaseAuthException catch (e){
      throw TFirebaseAuthException(e.code);
    } on PlatformException catch (e){
      throw TPlatformException(e.code);
    } on FormatException catch (e){
      throw TFormatException(e.message);
    } on FirebaseException catch (e){
      throw TFirebaseException(e.code);
    }on Exception {
      throw TExceptions().message;
    }catch (e){
      throw 'some went wrong';
    }
  }
}