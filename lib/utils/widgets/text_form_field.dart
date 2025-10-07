import 'package:expiry_wise_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget{
  final String? hint;
  final Widget?  prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const TextFormFieldWidget({super.key, this.hint, this.prefixIcon, this.suffixIcon, this.controller});



  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        hint: Text(hint??""),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 2,color: Colors.grey)
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 3,color: EColors.accentPrimary)
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 2,color: Colors.redAccent)
        ),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon
      ),
      style: TextStyle(
        backgroundColor: Colors.white70 ,
        color: Colors.black,

      )
    );
  }}

