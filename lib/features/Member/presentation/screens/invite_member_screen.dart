import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class InviteMemberScreen extends ConsumerWidget {
  const InviteMemberScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Invite Members")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const  SizedBox(height: 50),

              Container(
                height: height*.4,
                decoration: BoxDecoration(color: Colors.transparent),
                child: Image.asset(
                  "assets/images/invite_member.webp",
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: width * .7,
                child: Text(
                  textAlign: TextAlign.center,
                  "Share this code with people want to invite",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              SizedBox(height: 16),

              Consumer(
                builder: (_, ref, __) {
                  final currentSpaceId = ref.watch(currentSpaceProvider);
                  return currentSpaceId.when(
                    data: (id) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            Container(
                              height: 70,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: id == null
                                        ? Text(
                                            'No space found',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .apply(
                                                  color: EColors.accentPrimary,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : Text(
                                            id.id,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () async {
                                if (id != null) {
                                  await Clipboard.setData(
                                    ClipboardData(text: id.id),
                                  );
                                  SnackBarService.showToast(
                                    'Text copied to clipboard',
                                  );
                                } else {
                                  SnackBarService.showError(
                                    'Please add space to invite member',
                                  );
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.copy, color: EColors.accentPrimary),
                                  const  SizedBox(width: 8),
                                  Text(
                                    "Copy code",
                                    style: Theme.of(context).textTheme.titleSmall!
                                        .apply(color: EColors.primaryDark),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      );
                    },
                    error: (e, s) => Text(
                      "No Space found",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    loading: () => const CircularProgressIndicator(),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 24,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    context.pushNamed(MYRoute.joinSpaceScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [const Text("Join new Space")],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
