import 'package:expiry_wise_app/features/Profile/presentation/controllers/profile_state_controller.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/validators/validators.dart';
import 'package:expiry_wise_app/core/widgets/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import 'setting_tile.dart';

class ProfileSection extends ConsumerWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(margin: EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 3),
            blurStyle: BlurStyle.outer,
            blurRadius: 7,
            color: Colors.grey.shade200,
          ),
        ],
        border:const  Border(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Consumer(
            builder: (context, ref, child) {
              final name = ref.watch(
                profileStateProvider.select((s) => s.name),
              );
              return SettingTile(
                backgroundColor: Colors.blue.shade50,
                icon: Icons.person,
                iconColor: Colors.blue.shade400,

                title: "Name",
                subTitle: name,
                suffixWidget: IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey.shade700),
                  onPressed: () {
                    TextEditingController textController =
                        TextEditingController();
                    textController.text = name;
                    showDialog(
                      context: context,
                      builder: (c) {
                        return AlertDialog(
                          elevation: 1,
                          title: Text(
                            "Enter new name",
                            style: Theme.of(context).textTheme.titleMedium!
                                .apply(color: EColors.accentPrimary),
                          ),
                          content: TextFormFieldWidget(
                            labelText: 'Name',
                            onChanged: (v) {
                              ref.read(spaceNameProvider.notifier).state = v;
                            },
                            suffixIcon: Icon(Icons.edit_outlined,color:Colors.grey.shade200),
                            controller: textController,
                          ),
                          actions: [
                            SizedBox(
                              width: 400,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Consumer(
                                      builder: (_, ref, __) {
                                        final control = ref.read(
                                          isDialerLoadingProvider.notifier,
                                        );
                                        final isLoading = ref.watch(
                                          isDialerLoadingProvider,
                                        );
                                        return ElevatedButton(
                                          onPressed: () async {
                                            if (isLoading) return;
                                            try {
                                              control.state = true;
                                              final controller = ref.read(
                                                profileStateProvider.notifier,
                                              );
                                              if (!Validators.validateName(
                                                name: textController.text,
                                              )) {
                                                SnackBarService.showError(
                                                  'Please enter the name',
                                                );
                                                return;
                                              }
                                              await controller.changeName(
                                                textController.text,
                                              );
                                              if (context.mounted) {
                                                context.pop();
                                              }
                                            } catch (e) {
                                              SnackBarService.showError(
                                                'name change failed',
                                              );
                                            } finally {
                                              {
                                                control.state = false;
                                              }
                                            }
                                          },
                                          child: isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : Text("Save name"),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Divider(height: 1, color: Colors.grey[300]),
          ),
          Consumer(
            builder: (context, ref, child) {
              final email = ref.watch(
                profileStateProvider.select((s) => s.email),
              );
              return SettingTile(
                icon: Icons.email_rounded,
                iconColor: Colors.orangeAccent.shade400,
                backgroundColor: Colors.orange.shade50,

                title: "Email",
                subTitle: email.isEmpty ? "Add email address" : email,
                suffixWidget: IconButton(
                  icon: Icon(
                    email.isEmpty ? Icons.add_outlined : Icons.copy, color:Colors.grey.shade700
                  ),
                  onPressed: () async {
                    if (email.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: email));
                      SnackBarService.showToast("copied to clipboard");
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
