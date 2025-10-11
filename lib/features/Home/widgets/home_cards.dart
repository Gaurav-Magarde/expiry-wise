import 'package:expiry_wise_app/features/Home/widgets/item_card.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';

class HomeCards extends StatelessWidget {
  const HomeCards({super.key, required this.sectionHeading, required this.itemName, required this.categoriesName});

  final String sectionHeading;
  final String itemName;
  final String categoriesName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(sectionHeading,style:TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: EColors.primary),),
            TextButton(onPressed: () {  },
            child: Text("view all",style: Theme.of(context).textTheme.labelLarge,))
          ],
        ),
        ItemCard(itemName:itemName,categoriesName: categoriesName,)
      ],
    );
    
  }
}
