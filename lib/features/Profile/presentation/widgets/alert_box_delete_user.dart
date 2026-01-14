import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state_controller.dart';
import 'package:expiry_wise_app/routes/presentation/controllers/route_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/loaders/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';

class AlertBoxDeleteUser extends ConsumerWidget {
  const AlertBoxDeleteUser(this.title, this.onPressed, this.message, {super.key});
  final String title;
  final VoidCallback? onPressed;
  final String message;
  @override
  Widget build(BuildContext context, ref) {
    return AlertDialog(
      elevation: 5,
      backgroundColor: Colors.white,
      title: Text(
      title,
        style: Theme.of(context).textTheme.titleMedium!.apply(
          color: Colors.black87,
          fontWeightDelta: 2,
          fontSizeDelta: 2,
        ),
      ),
      content: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.titleMedium!.apply(color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'cancel',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.apply(color: EColors.accentPrimary),
          ),
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(
            'Delete',
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.apply(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
