import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller/item_controller.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/item_detail/widgets/item_detail_card_widget.dart';
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
      appBar: AppBar(title: const Text("Product Detail")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
        child: item.when(
          data: (items) {
            final item = items.firstWhere((i) => i.id == itemId);
    final isFinished = item.finished==0;
            final expiryColor = ItemUtils.getColor(item.expiryDate??DateTime(2099).toString());
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

                  const SizedBox(height: 16),
                   Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isFinished ? ItemUtils.getBackgroundColor(item.expiryDate??'') : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: isFinished ? item.expiryDate==null || item.expiryDate!.isEmpty ? Center()  :Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ItemUtils.getExpiryIcon(item.expiryDate!),
                            const SizedBox(width: 8),
                            Text(
                              ItemUtils.getExpiryTime(item.expiryDate!),
                              style: Theme.of(context).textTheme.titleMedium!
                                  .apply(fontWeightDelta: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                                  item.expiryDate??'',
                                ),
                                child: Container(
                                  height: 15,
                                  decoration: BoxDecoration(color: expiryColor),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item.expiryDate??"",
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .apply(fontWeightDelta: 2),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ) : Row(
                      children: [
                        Icon(Icons.check_box,color: Colors.green.shade900,),
                        SizedBox(width: 16,),
                        Text("Finished",style: Theme.of(context).textTheme.titleMedium!.apply(color: Colors.green.shade900,fontWeightDelta: 2),),
                      ],
                    ),
                  ) ,
                  const SizedBox(height: 16),
                  ItemDetailCard(item: item),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            const SizedBox(width: 8),
                            Text(
                              "Note",
                              style: Theme.of(context).textTheme.titleMedium!
                                  .apply(color: EColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final newItem = ItemModel(
                          price: item.price,
                          isExpenseLinked:item.isExpenseLinked,
                          id: item.id,
                          finished: item.finished == 0 ? 1 : 0,
                          image: item.image,
                          imageNetwork: item.imageNetwork,
                          userId: item.userId,
                          spaceId: item.spaceId,
                          name: item.name,
                          expiryDate: item.expiryDate,
                          updatedAt: item.updatedAt,
                          category: item.category,
                          quantity: item.quantity,
                          note: item.note,
                          unit: item.unit,
                          notifyConfig: item.notifyConfig,
                          addedDate: item.addedDate,
                        );
                        await ref
                            .read(itemControllerProvider)
                            .insertItemFromFirebase(
                              item: newItem,
                              prev: item,
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.finished == 0
                            ? Colors.green
                            : EColors.primary,
                        side:BorderSide(color: Colors.green)
                      ),
                      child: Text(
                        item.finished == 0
                            ? "Mark as Finished"
                            : "Re-store to inventory",
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
          error: (e, s) => const Text("error"),
          loading: () => const CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: AddItemFloatingButton(
        () {
          context.pushNamed(
            MYRoute.addNewItemScreen,
            queryParameters: {"id": itemId},
          );
        },
        Icons.edit_sharp,
        'Edit Item',
      ),
    );
  }
}
