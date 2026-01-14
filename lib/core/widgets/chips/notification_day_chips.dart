import 'package:flutter/material.dart';


class NotificationDayChips extends StatelessWidget {
  const NotificationDayChips({super.key, required this.selectedDays, required this.onSelectedChanged});
  final List<int> selectedDays;
  final Function(List<int>) onSelectedChanged;
  static const _options  = [0,1,2,7,14,28];
  // final Function>
  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Wrap(
          spacing : 8.0,
          children: _options.map((day){
            final isSelected = selectedDays.contains(day);
            final time = _formatDays(day);
            return FilterChip(label: Text(time), selected: isSelected,selectedColor: Colors.deepPurple.shade100, // Tera Theme Color
                checkmarkColor: Colors.deepPurple,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.deepPurple : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
            onSelected: (selected){
              final List<int> newList = List.from(selectedDays);
              if(selected){
                newList.add(day);
              }else{
                newList.remove(day);
              }
              print(newList);
              onSelectedChanged(newList);
            },);
          }).toList(),
        )
      ],
    );
  }
}

String _formatDays(int days) {
  if (days >= 28) {
    int months = days ~/ 28;
    return '$months ${months == 1 ? "Month" : "Months"}';
  }
  else if (days >= 7) {
    int weeks = days ~/ 7;
    return '$weeks ${weeks == 1 ? "Week" : "Weeks"}';
  }
  else {
    if(days==0) return "Expiring day";
    return '$days ${days == 1 ? "Day" : "Days"}';
  }
}