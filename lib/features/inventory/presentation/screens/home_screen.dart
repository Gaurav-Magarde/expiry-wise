import 'package:expiry_wise_app/core/widgets/add_item_floating_button.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/home_controller.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/app_bar_widget.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/cards_helper_home_screen.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/no_space_home_screen_widget.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../services/sync_services/local_firebase_syncing.dart';
import '../../data/models/item_model.dart';
import '../widgets/home_cards.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: const AppBarWidget(),
      body: SafeArea(
        child: RefreshIndicator(

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
                 const CardsHelper(),
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
                            return HomeCards(
                              list: list,
                              onEmpty: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/no_items_img.png'),
                                    const SizedBox(height: 16),
                                    Text(
                                      "No $name items Found!",style: Theme.of(context).textTheme.titleLarge!.apply(color: EColors.primaryDark,fontWeightDelta: 3),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Start adding items to track their expiry",style: Theme.of(context).textTheme.titleSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 2),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }, error: (e,s)=>Text('error'),  loading: ()=>Center(child: CircularProgressIndicator(),));
                    },
                  ),
                  const SizedBox(height: 36),

                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AddItemFloatingButton( () {
        context.pushNamed(
          MYRoute.addNewItemScreen,
          queryParameters: {},
        );
      },Icons.add,'Add Item'),
    );
  }

  PreferredSize buildPreferredSize() => PreferredSize(
    preferredSize: Size(double.infinity, 50),
    child: ClipRRect(
      child: Container(decoration: BoxDecoration(color: Colors.green)),
    ),
  );
}


