import 'package:expiry_wise_app/features/inventory/data/models/item_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/helpers/item_date_helper.dart';
import 'package:expiry_wise_app/core/utils/helpers/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ItemCard extends ConsumerWidget {
  const ItemCard({
    super.key,
    this.isExpired = false,
    required this.item,
    this.isAdded = false,
  });

  final ItemModel item;
  final bool isAdded;
  final bool isExpired;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor =  ItemUtils.getColor(item.expiryDate);

    return InkWell(
      onTap: () {
        context.pushNamed(
          MYRoute.itemDetailScreen,
          pathParameters: {'id': item.id},
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // Professional White Background
          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(0, 2),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. LEFT SIDE: Image Container (Gallery Placeholder Style)
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 70,
                    width: 70,

                    decoration: BoxDecoration(
                      color: Colors
                          .grey
                          .shade200,
                      boxShadow: [
                        BoxShadow(
                          offset: Offset(0, 0),
                          color: Colors.grey,
                          blurRadius: 10,
                          blurStyle: BlurStyle.outer
                        )
                      ]
                    ), // Light Grey Background for placeholder feel
                    child: ImageHelper.giveProductImage(
                      imagePath: item.image,
                      imagePathNetwork: item.imageNetwork,
                      category: item.category
                    ), // Original Image
                  ),
                ),



                // Progress Bar (Thinner & Aligned right)

              ],
            ),

            const SizedBox(width: 16),

            // 2. RIGHT SIDE: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row A: Name + Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Menu Icon (Compact)
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: PopupMenuButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onSelected: (val) {
                            if (val == 'delete') {
                              ref
                                  .read(itemControllerProvider)
                                  .deleteItem(item: item);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row B: Category • Quantity (Subtitle)
                  Text(
                    "${item.category} • ${item.quantity} ${item.unit}",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),


                  // Row C: Added Date + Expiry Status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left: Added Date
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.start,
                      //   children: [
                      //     Expanded(
                      //       child: Text(
                      //         ItemUtils.getAddedTime(item.addedDate ?? ""),
                      //         style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      //           color: Colors.grey.shade600,
                      //           fontSize: 11,
                      //         ),
                      //         textAlign: TextAlign.left,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // Right: Expiry Info & Bar



                               Text(
                                  ItemUtils.getExpiryTime(item.expiryDate),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  textAlign: TextAlign.right,
                                ),

                    ],
                  ),
                  const  SizedBox(height: 8,),
                   if(item.note.isNotEmpty )Text(
                   '${item.note} ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],

              ),
            ),
          ],
        ),
      ),
    );
  }
}
