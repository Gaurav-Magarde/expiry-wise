import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class AddItemFloatingButton extends ConsumerWidget {
  const AddItemFloatingButton(this.onTap, this.iconData, this.label, {super.key});

  final VoidCallback onTap;
  final IconData iconData;
  final String label;
  @override
  Widget build(BuildContext context,ref) {
    return InkWell(

      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        padding: EdgeInsets.symmetric(vertical: 12,horizontal: 16),
        decoration: BoxDecoration(
            color: EColors.primary,
            borderRadius: BorderRadius.circular(24)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: Colors.white),
            SizedBox(width: 8,),
            Text(label,style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.white),)
          ],),
      ),
    );
  }
}
