import 'package:expiry_wise_app/core/widgets/shimmers/product_loading_listview.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/all_items/widgets/all_category_chips_widget.dart';
import 'package:expiry_wise_app/features/inventory/presentation/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../routes/route.dart';
import '../../../../../../services/sync_services/local_firebase_syncing.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../../../Space/presentation/controllers/current_space_provider.dart';
import '../../../../data/models/item_model.dart';
import '../../../controllers/item_controller/all_item_controller.dart';

class FinishedList extends ConsumerWidget {
  const FinishedList({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer(
                          builder: (_, ref, _) {
                            final allItemsAsync = ref.watch(finishedItemsState);
                            int noOfItems = 0;
                            allItemsAsync.when(
                              data: (data) {
                                noOfItems = data.length;
                              },
                              error: (e, s) {
                                noOfItems = 0;
                              },
                              loading: () {
                                noOfItems = 0;
                              },
                            );
                            return Text(
                              '$noOfItems items finished',
                              style: Theme.of(context).textTheme.titleMedium!
                                  .apply(color: EColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer(
              builder: (_, ref, __) {
                final allItemsAsync = ref.watch(finishedItemsState);

                final currentSpace = ref.watch(currentSpaceProvider).value;
                if(currentSpace==null) {
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/no_items_img.webp"),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Text(
                            "No Items Found",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .apply(
                              color: EColors.primaryDark,
                              fontWeightDelta: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: Text(
                            "Try adjusting your search or add a new item to your list",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .apply(
                              color: EColors.accentPrimary,
                              fontWeightDelta: 2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamed(
                                MYRoute.addNewItemScreen,
                                queryParameters: {},
                              );
                            },
                            child: const Text("Add Item"),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return allItemsAsync.when(
                  data: (items) {
                    final isLoading = ref.watch(isItemsSortingProvider);
                    final list = List<ItemModel>.from(items);
                    if (isLoading) {
                      return ListView.separated(
                        itemBuilder: (context, index) {
                          return const ItemCardShimmer();
                        },
                        separatorBuilder: (context, ind) {
                          return const SizedBox(height: 8);
                        },
                        itemCount: 7,
                      );
                    }
                    return Consumer(
                      builder: (context, ref, child) {
                        final toSearch = ref.watch(allItemsSearchText);

                        final sortedList = list
                            .where(
                              (item) => item.name.toLowerCase().contains(
                            toSearch.toLowerCase(),
                          ),
                        )
                            .toList();
                        if (sortedList.isEmpty) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              await ref.read(syncProvider).performManualSync();
                            },
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/no_items_img.webp"),
                                  const SizedBox(height: 24),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      "No Items Found",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .apply(
                                        color: EColors.primaryDark,
                                        fontWeightDelta: 2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      "Try adjusting your search or add a new item to your list",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .apply(
                                        color: EColors.accentPrimary,
                                        fontWeightDelta: 2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.pushNamed(
                                          MYRoute.addNewItemScreen,
                                          queryParameters: {},
                                        );
                                      },
                                      child: const Text("Add Item"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            await ref.read(syncProvider).performManualSync();
                          },
                          color: EColors.primary,

                          child: ListView.separated(
                            itemBuilder: (context, index) {
                              return ItemCard(item: sortedList[index]);
                            },
                            separatorBuilder: (context, ind) {
                              return SizedBox(height: 0);
                            },
                            itemCount: sortedList.length,
                          ),
                        );
                      },
                    );
                  },
                  error: (e, s) => Text("err"),
                  loading: () {
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return const ItemCardShimmer();
                      },
                      separatorBuilder: (context, ind) {
                        return const SizedBox(height: 8);
                      },
                      itemCount: 7,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
