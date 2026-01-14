import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return ClipPath(
      // clipper: GreenHeaderClipper(),
      child: Consumer(
        builder: (_, ref, __) {
          final space = ref.watch(currentSpaceProvider).value?.name;

          return Container(
            height: space == null ? 100 : 150,
            color: Colors.white, // The dark green color
            // Fixed height for the header
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Row for Greeting + Profile
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (_, ref, __) {
                              String greet =
                                  ref.watch(currentUserProvider).value?.name ??
                                  '';
                              return Expanded(
                                child: Text(
                                  'Hi, $greet',
                                  style: Theme.of(context).textTheme.titleLarge!
                                      .apply(
                                        color: EColors.textPrimary,
                                        fontWeightDelta: 3,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      if (space != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: EColors.textSecondary,
                              size: 17,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                space,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .apply(color: EColors.textSecondary),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 80,
                        width: 60,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: EColors.accentPrimary,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 3),
                              color: Colors.grey[100]!,
                              blurRadius: 7,
                              blurStyle: BlurStyle.outer,
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () async {
                            context.pushNamed(
                              MYRoute.addNewItemScreen,
                              queryParameters: {'id': null},
                            );
                            context.pushNamed(MYRoute.barcodeScanScreen);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                color: Colors.white,
                                Icons.qr_code_scanner_outlined,
                                size: 30,
                              ),
                              Text(
                                'scan',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .apply(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Top Title

                // const SizedBox(height: 8), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  // Best Practice: Define size so it works in Scaffold.appBar
  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class GreenHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    final width = size.width;
    final height = size.height;

    // // Start from top-left
    // path.lineTo(0, size.height - 30); // Go down, leaving 30px for the curve
    //
    // // Create a quadratic bezier curve
    // // Control point: bottom-leftish (pulls the curve down)
    // // End point: bottom-right
    // var firstControlPoint = Offset(size.width / 4, size.height);
    // var firstEndPoint = Offset(size.width, size.height - 40);
    //
    // // Draw the curve
    // path.quadraticBezierTo(
    //     firstControlPoint.dx,
    //     firstControlPoint.dy,
    //     firstEndPoint.dx,
    //     firstEndPoint.dy
    // );
    //
    // // Close the path
    // path.lineTo(size.width, 0); // Go to top-right
    // path.close(); // Go back to top-left

    path.lineTo(0, height - 15);

    path.quadraticBezierTo(15, height, 40, height);

    path.lineTo(width - 40, height);
    path.quadraticBezierTo(width - 15, height, width, height - 15);

    path.lineTo(width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
