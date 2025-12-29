import 'package:cloud_firestore/cloud_firestore.dart';

class HomeRepository{

  final fireStore = FirebaseFirestore.instance;
  void fetchDataFromFirebase(){
    try{
      final path = fireStore.collection('Users').doc("Uid");
      path.collection("Spaces").get();
    }catch(e){
      return;
    }
  }

}