import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart  ';

import '../../../../../../core/theme/colors.dart';
import '../../../../../../core/widgets/text_form_field.dart';
import '../../../controllers/add_items_controller.dart';

class ItemQuantityTakerWidget extends ConsumerWidget {
  const ItemQuantityTakerWidget({
    required this.quantityController,
    required this.priceController,
    super.key,
    required this.id,
  });

  final String? id;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final AddItemController stateController = ref.read(provider.notifier);
    return Row(
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              return TextFormFieldWidget(
                textInputType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                prefixIcon: const Icon(
                  Icons.format_list_numbered,
                  color: EColors.accentPrimary,
                ),
                controller: quantityController,
                hint: '1',
                labelText: 'Qty',

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
                        value: units.contains(selectedUnit)
                            ? selectedUnit
                            : units[0],
                        isExpanded: false,
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
                    );
                  },
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        PriceEditingWidget( priceController,),
      ],
    );
  }
}




class PriceEditingWidget extends ConsumerWidget {
  const PriceEditingWidget(this.controller, {super.key});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context, ref) {
    return Expanded(
      child: TextFormFieldWidget(
        controller: controller,
        labelText: 'price',
        prefixIcon: const Icon(
          Icons.currency_rupee_outlined,
          color: EColors.accentPrimary,
        ),
        textInputType: const TextInputType.numberWithOptions(
          decimal: false,
          signed: false,
        ),
      ),
    );
  }
}
