import 'package:expiry_wise_app/core/widgets/shimmers/product_loading_listview.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/item_card.dart';
import 'package:flutter/material.dart';

import '../../data/models/item_model.dart';

class HomeCards extends StatelessWidget {

  final Widget? onEmpty;
  final bool isShimmer;
  const HomeCards({
    super.key,
     required this.list, this.onEmpty , this.isShimmer = false
  });

  final List<ItemModel> list;

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
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
                  return SizedBox(height: 8,);
                  // Text("Nothing");
                },
                itemCount: isShimmer? 6 : list.length,
                scrollDirection: Axis.vertical,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                   if(isShimmer ) return ItemCardShimmer();
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
