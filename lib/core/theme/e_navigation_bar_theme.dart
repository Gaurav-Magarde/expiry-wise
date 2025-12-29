import 'package:flutter/material.dart';

import 'colors.dart';

class ENavigationBarTheme{

  static NavigationBarThemeData eLightNavigationBarThemeData = NavigationBarThemeData(
    indicatorColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      // If the icon is selected, use the primary color. Otherwise, use grey.
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(color: EColors.primary,fontSize: 16);
      } else {
        return const TextStyle(color: Colors.grey);
      }
    })
  );
}