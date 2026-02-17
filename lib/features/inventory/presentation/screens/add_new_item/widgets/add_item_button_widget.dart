import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_items_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomAddItemButtonWidget extends ConsumerWidget {
  const BottomAddItemButtonWidget({
    super.key,
    required this.onPressed,
    required this.child,
  });

  final Widget child;
  final Function() onPressed;


  @override
  Widget build(BuildContext context,ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(elevation: 10),
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
