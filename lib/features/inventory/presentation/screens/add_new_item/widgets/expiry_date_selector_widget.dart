import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/constants.dart';
import '../../../../../../core/theme/colors.dart';
import '../../../controllers/add_items_controller.dart';

class ExpiryDateSelectorWidget extends ConsumerWidget {
  const ExpiryDateSelectorWidget({super.key, required this.id});

  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = addItemStateProvider(id);
    final AddItemController stateController = ref.read(provider.notifier);
    return Consumer(
      builder: (context, ref, child) {
        final selectedDate = ref.watch(provider.select((s) => s.expiryDate));
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
                expiryDate: DateFormat(
                  DateFormatPattern.dateformatPattern,
                ).format(pickedDate),
              );
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Expiry Date',
              labelStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.date_range,
                color: EColors.accentPrimary,
              ),
              suffixIcon: InkWell(
                child: const Icon(Icons.lock_reset_outlined),
                onTap: () {
                  stateController.copyWith(expiryDate: '');
                },
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            child: Text(
              selectedDate ?? 'Non Expiry product',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
