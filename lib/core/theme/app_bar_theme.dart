import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';

class EAppBarTheme{
  static const lightAppBarTheme = AppBarThemeData(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,

    toolbarHeight: 50,
    titleTextStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: EColors.textPrimary),
    actionsPadding: EdgeInsets.symmetric(horizontal: 16),
    // shadowColor: Colors.grey,
    systemOverlayStyle:SystemUiOverlayStyle.light,
    foregroundColor: EColors.textPrimary,

  //   shape: Border(
  // bottom: BorderSide(
  // color: EColors.primary, // Halki grey border
  //   width: 1, // Motai
  // ),
  // ),
  );
}