import '../../data/models/expense_model.dart';

class EditExpenseState {
  final String title;
  final ExpenseCategory category;
  final String selectedDate;
  final String amount;
  final String? note;
  final String? paidBY;
  final bool isExpenseSaving;

  EditExpenseState( {
    required this.paidBY,
    required this.isExpenseSaving,
    required this.note,
    required this.category,
    required this.amount,
    required this.title,
    required this.selectedDate,
  });

  factory EditExpenseState.empty() {
    return EditExpenseState(
      note: '',
      category: ExpenseCategory.household,
      amount: '',
      title: '',
      selectedDate: '', paidBY: 'You',
      isExpenseSaving: false
    );
  }

  EditExpenseState copyWith({
    String? title,
    String? selectedDate,
    String? amount,
    ExpenseCategory? category,
    String? note,
    String? paidBy,
    bool? isExpenseSaving,
  }) {
    return EditExpenseState(
      isExpenseSaving: isExpenseSaving??this.isExpenseSaving,
      paidBY: paidBy??this.paidBY,
      note: note ?? this.note,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}