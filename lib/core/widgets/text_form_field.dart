import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget{
  final String? hint;
  final String? labelText;
  final Widget?  prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? textInputType;

  final TextEditingController? controller;
  final ValueChanged<String>?  onChanged;

  const TextFormFieldWidget({super.key, this.hint, this.prefixIcon, this.suffixIcon, this.controller, this.onChanged, this.labelText, this.textInputType});



  @override
  Widget build(BuildContext context) {
    return
      ConstrainedBox( constraints: BoxConstraints(maxHeight: 60),

        child: TextFormField(maxLines: 1,minLines: 1,
        keyboardType: textInputType??TextInputType.name,
        onChanged: onChanged,
        controller: controller,
        decoration: InputDecoration(

          filled: true,
          fillColor: Colors.white,
          labelText: labelText??'',
          labelStyle: TextStyle(color: Colors.grey[700],overflow:TextOverflow.ellipsis, ),
          floatingLabelStyle: TextStyle(color: Color(0xFF673AB7)),
          hint: Text(hint??labelText??'',style: Theme.of(context).textTheme.bodyLarge,overflow: TextOverflow.ellipsis,),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 2,color: Colors.grey)
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 3,color: EColors.accentPrimary)
          ),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(width: 2,color: Colors.redAccent)
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,

        ),
        style: Theme.of(context).textTheme.titleMedium
            ),
      );
  }}

