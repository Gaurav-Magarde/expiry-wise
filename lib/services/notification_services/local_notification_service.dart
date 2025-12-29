import 'dart:io';

import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../local_db/sqflite_setup.dart'; // Iske liye package add karna padega


final notificationServiceProvider = Provider<LocalNotificationService>((ref)=>LocalNotificationService(ref));
class LocalNotificationService {
  late PrefsService _prefsService;
  final Ref ref;
   LocalNotificationService(this.ref);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(settings);
    // 🔥 Yahan call karo
    await requestPermissions();
    _prefsService = ref.read(prefsServiceProvider);
  }


  Future<void> requestPermissions() async {
    // 1. Notification Permission (Android 13+)
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 2. Exact Alarm Permission (Android 12+)
    // Note: Iske bina 'zonedSchedule' exact time par nahi bajta
    if (Platform.isAndroid) {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    }
  }

  Future<void> showTestNotificationNow() async {
    // Schedules a notification for 5 seconds from now
    final now = DateTime.now().add(const Duration(seconds: 5));

    await scheduleNotification(
        id: 888,
        title: "Test Working! 🚀",
        body: "If you see this, notifications are fixed.",
        date: now
    );
  }

  Future<void> showImmediateNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_channel_v3', // 🔥 NEW Channel ID (Important)
      'Immediate Test',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      777,
      'Immediate Test 🔔',
      'If you see this, permissions are OK.',
      details,
    );
  }
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async {
    print("Scheduled notification ID $id for $date   , ${tz.local}");
    if(date.isBefore(DateTime.now())) return;
    {
      try{

        // if (Platform.isAndroid) {
        //   // Check karo ki permission hai ya nahi
        //   if (await Permission.scheduleExactAlarm.isDenied) {
        //     print("Permission nahi hai! User se maang rahe hain...");
        //
        //     // Ye user ko seedha 'Alarms & Reminders' setting me bhej dega
        //     // Wahan user ko toggle ON karna padega manually
        //     await Permission.scheduleExactAlarm.request();
        //
        //     // Note: User wapas aake jab tak ON nahi karega, crash ho sakta hai.
        //     // Isliye return kar do ya user ko bolo "Bhai permission de do"
        //     return;
        //   }
        // }
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          payload: '${date.toString()}  | ${tz.local}',
          tz.TZDateTime.from(date, tz.local),
          NotificationDetails(
              android: AndroidNotificationDetails(
                'expiry_channel_2',
                'Expiry Reminders',
                channelDescription: 'Notification for expiry',
                importance: Importance.max,
                priority: Priority.high,
              ),
              iOS: DarwinNotificationDetails()
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

          
        );
        await checkPendingNotifications();
      }catch(e){
        print("error is $e");
    }
    }
    print("Scheduled notification ID $id for $date confirmed");

    
  }


  Future<void> reScheduleAllNotification() async {
    try{
      final items = await ref.read(sqfLiteSetupProvider).fetchAllItems();
      final time =  await _prefsService.getNotificationTime();

      List<NotificationCandidate> candidates = [];

      final now = DateTime.now();

      for(var item in items) {
        final expiryDate = DateTime.parse(item.expiryDate);

        for (int days in [15,7, 3, 1]) {
          final date = expiryDate.subtract(Duration(days: days));

       final scheduledDate =  DateTime(date.year,date.month,date.day,time.hour,time.minute);
          if (scheduledDate.isAfter(now)) {
            candidates.add(NotificationCandidate(
              id: int.tryParse(item.id) ?? item.hashCode,
              daysBefore: days,
              scheduledDate: scheduledDate,
              itemName: item.name,
            ));
          }
        }
      } candidates.sort((a,b)=>a.scheduledDate.compareTo(b.scheduledDate));

          int limit = candidates.length > 50 ? 50 : candidates.length;
          final topCandidates = candidates.take(limit);
          print("Scheduled notification length = ");

      _flutterLocalNotificationsPlugin.cancelAll();
          for(var candidate in topCandidates){
            print("${candidate.itemName}   ${candidate.scheduledDate}  ${candidate.daysBefore}");
            int notifId = (candidate.id) + candidate.daysBefore;
            String title = candidate.daysBefore == 1
                ? "Urgent: Expiring Tomorrow! 🚨"
                : "Expiring in ${candidate.daysBefore} days ⏳";
           await scheduleNotification(id :notifId,title: title,body: "${candidate.itemName} is Expiring",date: candidate.scheduledDate);

          }



    }catch(e){
      throw "  ";
    }
  }

  Future<void> cancelNotification({required int id})async{
    _flutterLocalNotificationsPlugin.cancel(id);
  }
Future<void> checkPendingNotifications() async {
  final List<PendingNotificationRequest> pendingNotificationRequests =
  await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

  print('Total pending notifications: ${pendingNotificationRequests.length}');

  for (var notification in pendingNotificationRequests) {
    print('ID: ${notification.id}, Title: ${notification.title}, Body: ${notification.body}, Payload: ${notification.payload}, } ');
  }
}
}

class NotificationCandidate{
  final int id;
  final String itemName;
  final DateTime scheduledDate;
  final int daysBefore;

  NotificationCandidate({required this.id, required this.itemName, required this.scheduledDate, required this.daysBefore,});
}

