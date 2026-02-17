import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/home/presentation/controllers/home_controller.dart';
import 'package:expiry_wise_app/features/home/presentation/widgets/app_bar_widget.dart';
import 'package:expiry_wise_app/features/home/presentation/screens/inventory_status/widgets/no_space_home_screen_widget.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../services/sync_services/local_firebase_syncing.dart';
import '../../../../inventory/domain/item_model.dart';
import 'widgets/selected_items_card_widget.dart';
import 'widgets/status_cards_helper_widget.dart';
class PantryStatusScreen extends ConsumerWidget{
  const PantryStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Pantry Status'),),
      body: RefreshIndicator(

        onRefresh: () async{
          await ref.read(syncProvider).performManualSync();
        },
        color: EColors.primary,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const CardsHelperWidget(),
                const SizedBox(height: 16),
                Consumer(
                  builder: (BuildContext context, WidgetRef ref, Widget? child) {
                    final isSpace = ref.watch(currentSpaceProvider);
                    return isSpace.when(data: (space){
                      if(space==null) return NoSpaceHomeScreenWidget();
                      return Consumer(
                        builder: (_, ref, __) {
                          List<ItemModel> list = <ItemModel>[];

                          String name = '';
                          final selected = ref.watch(selectedContainerProvider);
                          if (selected == SelectedContainer.expired) {
                            list = ref.watch(expiredItemsProvider).value ?? [];
                            name = 'expired';
                          } else if (selected == SelectedContainer.expiring) {
                            list =
                                ref.watch(expiringSoonItemsProvider).value ?? [];
                            name = 'expiring';
                          } else {
                            list = ref.watch(recentlyItemsProvider).value ?? [];
                            name = 'recent';
                          }
                          return SelectedItemsCardWidget(
                            list: list,
                            onEmpty: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset('assets/images/no_items_img.webp'),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No $name items Found!',style: Theme.of(context).textTheme.titleLarge!.apply(color: EColors.primaryDark,fontWeightDelta: 3),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start adding items to track their expiry',style: Theme.of(context).textTheme.titleSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 2),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }, error: (e,s)=>const Text('error'),  loading: ()=>const Center(child: CircularProgressIndicator(),));
                  },
                ),
                const SizedBox(height: 36),

              ],
            ),
          ),
        ),
      ),
    );
  }

}