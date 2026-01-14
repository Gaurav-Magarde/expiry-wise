import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_item_controllers/add_item_state.dart';
import 'package:expiry_wise_app/routes/route.dart';
import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/add_item_controllers/add_items_controller.dart';
import 'widgets/edit_item_form.dart';

class AddNewItem extends ConsumerWidget {
  final String? id;
  const AddNewItem(this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final isFinished = ref.read(provider.select((s) => s.finished));
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
        title: Text(id == null ? "Add Item" : "Edit item"),
      ),
      body: EditItemForm(id),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // decoration: BoxDecoration(
        // ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(elevation: 10),
          onPressed: () async {
            final currSpace = ref.read(currentSpaceProvider);
            if (currSpace.isLoading ||
                currSpace.hasError ||
                currSpace.value == null ||
                currSpace.value?.id == null ||
                currSpace.value!.id.isEmpty) {
              SnackBarService.showError(
                'No Space found.please add space to track items',
              );
              return;
            }
            final controller = ref.read(isItemAddingProvider.notifier);
            if (ref.read(isItemAddingProvider) == true) return;
            try {
              controller.state = true;
              ref.read(isItemAddingProvider.notifier).state = true;
              final stateController = ref.read(provider.notifier);
              final allFieldOk = stateController.validateAllFields();
              if (!allFieldOk) {
                return;
              }
              id == null
                  ? await stateController.insertItem()
                  : await stateController.updateItem(id, isFinished);
              if (context.mounted) {
                context.pop();
              }
            } catch (e) {
              SnackBarService.showMessage('Item adding failed');
            } finally {
              controller.state = false;
            }
          },
          child: Consumer(
            builder: (_, ref, __) {
              final isLoading = ref.watch(isItemAddingProvider);
              return isLoading
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  : Text(
                      id == null ? "Add Item" : "Save Item",
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.apply(color: Colors.white),
                    );
            },
          ),
        ),
      ),
    );
  }
}
