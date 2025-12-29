import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ElevatedButtonThemes{

   static final ElevatedButtonThemeData lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 5,
      backgroundColor: EColors.primary,
        minimumSize: Size(double.infinity,56),

        foregroundColor: Colors.white,
        disabledForegroundColor: Colors.grey,
        maximumSize: Size(double.infinity, 56),
        side: const BorderSide(color: EColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        textStyle: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))
    )
  );
}