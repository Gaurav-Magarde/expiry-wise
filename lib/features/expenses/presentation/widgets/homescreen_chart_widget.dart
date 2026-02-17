import 'package:expiry_wise_app/core/utils/helpers/helper.dart';
import 'package:expiry_wise_app/features/expenses/data/models/expense_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatefulWidget {
  final List<ExpenseModel> expenses; // Tera Expense Model List

  const ExpensePieChart({super.key, required this.expenses});

  @override
  State<ExpensePieChart> createState() => _ExpensePieChartState();
}

class _ExpensePieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _processData();
    final totalExpense = widget.expenses.fold(0.0, (sum, item) => sum + item.amount);

    if (totalExpense == 0) {
      return SizedBox(height: 200, child: Center(child: Text("No expenses yet!")));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('Monthly Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 250, // Chart ki height
            child: Stack(
              children: [
                // The Chart
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2, // Sections ke beech gap
                    centerSpaceRadius: 60, // Donut ka hole size
                    sections: _buildChartSections(categoryTotals),
                  ),
                ),
                // Center Text (Total Amount)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(touchedIndex==-1? 'Total':widget.expenses[touchedIndex].category.name, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                        touchedIndex==-1? '₹${totalExpense.toStringAsFixed(0)}':Helper.formatCurrency(widget.expenses[touchedIndex].amount),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: categoryTotals.keys.map((category) {
                return _buildLegendItem(category.name, category.color);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper 1: Data ko Group karna
  Map<ExpenseCategory, double> _processData() {
    Map<ExpenseCategory, double> data = {};
    for (var expense in widget.expenses) {
      ExpenseCategory cat = expense.category;
      if (!data.containsKey(cat)) data[cat] = 0;
      data[cat] = data[cat]! + expense.amount;
    }
    return data;
  }

  // Helper 2: Sections Banana
  List<PieChartSectionData> _buildChartSections(Map<ExpenseCategory, double> data) {
    List<PieChartSectionData> sections = [];
    int index = 0;

    data.forEach((category, amount) {
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 16.0 : 0.0;
      final double radius = isTouched ? 60.0 : 50.0;
      sections.add(PieChartSectionData(
        color: category.color,
        value: amount,
        title: '₹${amount.toStringAsFixed(0)}',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.white),
      ));
      index++;
    });
    return sections;
  }


  // Helper 4: Legend UI
  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}