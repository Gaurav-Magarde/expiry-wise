import 'package:expiry_wise_app/core/widgets/shimmers/space_shimmer.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/Space/presentation/widgets/popup_menu_space.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/model/space_model.dart';

class SpaceCard extends ConsumerWidget {
  const SpaceCard(this.space, {super.key});
  final SpaceModel space;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected =
        ref.watch(currentSpaceProvider.select((S) => S.value?.id)) == space.id;
    return Consumer(
      builder: (_, ref, __) {
        final async = ref.watch(spaceCardProvider(space.id));
        return async.when(
          data: (u) {
            return InkWell(
              onTap: () async {
                final currentSpaceId = ref.watch(
                  currentSpaceProvider.select((S) => S.value),
                );
                final selectedSpace = space.id;
                if (currentSpaceId?.id == selectedSpace) return;
                final controller = ref.read(spaceControllerProvider.notifier);
                await controller.changeSpace(space: space);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? EColors.primary.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                  border: isSelected
                      ? Border.all(color: EColors.primary, width: 1.5)
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? EColors.primary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isSelected ? Icons.check_circle : Icons.grid_view_rounded,
                              color: isSelected ? EColors.primary : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  space.name,
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (isSelected)
                                  Text(
                                    "Active Space",
                                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                      color: EColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupButtonSpace(space: space),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(context, Icons.inventory_2_outlined,
                                "${u.items} Items"),
                            Container(height: 24, width: 1, color: Colors.grey.shade300),
                            _buildStatItem(context, Icons.people_outline,
                                "${u.member} Members"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          error: (e, s) => const SizedBox(),
          loading: () => const SpaceCardShimmer(),
        );
      },
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

