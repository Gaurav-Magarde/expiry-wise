import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../../../inventory/presentation/screens/all_items/widgets/all_items_search_widget.dart';
import '../controllers/expense_controllers.dart';

class AllExpenseAppBarWidget extends ConsumerStatefulWidget implements PreferredSizeWidget{
  const AllExpenseAppBarWidget({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AllExpenseAppBarWidget();
  }

  @override
  Size get preferredSize => const Size(double.infinity, kToolbarHeight);
  
}
class _AllExpenseAppBarWidget extends ConsumerState<AllExpenseAppBarWidget>{
  late TextEditingController searchController ;

  @override
  void initState() {
    searchController = TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingExpense);
    return AppBar(
      title: Row(
            children: [
              !isSearching
                  ? const Text('My Expenses')
                  : Expanded(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        searchController.clear();
                        ref.read(searchControllerExpense.notifier).state =
                        '';
                        ref.read(isSearchingExpense.notifier).state =
                        false;
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: SearchWidget(
                        searchController: searchController,
                            () {
                          searchController.clear();
                          ref.read(searchControllerExpense.notifier).state = '';
                            },
                            (v) {
                              if(v!=null) {
                                ref.read(searchControllerExpense.notifier).state =
                              v;
                              }
                            },
                        'search by name..',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      actions: [
        Consumer(
          builder: (_, ref, _) {
            final isSearching = ref.watch(isSearchingExpense);

            return !isSearching
                ? IconButton(
              onPressed: () {
                ref.read(isSearchingExpense.notifier).state = true;
              },
              icon: const Icon(Icons.search),
            )
                :  const Center();
          },
        ),
      ],
    );
  }
 
  
  
}