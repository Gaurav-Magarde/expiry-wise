import 'package:expiry_wise_app/features/inventory/presentation/widgets/sortable_list_heading.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/all_item_controller.dart';

class AllItemsScreen extends ConsumerStatefulWidget{
   AllItemsScreen({super.key});

  final TextEditingController _searchController = TextEditingController();

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return  _AllItemsScreen();
  }
}



class _AllItemsScreen extends ConsumerState<AllItemsScreen> {
   _AllItemsScreen();
  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isSearchingProvider);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(

        titleSpacing: isSearching ? 0 : NavigationToolbar.kMiddleSpacing,


        leading: isSearching
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            ref.read(isSearchingProvider.notifier).state = false;
            ref.read(allItemsSearchText.notifier).state = '';
          },
        )
            : null, // Normal mode me drawer ya back button jo bhi ho

        title: isSearching
            ? TextField(
          autofocus: true,
          controller: widget._searchController,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          cursorColor: Colors.blueAccent,
          decoration: InputDecoration(
            hintText: "Search items...",
            hintStyle: const TextStyle(color: Colors.grey),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Text alignment

            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () {
                widget._searchController.clear();
                ref.read(allItemsSearchText.notifier).state = "";
              },
            ),
          ),
          onChanged: (val) {
            ref.read(allItemsSearchText.notifier).state = val;
          },
        )
            : const Text("Inventory"),

        actions: isSearching
            ? []
            : [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ref.read(isSearchingProvider.notifier).state = true;
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
      body:const  SortableList(),
    );
  }
}