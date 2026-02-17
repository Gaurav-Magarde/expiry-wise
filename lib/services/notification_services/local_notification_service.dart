import 'dart:io';
import 'package:expiry_wise_app/features/inventory/data/datasource/inventory_local_datasource_interface.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

final notificationServiceProvider = Provider<LocalNotificationService>(
      (ref) => LocalNotificationService(ref),
);

class LocalNotificationService {
  late PrefsService _prefsService;
  final Ref ref;

  LocalNotificationService(this.ref);

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- TIMEZONE FIX START ---
    tz.initializeTimeZones();


    try {
      final location = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(location);
    } catch (e) {
      tz.setLocalLocation(tz.local);
    }
    // --- TIMEZONE FIX END ---

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
    const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: initializationSettingsDarwin,
    );

    await _flutterLocalNotificationsPlugin.initialize(settings);

    await requestPermissions();

    _prefsService = ref.read(prefsServiceProvider);

  }


  Future<void> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  int _generateNotificationId(String itemId, int daysBefore) {
    return '${itemId}_$daysBefore'.hashCode.abs();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required dynamic date, // Accepts DateTime or TZDateTime
  }) async {

    tz.TZDateTime tzDate;
    if (date is DateTime) {
      tzDate = tz.TZDateTime.from(date, tz.local);
    } else {
      tzDate = date;
    }

    // 2. Past Check
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }


    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'expiry_channel_ALARM_V1', //
            'Alarm Notifications',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF673AB7),
            playSound: true,


            fullScreenIntent: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),

        androidScheduleMode: AndroidScheduleMode.alarmClock,

        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'Payload',
      );
    } catch (e) {
    }
  }

  Future<void> scheduleNotificationFor(ItemModel item) async{
    try{
      if(item.finished==1) return;

      for(final days in _prefsService.allDaysNotify){
       await cancelNotification(itemId: item.id, days: days);
      }
      for(final days in item.notifyConfig){
        int id = _generateNotificationId(item.id, days);

        final expiry = DateTime.tryParse(item.expiryDate??'');
        if(expiry==null) continue;
        final time = await _prefsService.getNotificationTime();

        final triggerDate = expiry.subtract(Duration(days: days));

        // Construct using DateTime first
        final scheduledDateTime = DateTime(
          triggerDate.year,
          triggerDate.month,
          triggerDate.day,
          time.hour,
          time.minute,
        );

        // Convert to TZ immediately
        final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

        await scheduleNotification(id: id, title: days == 1?"Expiring Today: ${item.name}":days == 1
            ? "Expiring Tomorrow: ${item.name}"
            : "${item.name} expires in $days days", body: 'Check your pantry.', date: tzScheduledDate);

      }
    }catch(e){

    }
  }
  Future<void> cancelNotificationFor(ItemModel item) async{
    try{
      for(final days in _prefsService.allDaysNotify){
       await cancelNotification(itemId: item.id, days: days);
      }
    }catch(e){

    }
  }
  Future<void> cancelAllNotification() async{
    try{
      await _flutterLocalNotificationsPlugin.cancelAll();
    }catch(e){

    }
  }
  Future<void> reScheduleAllNotification() async {
    try {
      final isNotify = await _prefsService.getIsNotificationOn();
      if(!isNotify) return;
      final items = await ref.read(inventoryLocalDataSourceProvider).fetchAllItems();
      final time = await _prefsService.getNotificationTime();

      final now = tz.TZDateTime.now(tz.local);

      for (var item in items) {
        if(item.finished==1) continue;
        DateTime expiryDate;
        try {
          expiryDate = DateTime.parse(item.expiryDate??'');
        } catch (e) { continue; }

        for (int days in item.notifyConfig) {
          final triggerDate = expiryDate.subtract(Duration(days: days));

          // Construct using DateTime first
          final scheduledDateTime = DateTime(
            triggerDate.year,
            triggerDate.month,
            triggerDate.day,
            time.hour,
            time.minute,
          );

          // Convert to TZ immediately
          final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

          if (tzScheduledDate.isAfter(now)) {
            await scheduleNotification(
              id: _generateNotificationId(item.id, days),
              title: days == 1
                  ? "Expiring Tomorrow: ${item.name}"
                  : "${item.name} expires in $days days",
              body: "Check your pantry.",
              date: tzScheduledDate,
            );
          }
        }
      }
      await checkPendingNotifications();
    } catch (e) {

    }
  }

  Future<void> cancelNotification({required String itemId, required int days}) async {
    int id = _generateNotificationId(itemId, days);
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> checkPendingNotifications() async {
    final pending = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

class NotificationCandidate {
  final int id;
  final String itemName;
  final DateTime scheduledDate;
  final int daysBefore;

  NotificationCandidate({
    required this.id,
    required this.itemName,
    required this.scheduledDate,
    required this.daysBefore,
  });
}