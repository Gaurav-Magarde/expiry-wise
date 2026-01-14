import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer_animation/shimmer_animation.dart';



class ItemCardShimmer extends ConsumerWidget{
  const ItemCardShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shimmer(
      interval: Duration(seconds: 2),
      // color: Colors.grey,
      direction: ShimmerDirection.fromLTRB(),

      child: Container(

        height: 170,
        width: 300,
        decoration: BoxDecoration(
            color:  Colors.grey[200],
            border: Border.all(width: 1, color:  Colors.grey[400]!),
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(width: 1,),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[400]!,
                blurRadius: 7,
                offset: Offset(0, 3),

              ),
        ]
      ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0,horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Shimmer(child: CircleAvatar(radius: 30,backgroundColor: Colors.grey.shade300,)),
                  const SizedBox(width: 32,)
                  ,Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer(child:Container(color: Colors.grey[300],width: 64,height: 14,)),
                      SizedBox(height: 4,),
                      Shimmer(child:Container(color: Colors.grey[300],width: 48,height: 10,)),
                    ],
                  ),
                  const Spacer(),
                  Shimmer(child:Container(color: Colors.grey[200],width: 64,height: 16,)),

                ],
              ),
              const SizedBox(height: 16,),
              Shimmer(child:Container(color: Colors.grey[300],width: 64,height: 10,)),

              const SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Shimmer(child:Container(color: Colors.grey[300],width: 48,height: 16,)),
                Shimmer(child:Container(color: Colors.grey[300],width: 72,height: 16,)),


              ],
            ),
              const SizedBox(height: 8,),
              Shimmer(child:Container(color: Colors.grey[300],width: double.infinity,height: 12,)),

            ],
          ),
        ),
      ),
    );
  }
}
