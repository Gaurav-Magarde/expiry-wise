import 'package:expiry_wise_app/core/widgets/shimmers/product_loading_listview.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/item_card.dart';
import 'package:flutter/material.dart';

import '../../../../../inventory/domain/item_model.dart';

class SelectedItemsCardWidget extends StatelessWidget {

  final Widget? onEmpty;
  final bool isShimmer;
  const SelectedItemsCardWidget({
    super.key,
     required this.list, this.onEmpty , this.isShimmer = false
  });

  final List<ItemModel> list;

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white
      ),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child:
            list.isEmpty && !isShimmer ? onEmpty :
            Center(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 0);
                },
                itemCount: isShimmer? 6 : list.length,
                scrollDirection: Axis.vertical,
                physics:const  NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                   if(isShimmer ) return const ItemCardShimmer();
                  final item = list[index];
                  return ItemCard(
                    isExpired: false,
                    item: item,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
