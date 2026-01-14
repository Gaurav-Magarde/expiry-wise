import 'package:expiry_wise_app/features/Space/presentation/controllers/space_controller.dart';
import 'package:expiry_wise_app/features/Space/presentation/widgets/space_card.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/shimmers/space_shimmer.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/text_form_field.dart';
import '../widgets/AddSpaceButton.dart';
class AllSpacesScreens extends ConsumerWidget {
  const AllSpacesScreens({super.key});



  @override
  Widget build(BuildContext context,ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextButton(onPressed: (){}, child: Text("Add",style: Theme.of(context).textTheme.titleLarge,)),
          // )
        ],
        title:const  Text("Spaces"),
      ),
      body: Padding(
        padding: const EdgeInsets.all( 8.0),
        child: Consumer(
          builder: (context, ref, child) {
            final asyncData = ref.watch(spaceControllerProvider);

            return asyncData.when(
              data: (data) {
                final list = data.allSpaces;
                if(list.isEmpty){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/img_5.webp'),
                        const SizedBox(height: 16),
                        Text(
                          "No space Found!",style: Theme.of(context).textTheme.titleLarge!.apply(color: EColors.primaryDark,fontWeightDelta: 3),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create a new space to start organising your items",style: Theme.of(context).textTheme.titleSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 2),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 16);
                  },
                  itemBuilder: (context, index) {
                    final space = list[index];
                    return SpaceCard(space);
                  },
                );
              },
              error: (e, s) => const Text("error"),
              loading: () {
                return const SpaceCardShimmer();
              },
            );
          },
        ),
      ),
      floatingActionButton: AddSpaceFloatingButton(),
    );
  }
}
