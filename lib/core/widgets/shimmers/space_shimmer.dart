import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class SpaceCardShimmer extends ConsumerWidget {
  const SpaceCardShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shimmer(

      child: Container(
        height: 150,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(width: 3, color: Colors.grey[100]!),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              spreadRadius: 0,
              color: Colors.grey[500]!,
              offset: Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Shimmer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],

                            borderRadius: BorderRadius.circular(16),

                    ),
                    width: 72,
                    height: 20,
                  ),
                ),
                Shimmer(
                  child: Container(
                    width: 16,
                    height: 32,
                    decoration: BoxDecoration(
                    color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: [
                        Shimmer(
                          child: Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                            color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),

                            ),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Shimmer(
                          child: Container(
                            width: 72,
                            height: 16,
                            decoration: BoxDecoration(
                            color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),

                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(),
                    child: Column(
                      children: [
                        Shimmer(
                          child: Container(
                            width: 36,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(16),

                            ),
                          ),
                        ),
                        const SizedBox(height: 8,),
                        Shimmer(
                          child: Container(
                            width: 64,
                            height: 16,
                            decoration: BoxDecoration(
                            color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),

                            ),
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
