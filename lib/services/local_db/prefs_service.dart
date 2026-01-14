import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefsServiceProvider = Provider((ref)=>PrefsService.instance);

class PrefsService{
  static final PrefsService instance =  PrefsService._();
  PrefsService._();
  static const SharedPreferencesOptions _options = SharedPreferencesOptions();
  static SharedPreferencesAsync get prefs => SharedPreferencesAsync(options: _options);

  Future<bool> get isUserFirstLogin async => await prefs.getBool("is_first_time")??false;
  Future<void>  setIsFirst( bool isFirst) async {
    await prefs.setBool("is_first_time", isFirst);
  }

  Future<String?> getString(String s) async {
   return await prefs.getString(s);


  }

  Future<void> addString(String id) async {
    prefs.setString("current_user_id", id);
  }

  Future<void> changeCurrentSpace(String currSpaceId)async{
    try{
      print("reach");

      await prefs.setString("current_space", currSpaceId);
    }catch(e){
      throw " ";
    }
  }

  Future<void> setCurrentUserId(String id) async {
    try{
      await prefs.setString("current_user_id", id);
    }catch(e){
      throw " ";
    }
  }

  Future<void> clearAllPrefs() async {

    await PrefsService.prefs.clear(); // This deletes EVERYTHING
    print("All shared preferences cleared");
  }

  Future<String?> getCurrentUserId() async {
    try{
      return await prefs.getString("current_user_id");
    }catch(e){
      throw " ";
    }
  }

  Future<bool>  getAutoSync() async {
    try{
      return await prefs.getBool("auto_sync_status")??false;
    }catch(e){
      throw " ";
    }
  }

  Future<void> setAutoSync(bool status) async {
    try{
      return await prefs.setBool("auto_sync_status",status);
    }catch(e){
      throw " ";
    }
  }

  Future<bool>  getIsNotificationOn() async {
    try{
      return await prefs.getBool("is_notification_on")??false;
    }catch(e){
      throw " ";
    }
  }

  Future<void> setNotificationStatus(bool status) async {
    try{
      print("new set $status");

      return await prefs.setBool("is_notification_on",status);
    }catch(e){
      throw " ";
    }
  }

 Future<bool>  getItemDeleteAlert() async {
    try{
      return await prefs.getBool("item_delete_alert")??true;
    }catch(e){
      throw " ";
    }
  }

  Future<void> setItemDeleteAlert(bool status) async {
    try{

      return await prefs.setBool("item_delete_alert",status);
    }catch(e){
      throw " ";
    }
  }

  Future<String> setNotificationTime(TimeOfDay time) async {
    try{
      final hour = time.hour.toString().padLeft(2,'0');
      final minute = time.minute.toString().padLeft(2,'0');
      await prefs.setString('notification_time', "$hour:$minute");
      return "$hour:$minute";
    }catch(e){
      throw " ";
    }
  }

  Future<TimeOfDay> getNotificationTime() async {
    try{
      final time = await prefs.getString("notification_time");
      if(time==null){
        await setNotificationTime(TimeOfDay(hour: 9, minute: 0));
        return TimeOfDay(hour: 9, minute: 0);
      }
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }catch(e){
      throw " ";
    }
  }



  static const String _keyNotifyDays = 'notify_days';

  final List<int> defaultDays = [1, 7];
  final List<int> allDaysNotify = [0,1,2,7,14,28];

  // Load Saved Days
    Future<List<int>> getNotificationDays() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_keyNotifyDays);

    if (saved == null) return defaultDays;
    return saved.map((e) => int.parse(e)).toList();
  }

  // Save Days
  Future<void> saveNotificationDays(List<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> stringList = days.map((e) => e.toString()).toList();
    await prefs.setStringList(_keyNotifyDays, stringList);
  }

}



