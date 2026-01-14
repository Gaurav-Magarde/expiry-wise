import 'package:flutter/material.dart';

enum ItemCategory {
  grocery,
  vegetables,
  dairy,
  medicine,
  personalCare,
  electronics,
  documents,
  subscriptions,
  others,
}


// Extension to get details easily
extension CategoryDetails on ItemCategory {

  // 1. Display Name
  String get label {
    switch (this) {
      case ItemCategory.grocery:
        return 'Groceries & Pantry';
      case ItemCategory.vegetables:
        return 'Fruits & Veggies';
      case ItemCategory.dairy:
        return 'Dairy & Bakery';
      case ItemCategory.medicine:
        return 'Medicine & Health';
      case ItemCategory.personalCare:
        return 'Cosmetics & Care';
      case ItemCategory.electronics:
        return 'Electronics (Warranty)';
      case ItemCategory.documents:
        return 'Documents & IDs';
      case ItemCategory.subscriptions:
        return 'Subscriptions';
      case ItemCategory.others:
        return 'Others';
    }
  }

  // 2. Icon
  IconData get icon {
    switch (this) {
      case ItemCategory.grocery:
        return Icons.local_grocery_store;
      case ItemCategory.vegetables:
        return Icons.eco;
      case ItemCategory.dairy:
        return Icons.egg;
      case ItemCategory.medicine:
        return Icons.medication;
      case ItemCategory.personalCare:
        return Icons.face;
      case ItemCategory.electronics:
        return Icons.devices;
      case ItemCategory.documents:
        return Icons.description;
      case ItemCategory.subscriptions:
        return Icons.subscriptions;
      case ItemCategory.others:
        return Icons.category;
    }
  }

  // 3. Color
  Color get color {
    switch (this) {
      case ItemCategory.grocery:
        return Colors.orange;
      case ItemCategory.vegetables:
        return Colors.green;
      case ItemCategory.dairy:
        return Colors.amber;
      case ItemCategory.medicine:
        return Colors.redAccent;
      case ItemCategory.personalCare:
        return Colors.pinkAccent;
      case ItemCategory.electronics:
        return Colors.blueGrey;
      case ItemCategory.documents:
        return Colors.brown;
      case ItemCategory.subscriptions:
        return Colors.purple;
      case ItemCategory.others:
        return Colors.grey;
    }
  }
}

class ChipsModel{
  static List<String> get  allChips {
    List<String> list =  ItemCategory.values.map((cate)=>cate.name).toList();
    list.insert(0,'all');
    return list;
  }



}