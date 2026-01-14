import 'dart:core';

import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';
import 'package:flutter/material.dart';

class ExpenseModel {
  final String title;
  final String id;
  final String? payerName;
  final String spaceId;
  final String? payerId;
  final double amount;
  final String? note;
  final ExpenseCategory category;
  final String expenseDate;
  final String updatedAt;
  final bool isSynced;
  ExpenseModel( {this.note,
    this.payerName,
    required this.spaceId,
    this.payerId,
    required this.title,
    required this.id,
    required this.amount,
    required this.category,
    required this.expenseDate,
    required this.updatedAt,
    required this.isSynced,
  });

factory ExpenseModel.fromMap({required Map<String, dynamic> map}) {
  return ExpenseModel(
    note: map['note'],
    spaceId: map['space_id'],
    payerName: map['payer_name']??'',
    payerId: map['payer_id']??'',
    title: map['title']??"",
    id: map['id']??"",
    amount: map['amount']??0.0,
    category: ExpenseCategory.values.firstWhere((e)=>e.name==map['category'],orElse: ()=>ExpenseCategory.others),
    expenseDate: map['expense_date']??'',
    isSynced: map['is_synced']==null || map['is_synced'] ==0 ? false :true, updatedAt:  map['updated_at']??'',
  );
}

Map<String,dynamic> toMap({String? isSynced}){
  return {
    'is_synced':  isSynced ?? (this.isSynced?1:0),
    'note':note,
    'space_id':spaceId,
    'payer_name':payerName,
    'payer_id':payerId,
    'title':title,
    'id':id,
    'amount':amount,
    'category':category.name,
    'expense_date':expenseDate,
    'updated_at':updatedAt

  };
}

}
// 2. Tera Expense Enum (Budget)
enum ExpenseCategory {
  grocery,
  bills,
  transport,
  health,
  shopping,
  household,
  education,
  entertainment,
  others,
}

extension ItemCategoryExtension on ItemCategory {
  ExpenseCategory get toExpenseCategory {
    switch (this) {
      case ItemCategory.grocery:
      case ItemCategory.vegetables:
      case ItemCategory.dairy:
        return ExpenseCategory.grocery;

      case ItemCategory.medicine:
        return ExpenseCategory.health;

      case ItemCategory.personalCare:
        return ExpenseCategory.household;
      case ItemCategory.electronics:
        return ExpenseCategory.shopping;

      case ItemCategory.subscriptions:
        return ExpenseCategory.bills;
      case ItemCategory.documents:
      case ItemCategory.others:
        return ExpenseCategory.others;
    }
  }
}

// Extension to get details for Expense
extension ExpenseCategoryDetails on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.grocery:
        return 'Grocery & Ration';
      case ExpenseCategory.bills:
        return 'Bills & Utilities';
      case ExpenseCategory.transport:
        return 'Transport & Fuel';
      case ExpenseCategory.health:
        return 'Health & Medical';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.household:
        return 'Household & Maintenance';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.entertainment:
        return 'Movies & Fun';
      case ExpenseCategory.others:
        return 'Miscellaneous';
    }
  }

  // 2. Icon (Card aur List ke liye)
  IconData get icon {
    switch (this) {
      case ExpenseCategory.grocery:
        return Icons.local_grocery_store;
      case ExpenseCategory.bills:
        return Icons.receipt_long; // Ya electric_bolt
      case ExpenseCategory.transport:
        return Icons.directions_car; // Ya commute
      case ExpenseCategory.health:
        return Icons.medical_services;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.household:
        return Icons.home_repair_service; // Plumbing/Repair tasks
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.entertainment:
        return Icons.movie; // Ya sports_esports
      case ExpenseCategory.others:
        return Icons.category;
    }
  }

  // 3. Color (Pie Chart aur Icons ke liye)
  Color get color {
    switch (this) {
      case ExpenseCategory.grocery:
        return Colors.green; // Freshness (match with Pantry items)
      case ExpenseCategory.bills:
        return Colors.redAccent; // Urgent/Fixed expense
      case ExpenseCategory.transport:
        return Colors.blue; // Travel standard color
      case ExpenseCategory.health:
        return Colors.teal; // Medical standard
      case ExpenseCategory.shopping:
        return Colors.purpleAccent; // Luxury feel
      case ExpenseCategory.household:
        return Colors.brown; // Maintenance/Earth
      case ExpenseCategory.education:
        return Colors.indigo; // Formal
      case ExpenseCategory.entertainment:
        return Colors.orangeAccent; // Fun/Vibrant
      case ExpenseCategory.others:
        return Colors.grey;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ExpenseCategory.grocery:
        return Colors.green.shade50; // Freshness (match with Pantry items)
      case ExpenseCategory.bills:
        return Colors.red.shade50; // Urgent/Fixed expense
      case ExpenseCategory.transport:
        return Colors.blue.shade50; // Travel standard color
      case ExpenseCategory.health:
        return Colors.teal.shade50; // Medical standard
      case ExpenseCategory.shopping:
        return Colors.purple.shade50; // Luxury feel
      case ExpenseCategory.household:
        return Colors.brown.shade50; // Maintenance/Earth
      case ExpenseCategory.education:
        return Colors.indigo.shade50; // Formal
      case ExpenseCategory.entertainment:
        return Colors.orange.shade50; // Fun/Vibrant
      case ExpenseCategory.others:
        return Colors.white;
    }
  }
}

// Tera Chips Logic for Expense
class ExpenseChipsModel {
  static List<String> get allChips {
    // Pro Tip: Yahan '.name' ki jagah '.label' use kar
    // Taaki Chip pe "grocery" ki jagah "Grocery & Ration" likha aaye.
    List<String> list = ExpenseCategory.values
        .map((cate) => cate.label)
        .toList();

    // 'All' filter ke liye
    list.insert(0, 'All');
    return list;
  }
}
