import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/data/model/space_model.dart';
import 'package:expiry_wise_app/features/User/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/inventory/data/models/item_model.dart';
import '../../core/utils/exception/exceptions.dart';
import '../../core/utils/exception/firebase_auth_exceptions.dart';
import '../../core/utils/exception/firebase_exceptions.dart';
import '../../core/utils/exception/format_exceptions.dart';
import '../../core/utils/exception/platform_exceptions.dart';

final fireStoreServiceProvider = Provider<FireStoreService>((ref){
  final SqfLiteSetup sqfLiteSetup = ref.read(sqfLiteSetupProvider);


  // final firebaseStream = ref.read(firebaseStreamProvider);
 return  FireStoreService._(sqfLiteSetup);
});

class FireStoreService {
  FireStoreService._(this._sqfLiteSetup,);
  final SqfLiteSetup _sqfLiteSetup;

  get instance => FirebaseFirestore.instance;


  // ---------------------------[Items Firebase] -----------------------------

  Future<void> insertItemToFirebase(
    String userId,
    String spaceId,
    ItemModel item,
  ) async {
    try {
      if (item.expiryDate.isEmpty ||
          item.name.isEmpty ||
          item.category.isEmpty ||
          item.spaceId ==null ||
          item.userId == null ||
          item.spaceId!.isEmpty ||
          item.userId!.isEmpty) {
        return;
      }
      final itemInMap = item.toMap();
      itemInMap['is_synced'] = 1;
      itemInMap['image'] = '';
      itemInMap['updated_at'] = DateTime.now().toString();
      await instance
          .collection("spaces")
          .doc(spaceId)
          .collection("items")
          .doc(item.id)
          .set(itemInMap);

      await _sqfLiteSetup.markItemAsSynced(item.id);

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


  Future<List<ItemModel>> fetchAllItemsFirebase(String userId,String spaceId) async {
    try {
      final spaceRef = instance
          .collection("spaces")
          .doc(spaceId);
      DocumentSnapshot doc = await spaceRef.get();

      if(doc.exists){
        final snapshot = await spaceRef.collection("items")
            .get();


        List<ItemModel> list = [];
        for(final s in snapshot.docs){
              final map = s.data() as Map<String, dynamic>;

              if(map.isEmpty) continue;
              map['user_id'] = userId;
              map['is_synced'] = 1;

              map['image'] = '';

              list.add(ItemModel.fromMap(item: map));

            }
        return list;
      }
      return [];
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

  Future<void> deleteItemFromFirebase({required String id,required String spaceId}) async {
    try{
      final docRef = await instance.collection("spaces").doc(spaceId).collection("items").doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        await docRef.delete();
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


  Future<void> updateItemFromFirebase({required Map<String,dynamic> map,required String id}) async {
    try{
      final docRef = instance.collection("spaces").doc(map['space_id']??'').collection("items").doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        map['is_synced'] = 1;
        map['image'] = '';

        map['updated_at'] = DateTime.now().toString();

        await docRef.update(map);
      }
      await _sqfLiteSetup.markItemAsSynced(id);

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


  // -------------------------------------[Space Firebase] ----------------------------------

  Future<void> insertSpaceTOFirebase(String userId, SpaceModel space) async {
    try {
      final spaceToMap = space.toMap();
      final docRef = await instance
          .collection("spaces")
          .doc(space.id);
      final doc = await docRef.get();
      if(doc.exists){
        spaceToMap['updated_at'] = DateTime.now().toString();

        await updateSpaceFromFirebase(map: spaceToMap, id: space.id);
      }else{
        await docRef
            .set(spaceToMap);
      await addSpaceToUser(spaceId: space.id, userId: userId);
      }
      await _sqfLiteSetup.markSpaceAsSynced(space.id);
      // _firebaseStreams.startAllListeners(null);
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


  Future<void> deleteSpaceFromFirebase({required String spaceId}) async {
    try {
      final docRef = await instance
          .collection("spaces")
          .doc(spaceId);
      DocumentSnapshot doc = await  docRef.get();
      if(doc.exists){
        final data = doc.data() as Map;
        List members = data['member'] ?? [];

        if(members.isNotEmpty){
          for(var member in members){
            await removeSpaceFromUser(spaceId: spaceId, id: member['user_id']);
          }
        }

        final res = await docRef.delete();
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


  Future<void> updateSpaceFromFirebase({required Map<String,dynamic> map,required String id}) async {
    try{
      final docRef = await instance.collection("spaces").doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        map['updated_at'] = DateTime.now().toString();

        await docRef.update(map);
      }

      await _sqfLiteSetup.markSpaceAsSynced(id);

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

  Future<SpaceModel?> spaceDetailById({required String id, required userId}) async
  {
    try{

      final docRef = await instance.collection("spaces").doc(id);
      DocumentSnapshot doc =  await docRef.get();
      if(doc.exists){
        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return null;
        final space = SpaceModel.fromMap(map: data,userId: userId);
        return space;
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
  // ----------------------------------------[user Firebase] ----------------------------

  Future<void> insertUserTOFirebase(UserModel user) async {
    try {
      final userToMap = user.toMap();
      final docRef = await instance
          .collection('users')
          .doc(user.id);
      final doc = await docRef.get();
      if(doc.exists) {
        userToMap['is_synced'] = 1;
        userToMap['updated_at'] = DateTime.now().toString();

        updateUserFromFirebase(map: userToMap, id: user.id);

      }
    else{
        userToMap['is_synced'] = 1;

        docRef.set(userToMap);
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

  Future<UserModel?> getUserDetail(String userId) async {
    try {

      final docRef = await instance
          .collection('users')
          .doc(userId);
      DocumentSnapshot doc = await docRef.get();
      if(doc.exists) {
        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return null;
        data['is_synced'] = 1;

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


  Future<void> addSpaceToUser({
    required String spaceId,
    required String userId,
  }) async {
    try {
      DocumentSnapshot snapshot = await instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic> userInfo = snapshot.data() as Map<String, dynamic>;


      final List spaceList = userInfo['spaces']  ?? [];
      final set = spaceList.toSet();
      set.add(spaceId);
      await instance.collection('users').doc(userId).set({
        'updated_at': DateTime.now().toString(),
        'spaces': set.toList(),
      }, SetOptions(merge: true));

      await _sqfLiteSetup.markSpaceAsSynced(spaceId);


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



  Future<void> addUserTOFirebase(UserModel user) async {
    try {
      final userToMap = user.toMap();
      userToMap['is_synced'] = 1;
      userToMap['updated_at'] = DateTime.now().toString();


      await instance
          .collection('users')
          .doc(user.id)
          .set(userToMap);

      await _sqfLiteSetup.markUserAsSynced(user.id);

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


  Future<List<SpaceModel>> fetchSpacesFromUser(String id) async {
    try {

      final docRef = await instance
          .collection('users')
          .doc(id);
      DocumentSnapshot doc = await docRef.get();

      if(doc.exists) {
        final data = doc.data() as Map<String,dynamic>;
        if(data.isEmpty) return [];
        List list = data['spaces'] ?? [];

        List<SpaceModel> spaces = [];
        print('%% => $list');

        for(final spaceId in list){

          final space = await spaceDetailById(id: spaceId,userId:id);

          if(space!=null) spaces.add(space);
          print(spaces);
        }
        print('#');
        return spaces;
      }
      return [];
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

  Future<void> updateUserFromFirebase({required Map<String,dynamic> map,required String id}) async {
    try{
      final docRef = await instance.collection("users").doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        map['is_synced'] = 1;
        map['updated_at'] = DateTime.now().toString();

        await docRef.update(map);
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
  Future<void> removeSpaceFromUser({required String spaceId,required String id}) async {
    try{
      final docRef = await instance.collection("users").doc(id);
      final doc =  await docRef.get();
      if(doc.exists){
        final data = doc.data();
        List spaces = data['spaces'] ?? [];
        if(spaces.isNotEmpty){
         spaces.removeWhere((space) => space == spaceId);
         docRef.update({'spaces' : spaces,'updated_at':DateTime.now().toString()});
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


  Future<void> deleteUserFromFirebase({required String userId}) async {
    try {
      final docRef = await instance
          .collection("users")
          .doc(userId);
      DocumentSnapshot doc = await  docRef.get();
      if(doc.exists){
        final spaces = await fetchSpacesFromUser(userId);
        for(var space in spaces){
          final member = MemberModel(role: 'member', name: 'name', spaceID: space.id, id: 'id', userId: userId, photo: 'photo');
          await removeMemberFromSpace(member);
        }
        await docRef.delete();
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

  // -----------------------------------------[member Firebase] ---------------------------



  Future<SpaceModel?> addMemberToSpace({
    required MemberModel member
  }) async {
    try {
      final time = DateTime.now().toString();


      final spaceId = member.spaceID;
      final userId = member.userId;
      final docRefSpace = await instance
          .collection('spaces')
          .doc(member.spaceID);

      DocumentSnapshot info = await docRefSpace.get();

      if(info.exists){

        final memberMap = member.toMap();
        final spaceInfo = info.data() as Map<String, dynamic>;
        final List list = spaceInfo['member'] ?? [];
      String spaceName = spaceInfo['name'];
      print("add member map $memberMap");
        for(final mem in list){
          if(mem['user_id']==member.userId) return null;
        }
        memberMap['is_synced'] = 1;
        list.add(memberMap);

        Map<String, dynamic> spaceMap = {'member': list,'update_at':time};
        await instance.collection('spaces').doc(spaceId).update(spaceMap);


        final docRefUser = await instance.collection('users').doc(userId);
        DocumentSnapshot userSnapshot = await docRefUser.get();
        if(userSnapshot.exists){
          final user = userSnapshot.data() as Map<String, dynamic>;
          List spaceList = user['spaces'] ?? [];
          final setSpace = spaceList.toSet();
          setSpace.add(spaceId);
          await instance.collection('users').doc(userId).update({
            'spaces': setSpace.toList(),
          });
        }else{
        }


        await _sqfLiteSetup.markMemberAsSynced(member.id);

        await _sqfLiteSetup.markSpaceAsSynced(spaceId);

        return SpaceModel(userId: userId, name: spaceName, id: spaceId,updatedAt: time);


      }else {
        return null;
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

  Future<List> fetchMembersFromSpace(String? userId, {spaceId})async {
    try{
     final docRef =  await instance.collection('spaces').doc(spaceId);
     final doc = await docRef.get();

     final memberList = [];
     if(doc.exists){
       final data = doc.data() as Map<String,dynamic>;
       final list  = data['member']??[];
        for(var member in list){
          member['is_synced'] = 1;

          final curr = MemberModel.fromLocal(member);
         memberList.add(curr);
        }
     }
     return memberList;
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


  Future<void> removeMemberFromSpace(MemberModel member) async {
    try{
      final docRef =  await instance.collection('spaces').doc(member.spaceID);
      final DocumentSnapshot doc = await docRef.get();
      if(doc.exists){
        final data = doc.data() as Map<String,dynamic>;
        List list  = data['member'] ?? [];
       List<Map<String,dynamic>> newMembers = [];
        for(final mem in list){
          if(mem['user_id']==member.userId) continue;
          newMembers.add(mem);
        }
        await docRef.update({'member':newMembers,'updated_at':DateTime.now().toString()});
        if(newMembers.isEmpty) await docRef.delete();
      }
        await removeSpaceFromUser(spaceId: member.spaceID, id: member.userId);

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
  Future<void> changeMemberRole(MemberModel member,String newRole) async {
    try{

      final docRef =  await instance.collection('spaces').doc(member.spaceID);
      final doc = await docRef.get();
      if(doc.exists){
        final data = doc.data() as Map<String,dynamic>;
        List list  = data['member'] ?? [];
        for(final mem in list){
          if(mem['user_id']==member.userId){
            mem['role'] = newRole;
          }
        }
        await docRef.update({'member' : list,'updated_at':DateTime.now().toString()});
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

  Future<bool> isExist({required String collection, required String doc}) async {
    try {

      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(doc)
          .get();

      // 3. Return existence status
      return snapshot.exists;

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
      throw 'something went wrong';
    }
  }
}
