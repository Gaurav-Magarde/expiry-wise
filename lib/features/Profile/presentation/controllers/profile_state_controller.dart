import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/routes/presentation/controllers/route_controller.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/local_db/sqflite_setup.dart';
import 'package:expiry_wise_app/services/notification_services/local_notification_service.dart';
import 'package:expiry_wise_app/services/remote_db/fire_store_service.dart';
import 'package:expiry_wise_app/services/sync_services/local_firebase_syncing.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/material/time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../services/Connectivity/internet_connectivity.dart';


final profileStateProvider = NotifierProvider<ProfileStateController,ProfileState>(
  (){
    return  ProfileStateController();
  }
);

class ProfileStateController extends Notifier<ProfileState> {

  ProfileStateController();

  Future<void>  deleteUser ()async {
    final user = ref.read(currentUserProvider);
    if(user.value == null || user.isLoading || user.hasError || user.value!.id.isEmpty) {
      SnackBarService.showError('user not found.please try again later');
      return;
    }
    final isInternet = ref.read(isInternetConnectedProvider);
    final currentUser = user.value!;
    if(currentUser.userType=='google' && !isInternet){
      SnackBarService.showMessage('check your internet connection');
      return;
    }
    final sqf = ref.read(sqfLiteSetupProvider);
    final prefs = ref.read(prefsServiceProvider);
    final fireStore = ref.read(fireStoreServiceProvider);
    await sqf.deleteDataBase();
    await prefs.clearAllPrefs();
    if(currentUser.userType=='google') {
      await fireStore.deleteUserFromFirebase(userId: currentUser.id);
      if(FirebaseAuth.instance.currentUser!=null) await FirebaseAuth.instance.signOut();
    }
    ref.invalidate(currentUserProvider);
  }
  Future<void>  logOutUser () async {
    final user = ref.read(currentUserProvider);
    if(user.value == null || user.isLoading || user.hasError || user.value!.id.isEmpty) {
      SnackBarService.showError('user not found.please try again later');
      return;
    }
    final isInternet = ref.read(isInternetConnectedProvider);
    final currentUser = user.value!;
    if(currentUser.userType=='google' && !isInternet){
      SnackBarService.showMessage('check your internet connection');
      return;
    }
    final sqf = ref.read(sqfLiteSetupProvider);
    final prefs = ref.read(prefsServiceProvider);
    await sqf.deleteDataBase();
    await prefs.clearAllPrefs();
    if(currentUser.userType=='google'){
      if(FirebaseAuth.instance.currentUser!=null) await FirebaseAuth.instance.signOut();
      FirebaseStreams firebaseStream = ref.read(
        firebaseStreamProvider,
      );
    }
    ref.invalidate(currentUserProvider);
    ref.read(screenRedirectProvider).screenRedirect();

  }
  Future<void> initializeUserData() async {
    final prefs = ref.read(prefsServiceProvider);

    final user = ref.read(currentUserProvider).value!;
    String name =user.name;
    String photoUrl =user.photoUrl;
    String email =user.email;
    final autoSync = await prefs.getAutoSync();
    final notification = await prefs.getIsNotificationOn();
    final time = await prefs.getNotificationTime();
   state = ProfileState(photoUrl: photoUrl, name: name, email: email, autoSync: autoSync,notification: notification, notificationTime: time);

  }

  @override
  ProfileState build() {
    ref.listen(currentUserProvider, (_,__){
      initializeUserData();
      
    });

    initializeUserData();

    return ProfileState(autoSync: false, notification: false, photoUrl: '', name: '', email: '',notificationTime: TimeOfDay(hour: 09, minute: 00));
  }

  Future<void> changeName(newName) async {
    try{
      if(newName.trim().isEmpty){
        SnackBarService.showError('Please enter name');
        return;
      }
      final isInternet = ref.read(isInternetConnectedProvider);
      final user = ref.read(currentUserProvider).value ;
      if(user==null || user.id.isEmpty ){
        SnackBarService.showError('user not found');
        return;
      }
      final sqf = ref.read(sqfLiteSetupProvider);
      final fireStore = ref.read(fireStoreServiceProvider);
      Map<String,dynamic> map = {
        'name' : newName
      };
      final userId = user.id;
      if( user.userType=='guest'){
        await sqf.updateUser(map,userId);
        state = state.copyWith(name: newName);
      }
      else if( user.userType=='google' ){
        if(!isInternet){
          SnackBarService.showMessage('Name change failed.please check internet connection!');
          return;
        }
        await sqf.updateUser(map,userId);
        await fireStore.updateUserFromFirebase(map: map, id: userId);
      await ref.read(currentUserProvider.notifier).fetchNewName(userId);
      }
      SnackBarService.showSuccess('Name changed successfully');

    }catch(e){
      SnackBarService.showError('Name changed failed $e');
    }
  }

  Future<void> changeNotificationAlert(bool notification) async {
    try{
      final prefs = ref.read(prefsServiceProvider);
      await prefs.setNotificationStatus(notification);
      state = state.copyWith(notification: notification);
      SnackBarService.showMessage(notification ? 'notification alerts on' : 'notification alerts off');

    }catch(e){
      SnackBarService.showError('Notification alert failed $e');
    }
  }

  Future<void> changeAutoSync(bool autoSync) async {
    try{

      final user = ref.read(currentUserProvider).value ;
      if(user==null || user.id.isEmpty ){
        SnackBarService.showError('user not found');
        return;
      }
      if( user.userType=='guest' ){

          SnackBarService.showMessage('please login first to auto sync the items!');
          return;

      }
      final prefs = ref.read(prefsServiceProvider);
      await prefs.setAutoSync(autoSync);
      state = state.copyWith(autoSync: autoSync);
      SnackBarService.showMessage(autoSync ? 'Auto sync on' : 'Auto sync off');

    }catch(e){
      SnackBarService.showError(autoSync ? 'Auto sync on failed ' : 'Auto sync off failed ');
    }
  }

  Future<void> setNotificationTime(TimeOfDay pickedTime) async {
    try{
      final prefs = ref.read(prefsServiceProvider);
      final time = await prefs.setNotificationTime(pickedTime);
      state = state.copyWith(notificationTime: pickedTime);
      SnackBarService.showMessage('Notification time changed to $time');
      ref.read(notificationServiceProvider).reScheduleAllNotification();
    }catch(e){
      SnackBarService.showError(' Notification Time change failed $e');

    }
  }

  Future<TimeOfDay> getNotificationTime() async {
    try{
      final prefs = ref.read(prefsServiceProvider);
      return await prefs.getNotificationTime();
    }catch(e){
      SnackBarService.showMessage('Something went wrong');
    }
    return TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> manualSync() async {
    try{
      final isInternet = ref.read(isInternetConnectedProvider);
      final user = ref.read(currentUserProvider);
      if(user.value==null || user.value!.id.isEmpty){
        SnackBarService.showError('sync failed user not found');
        return;
      }
      if(!isInternet){
        SnackBarService.showMessage('no internet connection');
        return;
      }
      if(user.value!.userType=='guest'){
        SnackBarService.showMessage('login to sync items');
        return;
      }
      await ref.read(syncProvider).performManualSync();
      SnackBarService.showSuccess('all items synced successfully');

    }catch(e){

    }
  }

}

final isDialerLoadingProvider = StateProvider.autoDispose<bool>((ref)=>false);