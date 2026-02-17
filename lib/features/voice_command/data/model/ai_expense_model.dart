class AiExpenseModel {
  final String title;
  final String? paidDate;
  final double? amount;
  final String category;

  AiExpenseModel({
    required this.category,
    this.paidDate,
    this.amount,
    required this.title,
  });

  factory AiExpenseModel.fromMap({required Map<String, dynamic> mapItem}) {
    return AiExpenseModel(
      category: mapItem['category'],
      title: mapItem['title'],
      amount: (mapItem['amount'] as num?)?.toDouble(),
      paidDate: mapItem['paid_date'],
    );
  }
}
