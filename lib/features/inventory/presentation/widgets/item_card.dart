import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Member/data/models/member_model.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/helpers/item_date_helper.dart';
import 'package:expiry_wise_app/core/utils/helpers/image_helper.dart';
import 'package:expiry_wise_app/services/local_db/prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/colors.dart';
import '../../../Profile/presentation/widgets/alert_box_delete_user.dart';

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
    final statusColor = ItemUtils.getColor(item.expiryDate??'');
    final key = Key(item.id);
    return InkWell(
      onTap: () {
        context.pushNamed(
          MYRoute.itemDetailScreen,
          pathParameters: {'id': item.id},
        );
      },
      child: Dismissible(
        key: key,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          color: item.finished==0 ? Colors.green : EColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              item.finished==0 ? Icon(Icons.check_circle, color: Colors.white):Icon(Icons.restore_outlined, color: Colors.white),
              SizedBox(width: 8),
              Text(
                item.finished==0? "Finished" : "Re-Stock",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          color: Colors.red,
          child: Icon(Icons.delete, color: Colors.white),
        ),

        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            final newItem = ItemModel(
              price: item.price,
              isExpenseLinked: item.isExpenseLinked,
              id: item.id,
              finished: item.finished==0?1:0,
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
            return await ref
                .read(itemControllerProvider.notifier)
                .insertItemByItemModel(item: newItem, prev: item);
          } else {
            final current = ref.read(currentSpaceProfileProvider);
            if (current == MemberRole.member) {
              SnackBarService.showMessage('only Admin can delete items');
              return false;
            }
            final isAlert = await ref.read(prefsServiceProvider).getItemDeleteAlert();
            if( isAlert){
              var isDeleted = false;
              await showDialog(context: context, builder: (context){

                return AlertBoxDeleteUser("Delete confirmation", () async {
                   isDeleted = await ref.read(itemControllerProvider.notifier).deleteItem(item: item);
                if(context.mounted)context.pop();
                }, "Item cannot be restored once deleted.Are you want to delete permanently");
              });
              return isDeleted;
            }else {
              return ref.read(itemControllerProvider.notifier).deleteItem(item: item);
            }
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 4, ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
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
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 70,
                      width: 70,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0),
                            color: Colors.grey,
                            blurRadius: 10,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ), // Light Grey Background for placeholder feel
                      child: ImageHelper.giveProductImage(
                        imagePath: item.image,
                        imagePathNetwork: item.imageNetwork,
                        category: item.category,
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
                            onSelected: (val) async {
                              if (val == 'delete') {
                                final current = ref.read(
                                  currentSpaceProfileProvider,
                                );
                                if (current == MemberRole.member) {
                                  SnackBarService.showMessage(
                                    'only Admin can delete items',
                                  );
                                  return;
                                }
                                ref
                                    .read(itemControllerProvider.notifier)
                                    .deleteItem(item: item);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
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
                        item.finished == 0
                            ? item.expiryDate==null || item.expiryDate!.isEmpty ?  Center(): Text(
                                ItemUtils.getExpiryTime(item.expiryDate??""),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.right,
                              )
                            : InkWell(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.5),
                                      width: 1,
                                    ), // Optional Border
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Finished",
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (item.note.isNotEmpty)
                      Text(
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
      ),
    );
  }
}
