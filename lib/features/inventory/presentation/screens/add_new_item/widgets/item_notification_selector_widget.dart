import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/widgets/chips/notification_day_chips.dart';
import '../../../controllers/add_items_controller.dart';

class ItemNotificationSelectorWidget extends ConsumerWidget {
  const ItemNotificationSelectorWidget({super.key, required this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final AddItemController stateController = ref.read(provider.notifier);
    return Consumer(
      builder: (_, ref, _) {
        final selectedChips = ref.watch(provider.select((s) => s.selectedDays));
        final isExpiry = ref.watch(provider.select((s) => s.expiryDate));
        return isExpiry == null || isExpiry.isEmpty
            ? Center()
            : ExpansionTile(
          iconColor: Colors.grey,
          collapsedIconColor: EColors.primaryDark,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: EColors.accentPrimary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Notification Settings',
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          children: [
            NotificationDayChips(
              selectedDays: selectedChips,
              onSelectedChanged: (list) {
                stateController.copyWith(selectedDays: list);
              },
            ),
          ],
        );
      },
    );
  }
}
