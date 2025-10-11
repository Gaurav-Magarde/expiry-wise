import 'package:flutter/material.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.itemName, required this.categoriesName});

  final String itemName;
  final String categoriesName;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 1,color: Colors.grey)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 50, width: 8,color: Colors.orange,),
                SizedBox(width: 8,),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(itemName,style: Theme.of(context).textTheme.titleMedium,),
                    Text(categoriesName,style: Theme.of(context).textTheme.labelSmall,),
                  ],
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.more_vert),
              ],
            )
          ],

        ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("23 Oct 2025",style: Theme.of(context).textTheme.bodyLarge!.apply(color: Colors.orange),),
            ],
          ),

      ],),
    );
  }
}
