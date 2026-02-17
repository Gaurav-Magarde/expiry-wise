import 'package:image_picker/image_picker.dart';

import '../../../../../../core/utils/helpers/image_helper.dart';
import '../../../controllers/add_items_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItemImagePickerWidget extends ConsumerWidget {
  const ItemImagePickerWidget({required this.id, super.key});
  final String? id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateController = ref.read(addItemStateProvider(id).notifier);
    return InkWell(
      onTap: () async {
        final file = await ImagePicker().pickImage(
          source: ImageSource.camera,
          imageQuality: 75,
          maxHeight: 600,
          maxWidth: 600,
        );
        if (file != null) {
          stateController.copyWith(image: file.path);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 3),
              color: Colors.grey.shade300,
              blurRadius: 15,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final imagePath = ref.watch(
              addItemStateProvider(id).select((s) => s.image),
            );
            return ImageHelper.giveAddImage(
              imagePath: imagePath,
              imagePathNetwork: '',
            );
          },
        ),
      ),
    );
  }
}
