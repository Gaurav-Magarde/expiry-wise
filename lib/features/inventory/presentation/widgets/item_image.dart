import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_item_controllers/add_items_controller.dart';
import 'package:expiry_wise_app/core/utils/helpers/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ItemImage extends ConsumerWidget {
  const ItemImage(this.id, {super.key, this.showCamera = true});
  final bool showCamera;
  final String? id;
  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height*0.2,
        width: MediaQuery.of(context).size.width*0.8,
        decoration: BoxDecoration(color: Colors.white),
        child: InkWell(
          onTap: () async {
            final XFile? photo = await ImagePicker().pickImage(
              source: ImageSource.camera,
            );

            if (photo != null) {
              ref.read(addItemStateProvider(id).notifier)
                  .copyWith(image: photo.path);
            }
          },
          child: Consumer(
            builder: (_, ref, __) {
              final selectedImg = ref.watch(
                addItemStateProvider(id).select((S) => S.image),
              );
              final selectedImgNetwork = ref.watch(
                addItemStateProvider(id).select((S) => S.image),
              );
              return Container(
                clipBehavior: Clip.hardEdge,

                decoration: BoxDecoration(color: Colors.white),
                child: ImageHelper.giveImage(imagePath: selectedImg,imagePathNetwork: selectedImgNetwork)
              );
            },
          ),
        ),
      ),
    );
  }
}
