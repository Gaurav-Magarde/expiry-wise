import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state_controller.dart';
import 'package:expiry_wise_app/routes/presentation/controllers/route_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/loaders/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';

class AlertBoxDeleteUser extends ConsumerWidget {
  const AlertBoxDeleteUser({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return AlertDialog(
      elevation: 5,
      backgroundColor: Colors.white,
      title: Text(
        "Delete user?",
        style: Theme.of(context).textTheme.titleMedium!.apply(
          color: Colors.black87,
          fontWeightDelta: 2,
          fontSizeDelta: 2,
        ),
      ),
      content: Text(
        'This action cannot be undone.All the data associated with the user will be permanently deleted.',
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
          onPressed: () async {
            FullScreenLoader.showLoader(
              context,
              'Deleting all spaces & items...',
            );
            try {
              final controller = ref.read(profileStateProvider.notifier);
              await controller.deleteUser();
              if (context.mounted) {
                FullScreenLoader.stopLoader(context);
                context.pop();
              }
              ref.read(screenRedirectProvider).screenRedirect();
            } catch (e) {
              if (context.mounted) {
                FullScreenLoader.stopLoader(context);
                context.pop();
              }

              SnackBarService.showError(
                'Delete user failed.please try again later! $e',
              );
            }
          },
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
