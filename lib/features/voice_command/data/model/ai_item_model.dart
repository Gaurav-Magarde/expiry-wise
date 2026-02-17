class AiItemModel {
  final String name;
  final String? quantity;
  final String? expiry;
  final double? price;
  final String category;

  AiItemModel({
    required this.category,
    this.expiry,
    this.price,
    this.quantity,
    required this.name,
  });

  factory AiItemModel.fromMap({required Map<String, dynamic> mapItem}) {
    return AiItemModel(
      category: mapItem['category'],
      name: mapItem['name'],
      quantity: mapItem['quantity'],
      price: (mapItem['price'] as num?)?.toDouble(),
      expiry: mapItem['expiry'],
    );
  }
}
