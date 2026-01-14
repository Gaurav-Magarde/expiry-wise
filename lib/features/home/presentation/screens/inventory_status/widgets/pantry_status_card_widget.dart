import 'dart:math' as math;

import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/features/home/presentation/controllers/home_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PantryStatusContainer extends ConsumerWidget {
  const PantryStatusContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Colors Gradients (Reusing your theme)
    const recentGradient = LinearGradient(
      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    );
    const expiringGradient = LinearGradient(
      colors: [Color(0xFFF6D365), Color(0xFFFDA085)],
    );
    const expiredGradient = LinearGradient(
      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    );

    return InkWell(
      onTap: () {
        context.pushNamed(MYRoute.pantryStatusScreen);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0), // Increased padding slightly for breathability
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                "Pantry Status",
                style: Theme.of(context).textTheme.titleMedium!.apply(
                  color: EColors.primaryDark,
                  fontWeightDelta: 3,
                ),
              ),
              const SizedBox(height: 20),

              // Consumer for Data
              Consumer(
                builder: (_, ref, _) {
                  // 1. Get Data
                  var recent = 0;
                  ref.watch(recentlyItemsProvider).whenData((data) => recent = data.length);

                  var expiring = 0;
                  ref.watch(expiringSoonItemsProvider).whenData((data) => expiring = data.length);

                  var expired = 0;
                  ref.watch(expiredItemsProvider).whenData((data) => expired = data.length);

                  // 2. Calculate Max for Progress Bar scaling
                  int maxVal = math.max(1, math.max(recent, math.max(expiring, expired)));

                  // 3. Render List
                  return Column(
                    children: [
                      _StatusRow(
                        label: "Recent",
                        count: recent,
                        maxVal: maxVal,
                        gradient: recentGradient,
                        iconColor: const Color(0xFF4FACFE),
                      ),
                      const SizedBox(height: 16), // Gap between bars
                      _StatusRow(
                        label: "Expiring Soon",
                        count: expiring,
                        maxVal: maxVal,
                        gradient: expiringGradient,
                        iconColor: const Color(0xFFF6D365),
                      ),
                      const SizedBox(height: 16), // Gap between bars
                      _StatusRow(
                        label: "Expired",
                        count: expired,
                        maxVal: maxVal,
                        gradient: expiredGradient,
                        iconColor: const Color(0xFFFF6B6B),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final int count;
  final int maxVal;
  final Gradient gradient;
  final Color iconColor;

  const _StatusRow({
    required this.label,
    required this.count,
    required this.maxVal,
    required this.gradient,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate width factor (percentage)
    double percentage = count / maxVal;
    // Ensure minimal visibility if count is > 0 but very small compared to max
    if (count > 0 && percentage < 0.05) percentage = 0.05;
    // If count is 0, bar length is 0
    if (count == 0) percentage = 0.0;

    return Column(
      children: [
        // Label Row (Icon + Text + Number)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium!.apply(
                    color: Colors.grey[700],
                    fontWeightDelta: 1,
                  ),
                ),
              ],
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.titleMedium!.apply(
                fontWeightDelta: 3,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Progress Bar
        Container(
          height: 8, // Sleek height
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[100], // The "Empty" Track color
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}