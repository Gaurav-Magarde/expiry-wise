import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:expiry_wise_app/services/sync_services/local_firebase_syncing.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/src/material/time.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:workmanager/workmanager.dart';

import '../../../../services/workmanager/work_manager_service.dart';


final profileStateProvider =
    NotifierProvider<ProfileStateController, ProfileState>(() {
      return ProfileStateController();
    });

class ProfileStateController extends Notifier<ProfileState> {

  ProfileStateController();

  Future<void> deleteUser() async {
    final link = ref.keepAlive();
    try{
      await ref.read(authControllerProvider.notifier).deleteUser();
      ref.invalidate(currentUserProvider);
    }catch(e){
      SnackBarService.showError('Error : ${e.toString()}');
    }
    link.close();
  }

  Future<void> logOutUser() async {
    final auth = ref.read(authControllerProvider.notifier);
    await auth.logOutUser();
  }

  Future<void> initializeUserData() async {
    final prefs = ref.read(prefsServiceProvider);
    final user = ref.read(currentUserProvider).value!;
    String name = user.name;
    String photoUrl = user.photoUrl;
    String email = user.email;
    final autoSync = await prefs.getAutoSync();
    final notification = await prefs.getIsNotificationOn();
    final time = await prefs.getNotificationTime();
    final itemAlert = await prefs.getItemDeleteAlert();
    final selectedDays = await prefs.getNotificationDays();
    state = ProfileState(
      itemAlert: itemAlert,
      photoUrl: photoUrl,
      name: name,
      email: email,
      autoSync: autoSync,
      notification: notification,
      notificationTime: time,
      selectedDays: selectedDays,
    );
  }

  @override
  ProfileState build() {
    ref.listen(currentUserProvider, (_, __) {
      initializeUserData();
    });
    initializeUserData();
    return ProfileState(
      autoSync: false,
      notification: false,
      photoUrl: '',
      name: '',
      email: '',
      notificationTime: const TimeOfDay(hour: 09, minute: 00),
      selectedDays: [],
      itemAlert: false,
    );
  }


  Future<void> changeName(newName) async {
    try {
      await ref.read(currentUserProvider.notifier).changeName(newName);
      SnackBarService.showSuccess('Name changed successfully');
    } catch (e) {
      SnackBarService.showError('Name changed failed ');
    }
  }


  Future<void> changeNotificationAlert(bool notification) async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      await prefs.setNotificationStatus(notification);
      if(notification) {
        await _reScheduleNotification();
      } else {
        await _cancelNotification();
      }
      state = state.copyWith(notification: notification);
      SnackBarService.showMessage(
        notification ? 'notification alerts on' : 'notification alerts off',
      );
    } catch (e) {
      SnackBarService.showError('Notification alert failed ');
    }
  }


  Future<void> changeItemDeleteAlert(bool delete) async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      await prefs.setItemDeleteAlert(delete);
      state = state.copyWith(itemAlert: delete);
      SnackBarService.showMessage(delete ? 'alerts on' : 'alerts off');
    } catch (e) {
      SnackBarService.showError('alert failed ');
    }
  }

  Future<void> changeAutoSync(bool autoSync) async {
    try {
      await ref.read(currentUserProvider.notifier).toggleAutoSync(autoSync);
      state = state.copyWith(autoSync: autoSync);
      SnackBarService.showMessage(autoSync ? 'Auto sync on' : 'Auto sync off');
    } catch (e) {
      SnackBarService.showError(
        e.toString()
      );
    }
  }

  Future<void> setNotificationTime(TimeOfDay pickedTime) async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      final time = await prefs.setNotificationTime(pickedTime);
      await _reScheduleNotification();
      state = state.copyWith(notificationTime: pickedTime);
      SnackBarService.showMessage('Notification time changed to $time');
    } catch (e) {
      SnackBarService.showError(' Notification Time change failed $e');
    }
  }

  Future<TimeOfDay> getNotificationTime() async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      return await prefs.getNotificationTime();
    } catch (e) {
      SnackBarService.showMessage('Something went wrong');
    }
    return const TimeOfDay(hour: 0, minute: 0);
  }

  Future<void> setNotificationDays(List<int> selectedDays) async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      await prefs.saveNotificationDays(selectedDays);
      state = state.copyWith(selectedDays: selectedDays);
    } catch (e) {
      SnackBarService.showError(' Notification day added failed ');
    }
  }

  Future<List<int>> getNotificationDays() async {
    try {
      final prefs = ref.read(prefsServiceProvider);
      return await prefs.getNotificationDays();
    } catch (e) {
      SnackBarService.showMessage('Something went wrong');
    }
    return [];
  }

  Future<void> manualSync() async {
    try {
      await ref.read(syncProvider).performAutoSync(isAllSync: true).timeout(Duration(seconds: 30));
    } catch (e) {
      SnackBarService.showError(e.toString());
    }
  }

Future<void> _reScheduleNotification() async {
  final time = await getNotificationTime();
  final delay = _calculateInitialDelay(time.hour, time.minute);
  await Workmanager().registerPeriodicTask(
    'notification_task',taskExpiryCheck,initialDelay: delay,
    frequency: const Duration(days: 1),
    constraints: Constraints(
      networkType: NetworkType.notRequired,
      requiresBatteryNotLow: false,
      requiresCharging: false,
      requiresDeviceIdle: false,
      requiresStorageNotLow: false,
    ),
  );
}

Duration _calculateInitialDelay(int targetHour, int targetMinute) {
  final now = DateTime.now();
  final target = DateTime(now.year, now.month, now.day, targetHour, targetMinute);

  // Agar target time nikal chuka hai, toh kal ka time set karein
  if (target.isBefore(now)) {
    return target.add(const Duration(days: 1)).difference(now);
  }
  return target.difference(now);
}

  Future<void> _cancelNotification() async {
   await Workmanager().cancelByUniqueName('notification_task');
  }
}

final isDialerLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final isItemsSyncingProvider = StateProvider.autoDispose<bool>((ref) => false);

