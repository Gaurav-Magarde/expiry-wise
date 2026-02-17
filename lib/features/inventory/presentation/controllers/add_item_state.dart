import 'package:expiry_wise_app/features/inventory/domain/item_model.dart';
import 'package:flutter/material.dart';

class AddItemState {
  final int finished;
  final bool isExpenseLinked;
  final double? price;
  final String? itemName;
  final String? scannedBarcode;
  final String? itemQty;
  final String? expiryDate;
  final String? note;
  final String category;
  final String? addedDate;
  final String? image;
  final String? prevImage;
  final bool isItemEditing;
  final bool isSaving;
  final String unit;
  final List<int> selectedDays;
  AddItemState( {this.itemName,this.scannedBarcode, this.itemQty, this.note, required this.isExpenseLinked, required this.isItemEditing, required this.price,
    required this.finished,
    required this.isSaving,
    required this.selectedDays,
    this.image,
    this.prevImage,
    this.expiryDate,
    required this.category,
    this.addedDate,
    required this.unit,
  }) ;
  factory AddItemState.empty() {
    return AddItemState(category: 'grocery', unit: 'pcs',selectedDays: [],finished: 0,isExpenseLinked: false,price: null,isItemEditing: false, isSaving: false);
  }

  AddItemState copyWith({String? expiryDate,bool? isSaving,String? scannedBarcode,bool? isExpenseLinked,List<int>? selectedDays, String? category, String? unit,String? image,String? name,String? note,String? quantity, double? price}) {
    return AddItemState(
      scannedBarcode: scannedBarcode??this.scannedBarcode,
      isItemEditing: isItemEditing,
      isSaving: isSaving??this.isSaving,
      price: price??this.price,
      isExpenseLinked: isExpenseLinked??this.isExpenseLinked,
      finished: finished,
      prevImage: prevImage,
      category: category ?? this.category,
      image: image??this.image,
      expiryDate: expiryDate==null ? this.expiryDate:expiryDate==''?null:expiryDate,
      addedDate: addedDate,
      itemName: name??itemName,
      note: note??this.note,
      itemQty: quantity??itemQty,
      unit: unit ?? this.unit,
      selectedDays: selectedDays??this.selectedDays,
    );
  }

  factory AddItemState.newStateByParameter({
    required int finished,
    required String image,
    required String prevImage,
    required String unit,
    required String name,
    required String quantity,
    required String category,
    required String note,
    required String addedDate,
    required String? expiryDate,
    required String? scannedBarcode,
    required bool isExpenseLinked,
    required bool isItemEditing,
    required double? price,
    required List<int> selectedDays,
    required bool isSaving,
  }) {
    return AddItemState(
      scannedBarcode: scannedBarcode,
      isItemEditing: isItemEditing,
      isSaving: isSaving,
      price: price,
      isExpenseLinked: isExpenseLinked,
      finished: finished,
      prevImage: prevImage,
      category: category,
      unit: unit,
      itemName: name,
      image: image,
      addedDate: addedDate,
      expiryDate: expiryDate,
      note: note,
      itemQty: quantity,
      selectedDays: selectedDays,
    );
  }

  factory AddItemState.newStateByItem({
    required ItemModel item,
  }) {
    return AddItemState(
      scannedBarcode: null,
      isItemEditing: true,
      price: item.price,
      isExpenseLinked: item.isExpenseLinked==null?false:item.isExpenseLinked!,
      finished: item.finished,
      prevImage: item.image,
      category: item.category,
      unit: item.unit,
      itemName: item.name,
      image: item.image,
      addedDate: item.addedDate,
      expiryDate: item.expiryDate,
      note: item.note,
      itemQty: item.quantity.toString(),
      selectedDays: item.notifyConfig, isSaving: false,
    );
  }
}
