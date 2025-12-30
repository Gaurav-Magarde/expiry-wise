import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/core/utils/validators/validators.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/text_form_field.dart';
import '../../data/model/space_model.dart';

class AlertDialogSpaceCard extends ConsumerWidget {
  const AlertDialogSpaceCard({
    super.key,
    required this.space,
  });

  final SpaceModel space;

  @override
  Widget build(BuildContext context,ref) {
    return AlertDialog(
      backgroundColor: Colors.white,
      elevation: 1,
      title: Text(
        "Change Name",
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .apply(color: EColors.dark),
      ),
      content: TextFormFieldWidget(
        labelText: 'Space Name',
        onChanged: (v) {
          ref.read(spaceNameProvider.notifier).state = v;
        },
        prefixIcon: Icon(
          Icons.edit_outlined,
          color: EColors.accentPrimary,
        ),
        hint: "eg. Home Space",
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
                        addNewSpaceLoadingProvider.notifier);
                    final isLoading = ref.watch(
                        addNewSpaceLoadingProvider);
                    return ElevatedButton(
                      onPressed: () async {
                        control.state = true;
                        final isSpaceCreating = ref.read(
                            isSpaceCreatingProvider);
                        if (isSpaceCreating) return;
                        final spaceController = ref.read(
                            isSpaceCreatingProvider.notifier);
                        try {
                          spaceController.state = true;
                          final controller = ref.read(
                              spaceControllerProvider.notifier);
                          final text = ref.read(
                              spaceNameProvider);
                          final isNameOk =
                          Validators.validateName(
                              name: text);
                          if (!isNameOk) {
                            SnackBarService.showError(
                                'Please Enter space name');
                            return;
                          }
                          await controller.changeSpaceName(
                              space: space);
                          if (context.mounted) context.pop();
                        } catch (e) {
                          SnackBarService.showError(
                              'something went wrong');
                        } finally {
                          spaceController.state = false;
                          control.state = false;
                        }
                      },
                      child: isLoading
                          ?const  CircularProgressIndicator(
                        color: Colors.white,
                      )
                          :const  Text("Save"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}