import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/widgets/chips/notification_day_chips.dart';
import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_item_controllers/add_items_controller.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/utils/helpers/image_helper.dart';
import '../../../../../../core/widgets/text_form_field.dart';

class EditItemForm extends ConsumerWidget {
  final String? id;
  const EditItemForm(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);

    final stateController = ref.read(provider.notifier);

    Future.microtask(() {
      stateController.loadAsyncDependencies();
    });

    // 4. Barcode Listener (Logic same rahega)
    ref.listen(scannedBarcodeProvider, (previous, next) async {
      if (next != null && next.isNotEmpty) {
        try {
          ref.read(isProductFindingProvider.notifier).state = true;
          await stateController.fetchItemByBarcode((next));
        } catch (e) {
          throw 'exception occur';
        } finally {
          ref.read(isProductFindingProvider.notifier).state = false;
          ref.read(scannedBarcodeProvider.notifier).state = null;
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
            InkWell(
              onTap: () async {
                final file = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                );
                if (file != null) {
                  stateController.copyWith(image: file.path);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 3),
                      color: Colors.grey.shade300,
                      blurRadius: 15,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Consumer(
                  builder: (context, ref, child) {
                    final imagePath = ref.watch(
                      provider.select((s) => s.image),
                    );
                    return ImageHelper.giveAddImage(
                      imagePath: imagePath,
                      imagePathNetwork: '',
                    );
                  },
                ),
              ),
            ),

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
                                  provider.select((s) => s.itemNameController),
                                );
                                return TextFormFieldWidget(
                                  controller: nameController,
                                  prefixIcon: Icon(
                                    Icons.shopping_bag,
                                    color: EColors.accentPrimary,
                                  ),
                                  hint: "Item Name",
                                  labelText: 'Product Name',
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(

                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final qtyController = ref.watch(
                                        provider.select(
                                          (s) => s.itemQtyController,
                                        ),
                                      );
                                      return TextFormFieldWidget(
                                        textInputType:
                                            TextInputType.numberWithOptions(
                                              decimal: false,
                                              signed: false,
                                            ),
                                        prefixIcon: Icon(
                                          Icons.format_list_numbered,
                                          color: EColors.accentPrimary,
                                        ),
                                        controller: qtyController,
                                        hint: "1",
                                        labelText: "Qty",

                                        suffixIcon: Consumer(
                                          builder: (context, ref, child) {
                                            final selectedUnit = ref.watch(
                                              provider.select((s) => s.unit),
                                            );

                                            final List<String> units = [
                                              'pcs',
                                              'kg',
                                              'L',
                                              'pkt',
                                              'g',
                                              'ml',
                                            ];

                                            return DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value:
                                                    units.contains(selectedUnit)
                                                    ? selectedUnit
                                                    : units[0],
                                                isExpanded: false,
                                                isDense: true,
                                                items: units.map((
                                                  String value,
                                                ) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (val) {
                                                  if (val == null) return;
                                                  stateController.copyWith(
                                                    unit: val,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),

                                PriceEditingWidget(id,ref.read(provider).price),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      final selectedCategory = ref.watch(
                        provider.select((s) => s.category),
                      );
                      final selected = ItemCategory.values.firstWhere(
                        (e) => e.name == selectedCategory,
                        orElse: () => ItemCategory.grocery,
                      );

                      return InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Category",
                          labelStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: Icon(
                            selected.icon,
                            color: EColors.accentPrimary,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ItemCategory>(
                            value: selected,
                            isExpanded: true,
                            isDense: true,
                            items: ItemCategory.values.map((category) {
                              return DropdownMenuItem<ItemCategory>(
                                value: category,
                                child: Text(
                                  category.label,
                                  style: Theme.of(context).textTheme.labelLarge!
                                      .apply(color: category.color),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              stateController.copyWith(category: val.name);
                            },
                          ),
                        ),
                      );
                    },
                  ),
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
                  Consumer(
                    builder: (context, ref, child) {
                      final selectedDate = ref.watch(
                        provider.select((s) => s.expiryDate),
                      );
                      return InkWell(
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2001),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            stateController.copyWith(
                              expiryDate: DateFormat(DateFormatPattern.dateformatPattern
                              ).format(pickedDate),
                            );
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Expiry Date",
                            labelStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: EColors.accentPrimary,
                            ),
                            suffixIcon: InkWell(
                              child: Icon(Icons.lock_reset_outlined),
                              onTap: () {
                                stateController.copyWith(expiryDate: '');
                              },
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(6),
                              ),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                          child: Text(
                            selectedDate ?? "Non Expiry product",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (context, ref, child) {
                      final noteController = ref.watch(
                        provider.select((s) => s.noteController),
                      );
                      return TextFormFieldWidget(
                        controller: noteController,
                        hint: "Add a Note",
                        labelText: "Note(optional)",
                        prefixIcon: Icon(
                          Icons.message,
                          color: EColors.accentPrimary,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  Consumer(
                    builder: (_, ref, _) {
                      final selectedChips = ref.watch(
                        provider.select((s) => s.selectedDays),
                      );
                      final isExpiry = ref.watch(
                        provider.select((s) => s.expiryDate),
                      );
                      return isExpiry == null || isExpiry.isEmpty
                          ? Center()
                          : ExpansionTile(
                              iconColor: Colors.grey,
                              collapsedIconColor: EColors.primaryDark,
                              shape: const Border(),
                              collapsedShape: const Border(),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    color: EColors.accentPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Notification Settings',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              children: [
                                NotificationDayChips(
                                  selectedDays: selectedChips,
                                  onSelectedChanged: (list) {
                                    stateController.copyWith(
                                      selectedDays: list,
                                    );
                                  },
                                ),
                              ],
                            );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class PriceEditingWidget extends ConsumerStatefulWidget {
  const PriceEditingWidget(this.id, this.text, {super.key});
  final String? id;
  final double? text;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
   return _PriceEditingWidget();
  }

}




class _PriceEditingWidget extends ConsumerState<PriceEditingWidget> {

  late TextEditingController controller;


  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
    controller.text = widget.text==null? '': widget.text.toString();
  }

  @override
  void dispose() {

    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormFieldWidget(
        controller: controller,
        labelText: 'price',
        onChanged: (v){
            ref.read(addItemStateProvider(widget.id).notifier).copyWith(price: v);
          },
        prefixIcon: Icon(
          Icons.currency_rupee_outlined,
          color: EColors.accentPrimary,
        ),
        textInputType:
            TextInputType.numberWithOptions(
              decimal: false,
              signed: false,
            ),
      ),
    );
  }
}
