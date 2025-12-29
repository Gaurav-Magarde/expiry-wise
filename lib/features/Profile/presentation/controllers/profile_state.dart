import 'package:flutter/material.dart';

class ProfileState {
  final String name;
  final String email;
  final String photoUrl;
  final TimeOfDay notificationTime;
  final bool autoSync;
  final bool notification;
  ProfileState( {
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
    bool? autoSync,
    bool? notification,
    TimeOfDay? notificationTime,
  }) {
    return ProfileState(
      photoUrl: photoUrl ?? this.photoUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      notification:notification?? this.notification,
      autoSync: autoSync?? this.autoSync,
      notificationTime:  notificationTime?? this.notificationTime,
    );
  }
}
