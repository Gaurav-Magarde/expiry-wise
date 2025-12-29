import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/core/utils/helpers/item_date_helper.dart';
import 'package:expiry_wise_app/core/utils/helpers/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen(this.itemId, {super.key});
  final String itemId;
  @override
  Widget build(BuildContext context, ref) {
    final item = ref.watch(itemsStreamProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: Text("Product Detail")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: item.when(
          data: (items) {
            final item = items.firstWhere((i) => i.id == itemId);
            final expiryColor = ItemUtils.getColor(item.expiryDate);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.2,

                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 3),
                            color: Colors.grey.shade200,
                            blurRadius: 15,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                      child: ImageHelper.giveImage(
                        imagePath: item.image,
                        imagePathNetwork: item.imageNetwork,
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(16),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: ItemUtils.getBackgroundColor(item.expiryDate),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ItemUtils.getExpiryIcon(item.expiryDate),
                            SizedBox(width: 8),
                            Text(
                              ItemUtils.getExpiryTime(item.expiryDate),
                              style: Theme.of(context).textTheme.titleMedium!
                                  .apply(fontWeightDelta: 2),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.topLeft,
                                heightFactor: 1,
                                widthFactor: ItemUtils.widthFactor(
                                  item.expiryDate,
                                ),
                                child: Container(
                                  height: 15,
                                  decoration: BoxDecoration(color: expiryColor),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item.expiryDate,
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .apply(fontWeightDelta: 2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 3),
                          blurStyle: BlurStyle.outer,
                          blurRadius: 15,
                          color: Colors.grey.shade200,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.shopping_bag_sharp,
                                  color: EColors.accentPrimary,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Product name ",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .apply(color: EColors.textSecondary),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          textAlign: TextAlign.end,
                                          item.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .apply(
                                                color: EColors.textPrimary,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.date_range,
                                  color: EColors.accentPrimary,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Added Date  ",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .apply(color: EColors.textSecondary),
                                ),
                                Spacer(),
                                Text(
                                  item.addedDate!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(color: EColors.textPrimary),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.menu_outlined,
                                  color: EColors.accentPrimary,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Quantity ",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .apply(color: EColors.textSecondary),
                                ),
                                SizedBox(height: 16),

                                Spacer(),
                                Text(
                                  "${item.quantity.toString()} ${item.unit}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(color: EColors.textPrimary),
                                  overflow: TextOverflow.clip,
                                ),
                              ],
                            ),

                            SizedBox(height: 8),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.category_sharp,
                                  color: EColors.accentPrimary,
                                ),
                                SizedBox(width: 16),
                                Text(
                                  "Category ",
                                  style: Theme.of(context).textTheme.titleSmall!
                                      .apply(color: EColors.textSecondary),
                                ),
                                Spacer(),
                                Text(
                                  item.category,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .apply(color: EColors.textPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFFFDE7,
                      ), // Light yellow sticky note color
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sticky_note_2,
                              color: Colors.orange.shade300,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Note",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .apply(color: EColors.textSecondary),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 24,
                            right: 8,
                            bottom: 8,
                          ),
                          child: Text(
                            item.note,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            );
          },
          error: (e, s) => Text("error"),
          loading: () => CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: AddItemFloatingButton(() {
        context.pushNamed(
          MYRoute.addNewItemScreen,
          queryParameters: {"id": itemId},
        );
      },Icons.edit_sharp,'Edit Item'),
    );
  }
}

