import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_item_state.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/add_items_controller.dart';
import 'widgets/edit_item_form.dart';

class AddNewItem extends ConsumerWidget {
  final String? id;
  const AddNewItem(this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        // titleSpacing: 0
        actions: [
          IconButton(
            onPressed: () {
              context.pushNamed(MYRoute.barcodeScanScreen);
            },
            icon: const Icon(Icons.document_scanner),
          ),
        ],
        title: Text(id == null ? 'Add Item' : 'Edit item'),
      ),
      body: EditItemForm(id),
    );
  }
}
