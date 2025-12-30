import 'package:expiry_wise_app/features/inventory/data/models/category_helper.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/add_items_controller.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/helpers/image_helper.dart';
import '../../../../core/widgets/text_form_field.dart';

class EditItemForm extends ConsumerWidget {
  final String? id;
  const EditItemForm(this.id, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final state = ref.watch(provider);
    final stateController = ref.read(provider.notifier);

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
        padding:const  EdgeInsets.all(0),
        child: Column(
          children: [
            const SizedBox(height: 16),

            InkWell(
              onTap: () async {
                final file = await ImagePicker().pickImage(source: ImageSource.camera);
                if(file!=null){
                  stateController.copyWith(image: file.path);
                }
                }
                ,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,

                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 3),
                      color: Colors.grey.shade200,
                      blurRadius: 15,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: ImageHelper.giveAddImage(
                  imagePath: state.image,
                  imagePathNetwork: '',
                ),
              ),
            ),

            Container(
              padding:const  EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 3),
                    blurStyle: BlurStyle.outer,
                    blurRadius: 7,
                    color: Colors.grey.shade300
                  )
                ]
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
                            TextFormFieldWidget(
                              controller: state.itemNameController,
                              prefixIcon: Icon(Icons.shopping_bag,color: EColors.primary,),
                              hint: "Item Name",
                              labelText: 'Product Name',
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  // flex: 4,
                                  child: TextFormFieldWidget(
                                    prefixIcon: Icon(Icons.format_list_numbered,color: EColors.primary,),
                                    controller: state.itemQtyController,
                                    hint: "Quantity",
                                    labelText: "Quantity",
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final currentUnit = ref.watch(
                                        provider.select((s) => s.unit),
                                      );

                                      // Using InkWell for better touch feedback
                                      return Expanded(
                                        flex: 1, // Unit chhota
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            // Unit State fetch karo
                                            final selectedUnit = ref.watch(
                                              provider.select((s) => s.unit), // Assuming 'unit' is in your state
                                            );

                                            // Default Unit List
                                            final List<String> units = ['pcs', 'kg', 'L', 'pkt', 'g'];

                                            return InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: "Unit", // ✨ Border Label
                                                labelStyle: TextStyle(color: Colors.grey),

                                                // Border Styling
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                  borderSide: BorderSide(color: Colors.grey),
                                                ),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<String>(
                                                  value: units.contains(selectedUnit) ? selectedUnit : units[0],
                                                  isExpanded: true,
                                                  isDense: true,
                                                  items: units.map((String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (val) {
                                                    if (val == null) return;
                                                    stateController.copyWith(unit: val);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
                      // Data fetch logic
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
                          labelStyle: TextStyle(color: Colors.grey),

                          prefixIcon: Icon(selected.icon, color: EColors.primary),

                          // Border Styling
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),

                        // Dropdown Logic
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
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
                  )
                ],
              ),
            ),

            Container(
              padding:const  EdgeInsets.all(16),
              margin:const  EdgeInsets.only(bottom:  16,right: 16,left: 16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 3),
                        blurStyle: BlurStyle.outer,
                        blurRadius: 15,
                        color: Colors.grey.shade300
                    )
                  ]
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
                            initialDate: DateTime.now(), // Crash se
                            firstDate: DateTime(2001),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            stateController.copyWith(
                              expiryDate: DateFormat('yyyy-MM-dd').format(pickedDate),
                            );
                          }
                        },

                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: "Expiry Date",
                            labelStyle: TextStyle(color: Colors.grey), // Label ka color styling
                            prefixIcon: Icon(Icons.date_range, color: EColors.primary), // Icon ab decoration ka part hai
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                            ),
                            enabledBorder: OutlineInputBorder( // Normal state border
                              borderRadius: BorderRadius.all(Radius.circular(6)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Height adjust karne ke liye
                          ),
                          // Value Text
                          child: Text(
                            selectedDate ?? "", // Agar null hai to blank rakho, label apne aap placeholder ban jayega
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormFieldWidget(
                    controller: state.noteController,
                    hint: "Add a Note",
                    labelText: "Note",
                    prefixIcon: Icon(Icons.message,color: EColors.primary,),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
