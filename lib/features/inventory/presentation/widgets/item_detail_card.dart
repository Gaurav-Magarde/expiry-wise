
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/item_model.dart';
class ItemDetailCard extends StatelessWidget {
  const ItemDetailCard({
    super.key,
    required this.item,
  });

  final ItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:const  EdgeInsets.symmetric(horizontal: 16),
      padding:const  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  const  SizedBox(width: 16),
                  Text(
                    "Product name ",
                    style: Theme.of(context).textTheme.titleSmall!
                        .apply(color: EColors.textSecondary),
                  ),
                  const  SizedBox(width: 16),
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
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.date_range,
                    color: EColors.accentPrimary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Added Date  ",
                    style: Theme.of(context).textTheme.titleSmall!
                        .apply(color: EColors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    item.addedDate!,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .apply(color: EColors.textPrimary),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.menu_outlined,
                    color: EColors.accentPrimary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Quantity ",
                    style: Theme.of(context).textTheme.titleSmall!
                        .apply(color: EColors.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  const Spacer(),
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

              const SizedBox(height: 8),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.category_sharp,
                    color: EColors.accentPrimary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Category ",
                    style: Theme.of(context).textTheme.titleSmall!
                        .apply(color: EColors.textSecondary),
                  ),
                  const Spacer(),
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
    );
  }
}