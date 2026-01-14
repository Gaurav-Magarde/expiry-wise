import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NoSpaceHomeScreenWidget extends ConsumerWidget{
  const NoSpaceHomeScreenWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/images/no_space_found.webp'),
        const SizedBox(height: 16,),
        Text('No space found!',style: Theme.of(context).textTheme.headlineSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 3),),
        const SizedBox(height: 16,),
        Text('Create a space to begin organizing items',style: Theme.of(context).textTheme.titleSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 2),),
        const SizedBox(height: 16,),
        ElevatedButton(onPressed: (){
          context.pushNamed(MYRoute.spaceScreen);
        }, child: Text('create new space'))
      ],
    );

  }

}