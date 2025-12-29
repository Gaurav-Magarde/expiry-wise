import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/model/space_model.dart';
import 'alert_dialog_space.dart';

class PopupButtonSpace extends ConsumerWidget {
  const PopupButtonSpace({
    super.key,
    required this.space,
  });

  final SpaceModel space;

  @override
  Widget build(BuildContext context,ref) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton(
        icon: Icon(
          Icons.more_horiz,
          color: Colors.grey.shade600,
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        elevation: 2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        onSelected: (v) async {
          if (v == 'delete') {
            final controller =
            ref.read(spaceControllerProvider.notifier);
            final canDelete = await controller.canSpaceDeleted(
                spaceId: space.id);
            if (canDelete) {
              if (context.mounted) {
                SnackBarService.showMessage(
                    'Default space cannot be deleted');
              }
              return;
            }
            await controller.deleteSpace(spaceId: space.id);
          } else if (v == 'member') {
            final controller =
            ref.read(currentSpaceProvider.notifier);
            await controller.changeCurrentSpace(space: space);
            if (context.mounted) {
              context.pushNamed(MYRoute.memberScreen);
            }
          } else if (v == 'edit') {
            showDialog(
              context: context,
              builder: (c) {
                return AlertDialogSpaceCard(space: space);
              },
            );
          } else if (v == 'exit') {
            final controller =
            ref.read(spaceControllerProvider.notifier);
            await controller.removeMemberFromSpace(spaceId: space.id);
            ref.invalidate(spaceControllerProvider);
          }
        },
        itemBuilder: (context) => <PopupMenuItem>[
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 20, color: Colors.black87),
                SizedBox(width: 8),
                Text("Rename"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'member',
            child: Row(
              children: [
                Icon(Icons.people_outline, size: 20, color: Colors.black87),
                SizedBox(width: 8),
                Text("Members"),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text("Delete", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'exit',
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text("Leave Space", style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
