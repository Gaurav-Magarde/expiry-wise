import 'package:expiry_wise_app/utils/Theme/Widgets/e_navigation_bar_theme.dart';
import 'package:flutter/material.dart';

import 'Widgets/elevated_button_theme.dart';

class EAppTheme{

  static ThemeData lightTheme = ThemeData(

      useMaterial3: true,

      elevatedButtonTheme: ElevatedButtonThemes.lightElevatedButtonTheme,
    navigationBarTheme: ENavigationBarTheme.eLightNavigationBarThemeData
  );
}