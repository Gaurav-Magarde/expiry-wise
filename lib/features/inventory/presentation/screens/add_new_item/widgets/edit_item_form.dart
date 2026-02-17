import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_item_state.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_items_controller.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:expiry_wise_app/features/inventory/presentation/screens/add_new_item/widgets/add_item_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/utils/snackbars/snack_bar_service.dart';
import '../../../../../../core/widgets/text_form_field.dart';
import 'category_selector_widget.dart';
import 'expiry_date_selector_widget.dart';
import 'item_image_picker_widget.dart';
import 'item_notification_selector_widget.dart';
import 'item_quantity_taker_widget.dart';

class EditItemForm extends ConsumerStatefulWidget {
  const EditItemForm(this.id, {super.key});
  final String? id;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EditItemForm();
  }
}

class _EditItemForm extends ConsumerState<EditItemForm> {
  _EditItemForm();
  bool _didHydrate = false;
  late  ProviderSubscription<AddItemState> _sub;

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _quantityController = TextEditingController();
    _priceController = TextEditingController();
    _nameController = TextEditingController();

     _sub = ref.listenManual(addItemStateProvider(widget.id), (prev,next){
      if(_didHydrate) return;
      if(prev==null && next.isItemEditing && next.itemName!=null){
        _noteController.text = next.note??'';
        _nameController.text = next.itemName??'';
        _quantityController.text = next.itemQty??'';
        _priceController.text = next.price.toString();
      }
      _didHydrate = true;
    },
     fireImmediately: true
     );
  }

  @override
  void dispose() {
    _sub.close();
    _noteController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final provider = addItemStateProvider(id);
    final stateController = ref.read(provider.notifier);
    ref.listen(provider.select((s) => s.scannedBarcode), (
      previous,
      next,
    ) async {
      if (next != null && next.isNotEmpty) {
        try {
          ref.read(provider.notifier).copyWith(barcode: next);
          await stateController.fetchItemByBarcode((next));
        } catch (e) {
          throw 'exception occur';
        } finally {
          ref.read(provider.notifier).copyWith(barcode: null);
        }
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- IMAGE PICKER SECTION ---
            ItemImagePickerWidget(id: id),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 7,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Consumer(
                              builder: (context, ref, child) {
                                final nameController = ref.watch(
                                  provider.select((s) => s.itemName),
                                );
                                return TextFormFieldWidget(
                                  controller: _nameController,
                                  prefixIcon: const Icon(
                                    Icons.shopping_bag,
                                    color: EColors.accentPrimary,
                                  ),
                                  hint: 'Item Name',
                                  labelText: 'Product Name',
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            ItemQuantityTakerWidget(
                              id: id,
                              quantityController: _quantityController,
                              priceController: _priceController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  CategorySelectorWidget(id: id),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 15,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              child: Column(
                children: [
                  ExpiryDateSelectorWidget(id: id),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      return TextFormFieldWidget(
                        controller: _noteController,
                        hint: 'Add a Note',
                        labelText: 'Note(optional)',
                        prefixIcon: const Icon(
                          Icons.message,
                          color: EColors.accentPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  ItemNotificationSelectorWidget(id: id),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Consumer(
              builder: (_,ref,_){
                final isSaving = ref.watch(addItemStateProvider(id).select((s)=>s.isSaving));
                return BottomAddItemButtonWidget(
                  child: isSaving ? const CircularProgressIndicator(color: Colors.white,):  const Text('Save item'),
                  onPressed: () async {
                    try {
                      ref.read(provider.notifier)
                          .copyWith(
                        note: _noteController.text.trim(),
                        price: _priceController.text.trim(),
                        name: _nameController.text.trim(),
                        quantity: _quantityController.text.trim(),
                      );
                      await stateController.saveItem();
                      if (context.mounted) {
                        context.pop();
                      }
                    } catch (e) {
                      SnackBarService.showMessage('Item adding failed');
                    } finally {
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}



