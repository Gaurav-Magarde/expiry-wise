import 'package:expiry_wise_app/features/inventory/presentation/controllers/item_controller.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/all_items/widgets/sortable_list_heading_widget.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/add_item_floating_button.dart';
import 'widgets/all_category_chips_widget.dart';
import 'widgets/all_items_search_widget.dart';
import 'widgets/finished_items_list_widget.dart';

class AllItemsScreen extends ConsumerStatefulWidget {
  const AllItemsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AllItemsScreen();
  }
}

class _AllItemsScreen extends ConsumerState<AllItemsScreen> {
  _AllItemsScreen();
  final TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isSearching =
        ref.watch(itemControllerProvider.select((s) => s.searchText)) != null;
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          titleSpacing: isSearching ? 0 : NavigationToolbar.kMiddleSpacing,

          leading: isSearching
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    ref
                        .read(itemControllerProvider.notifier)
                        .changeSearchText(searchText: null);
                    textController.text = '';
                  },
                )
              : null,

          title: isSearching
              ? SearchWidget(
                  searchController: textController,
                  () {
                      ref
                          .read(itemControllerProvider.notifier)
                          .changeSearchText(searchText: '');
                    textController.text = '';
                  },
                  (v) {
                    ref
                        .read(itemControllerProvider.notifier)
                        .changeSearchText(searchText: v);
                  },
                  'search items...',
                )
              : const Text('Inventory'),

          actions: isSearching
              ? []
              : [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                        ref
                            .read(itemControllerProvider.notifier)
                            .changeSearchText(searchText: '');
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      context.pushNamed(MYRoute.addNewItemScreen);
                      context.pushNamed(MYRoute.barcodeScanScreen);
                    },
                  ),
                ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 16),
            const AllChips(),
            Container(
              height: 36,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: const Color(0xFF6C63FF),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelMedium!.apply(fontWeightDelta: 2),
                tabs: [
                  const Tab(height: 36, child: Text('Active')),
                  const Tab(height: 36, child: Text('Finished')),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(children: [SortableList(), FinishedList()]),
            ),
          ],
        ),
        floatingActionButton: AddItemFloatingButton(
          () {
            context.pushNamed(MYRoute.addNewItemScreen, queryParameters: {});
          },
          Icons.add,
          'Add Item',
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

}
