import 'package:flutter/material.dart';

import 'Widgets/elevated_button_theme.dart';

class EAppTheme{

  static ThemeData lightTheme = ThemeData(

      useMaterial3: true,

      elevatedButtonTheme: ElevatedButtonThemes.lightElevatedButtonTheme
  );
}