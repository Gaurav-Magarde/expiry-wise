import 'package:uuid/uuid.dart';

class ItemModel {
  ItemModel( {
    required this.finished,
    required this.isExpenseLinked,
    String? id,
    this.addedDate,
    required this.image,
    required this.imageNetwork,
    required this.userId,
    required this.price,
    required this.spaceId,
    required this.name,
    required this.expiryDate,
    required this.updatedAt,
    required this.category,
    required this.quantity,
    required this.note,
    required this.unit,
    required this.notifyConfig,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final double? price;
  final bool? isExpenseLinked;
  final String? spaceId;
  final String? userId;
  final String image;
  final String imageNetwork;
  final String name;
  final String note;
  final String? expiryDate;
  final String updatedAt;
  final String? addedDate;
  final String category;
  final String unit;
  final int quantity;
  final int finished;
  final List<int> notifyConfig;

  Map<String, dynamic> toMap() {
    return {
      'price':price,
      "notify_config": notifyConfig.join(','),
      "finished" : finished,
      "id": id,
      "added_date": addedDate,
      'image_network': imageNetwork,
      "name": name,
      "note": note,
      "expiry_date": expiryDate,
      "quantity": quantity,
      "category": category,
      "image": image,
      "user_id": userId,
      "space_id": spaceId,
      "is_synced": 0,
      "is_deleted": 0,
      'unit': unit,
      'updated_at': updatedAt,
      'is_expense_linked':isExpenseLinked !=null && isExpenseLinked! ?1:0
    };
  }

  factory ItemModel.fromMap({required Map<String, dynamic> item, bool? isSynced, String? userId}) {

    List<int> parsedConfig = [];
    if (item['notify_config'] != null) {
      final data = item['notify_config'];
      try {
        if (data is String && data.isNotEmpty) {
          parsedConfig = data.split(',').map((e) => int.parse(e)).toList();
        } else if (data is List) {
          parsedConfig = List<int>.from(data);
        }
      } catch (e) {
        parsedConfig = [];
      }
    }

    return ItemModel(

      price: item['price'],
      finished: item['finished']??0,
        notifyConfig: parsedConfig,
        updatedAt: item['updated_at'] ?? '',
        id: item['id'] ?? '',
        unit: item['unit'] ?? "pcs",
        image: item['image'] ?? '',
        imageNetwork: item['image_network'] ?? '',
        userId: userId ?? item['user_id'] ?? '',
        spaceId: item['space_id'] ?? '',
        name: item['name'] ?? '',
        expiryDate: item['expiry_date'],
        category: item['category'] ?? '',
        quantity: item['quantity'] ?? 1,
        note: item['note'] ?? '',
        addedDate: item['added_date'] ?? '', isExpenseLinked:  item['is_expense_linked']!=null  && item['is_expense_linked']==1 ? true : false
    );
  }
}