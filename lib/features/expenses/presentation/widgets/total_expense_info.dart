import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:expiry_wise_app/core/constants/constants.dart';
import 'package:expiry_wise_app/core/utils/helpers/helper.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/expense_controllers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expiry_wise_app/core/theme/colors.dart';
import 'package:intl/intl.dart';
// Apne imports check kar lena

class TotalExpenseInfo extends ConsumerWidget {
  const TotalExpenseInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final currentLabel = ref.watch(selectedDateLabelExpense);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer(builder:(_,ref,_){
            final total = ref.watch(totalAmount);
            return Text(Helper.formatCurrency(total), style: Theme.of(context).textTheme.titleMedium!.apply(color: EColors.primaryDark,fontWeightDelta: 5,fontSizeDelta: 2));
          }),
          const Spacer(),

          FilterChip(
            padding: EdgeInsets.zero,
            selected: true,
            showCheckmark: false,
            selectedColor: EColors.backgroundPrimary,
            label: Row(
              children: [
                Text(
                  currentLabel,
                  style: Theme.of(context).textTheme.labelSmall!.apply(color: EColors.primaryDark,fontWeightDelta: 4),
                ),
                SizedBox(width: 4,),
                Icon(Icons.arrow_drop_down_outlined,color:  EColors.primaryDark,)
              ],
            ),
            onSelected: (bool value) {
              _openFilterSheet(context, ref);
            },
          )
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context, WidgetRef ref) async {

    List<DateTime?> tempDates = [
      ref.read(startDateInterval),
      ref.read(lastDateInterval),
    ];
    String tempLabel = ref.read(selectedDateLabelExpense);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            void applyPreset(String type) {
              final now = DateTime.now();
              DateTime start, end;

              if (type == 'This Week') {
                start = now.subtract(Duration(days: now.weekday - 1));
                end = now;
              } else if (type == 'This Month') {
                start = DateTime(now.year, now.month, 1);
                end = now;
              } else if (type == 'Last Month') {
                start = DateTime(now.year, now.month - 1, 1);
                end = DateTime(now.year, now.month, 0);
              } else {
                return;
              }

              setModalState(() {
                tempDates = [start, end]; // Calendar update hoga
                tempLabel = type;         // Label update hoga
              });
            }

            return Container(
              height: 600,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filter Expenses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip("This Week", () => applyPreset("This Week")),
                        const SizedBox(width: 8),
                        _buildFilterChip("This Month", () => applyPreset("This Month")),
                        const SizedBox(width: 8),
                        _buildFilterChip("Last Month", () => applyPreset("Last Month")),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // Calendar
                  Expanded(
                    child: CalendarDatePicker2(
                      config: CalendarDatePicker2Config(
                        calendarType: CalendarDatePicker2Type.range,
                        selectedDayHighlightColor: Colors.indigo,
                      ),
                      value: tempDates,
                      onValueChanged: (dates) {
                        // Agar user manually calendar pe tap kare
                        setModalState(() {
                          tempDates = dates;
                          tempLabel = "${DateFormat(DateFormat.ABBR_MONTH_DAY).format(tempDates[0]!)}-${DateFormat(DateFormat.ABBR_MONTH_DAY).format(tempDates[1]!)}"; // Label change karke Custom kar do
                        });
                      },
                    ),
                  ),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        if (tempDates.length == 2) {
                          ref.read(startDateInterval.notifier).state = tempDates[0]!.toDateOnly;
                          ref.read(lastDateInterval.notifier).state = tempDates[1]!.toDateOnly;
                          ref.read(selectedDateLabelExpense.notifier).state = tempLabel;
                          Navigator.pop(context); // Sheet band
                        }
                      },
                      child: const Text("Apply Filter", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Chip Widget Helper (Fixed)
  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
      onPressed: onTap, // Callback yahan connect kiya
    );
  }
}

extension DateOnlyExtension on DateTime {
  DateTime get toDateOnly {
    return DateTime(year, month, day);
  }
}
