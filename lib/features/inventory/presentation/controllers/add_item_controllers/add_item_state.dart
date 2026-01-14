import 'package:flutter/material.dart';

class AddItemState {
  final int finished;
  final bool isExpenseLinked;
  final double? price;
  final TextEditingController itemNameController;
  final TextEditingController itemQtyController;
  final String? expiryDate;
  final TextEditingController noteController;
  final String category;
  final String? addedDate;
  final String? image;
  final String? prevImage;
  final String unit;
  final List<int> selectedDays;
  AddItemState( {required this.isExpenseLinked, required this.price,
    required this.finished,
    required this.selectedDays,
    this.image,
    this.prevImage,
    this.expiryDate,
    required this.category,
    this.addedDate,
    TextEditingController? nameController,
    TextEditingController? quantityController,
    TextEditingController? noteController,
    required this.unit,
  }) : itemNameController = nameController ?? TextEditingController(),
       itemQtyController = quantityController ?? TextEditingController(),
       noteController = noteController ?? TextEditingController();

  void dispose() {
    itemNameController.dispose();
    itemQtyController.dispose();
    noteController.dispose();
  }

  factory AddItemState.empty() {
    return AddItemState(category: "grocery", unit: "pcs",selectedDays: [],finished: 0,isExpenseLinked: false,price: null);
  }

  copyWith({String? expiryDate,bool? isExpenseLinked,List<int>? selectedDays, String? category, String? unit,String? image,String? name,String? quantity, double? price}) {
    if(quantity !=null) itemQtyController.text = quantity;
    if(itemQtyController.text.isEmpty) itemQtyController.text = '1';
    if(name!=null) itemNameController.text = name;
    return AddItemState(
      price: price??this.price,
      isExpenseLinked: isExpenseLinked??false,
      finished: finished,
      prevImage: prevImage,
      category: category ?? this.category,
      image: image??this.image,
      expiryDate: expiryDate==null ? this.expiryDate:expiryDate==''?null:expiryDate,
      addedDate: addedDate,
      nameController: itemNameController,
      noteController: noteController,
      quantityController: itemQtyController,
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
    required bool isExpenseLinked,
    required double? price,
    required List<int> selectedDays,
  }) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    noteController.text = note;
    quantityController.text = quantity;
    nameController.text = name;
    return AddItemState(
      price: price,
      isExpenseLinked: isExpenseLinked,
      finished: finished,
      prevImage: prevImage,
      category: category,
      unit: unit,
      nameController: nameController,
      image: image,
      addedDate: addedDate,
      expiryDate: expiryDate,
      noteController: noteController,
      quantityController: quantityController,
      selectedDays: selectedDays,
    );
  }
}
