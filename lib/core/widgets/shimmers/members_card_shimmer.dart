import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MembersCardShimmer extends ConsumerWidget{
  const MembersCardShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   return Shimmer(child: Container(
       height: 80,
       // width: 80,
       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
       decoration: BoxDecoration(
         border: Border.all(width: 1, color: Colors.grey[200]!),
         boxShadow: [
           BoxShadow(
               offset: Offset(0,1.5),
               spreadRadius: 2,
               color: Colors.grey[400]!
           ),

         ],
         borderRadius: BorderRadius.circular(16),
         color: Colors.grey[200],
       )
       ,child:
   Row(
     mainAxisAlignment: MainAxisAlignment.start,
     children: [
        Shimmer(child: const CircleAvatar(radius: 25,)),
       const SizedBox(width: 32,),
       Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Shimmer(
             child: Container(
               width: 64,
               height: 14,
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(8),
               ),
             ),
           ),
           const SizedBox(height: 8,),
           Shimmer(
             child: Container(
               width: 32,
               height: 12,
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(4),
               ),
             ),
           )
         ],
       ),
       const Spacer(),
       Shimmer(
         child: Container(
           width: 16,
           height: 32,
           decoration: BoxDecoration(
             color: Colors.grey[300],
             borderRadius: BorderRadius.circular(14),
           ),
         ),
       )
     ],

   ),
   ));
  }
  
}