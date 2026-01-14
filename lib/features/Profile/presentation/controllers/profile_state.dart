import 'package:flutter/material.dart';

class ProfileState {
  final String name;
  final String email;
  final String photoUrl;
  final TimeOfDay notificationTime;
  final bool autoSync;
  final List<int> selectedDays;
  final bool notification;
  final bool itemAlert;
  ProfileState(  {
    required this.itemAlert,
    required this.selectedDays,
    required this.notificationTime,
    required this.autoSync,
    required this.notification,
    required this.photoUrl,
    required this.name,
    required this.email,
  });

  ProfileState copyWith({
    String? name,
    String? email,
    String? photoUrl,
    List<int>? selectedDays,
    bool? autoSync,
    bool? notification,
    bool? itemAlert,
    TimeOfDay? notificationTime,
  }) {
    return ProfileState(
      itemAlert: itemAlert??this.itemAlert,
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      notification:notification?? this.notification,
      autoSync: autoSync?? this.autoSync,
      notificationTime:  notificationTime?? this.notificationTime, selectedDays: selectedDays??this.selectedDays,
    );
  }
}
