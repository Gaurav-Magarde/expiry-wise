import 'package:expiry_wise_app/core/theme/app_bar_theme.dart';
import 'package:expiry_wise_app/core/theme/e_navigation_bar_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'elevated_button_theme.dart';

class EAppTheme{

  static ThemeData lightTheme = ThemeData(

      useMaterial3: true,

      elevatedButtonTheme: ElevatedButtonThemes.lightElevatedButtonTheme,
    navigationBarTheme: ENavigationBarTheme.eLightNavigationBarThemeData,
    appBarTheme: EAppBarTheme.lightAppBarTheme,
    textTheme: GoogleFonts.poppinsTextTheme(

    )
  );
}