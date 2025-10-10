import 'package:expiry_wise_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class ElevatedButtonThemes{

   static final ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: EColors.accentPrimary,
        minimumSize: Size(double.infinity,56),
        foregroundColor: EColors.light,
        disabledForegroundColor: Colors.grey,
        maximumSize: Size(double.infinity, 56),
        side: const BorderSide(color: EColors.background),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
    )
  );
}