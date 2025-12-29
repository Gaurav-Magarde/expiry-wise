import 'package:flutter/material.dart';

class AddItemState {
  final TextEditingController itemNameController;
  final TextEditingController itemQtyController;
  final String? expiryDate;
  final TextEditingController noteController;
  final String category;
  final String? addedDate;
  final String? image;
  final String? prevImage;
  final String unit;

  AddItemState( {
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
    return AddItemState(category: "grocery", unit: "pcs");
  }

  copyWith({String? expiryDate, String? category, String? unit,String? image,String? name,String? quantity}) {
    if(quantity!=null) itemQtyController.text = quantity;
    if(name!=null) itemNameController.text = name;
    return AddItemState(
      prevImage: prevImage,
      category: category ?? this.category,
      image: image??this.image,
      expiryDate: expiryDate ?? this.expiryDate,
      addedDate: addedDate,
      nameController: itemNameController,
      noteController: noteController,
      quantityController: itemQtyController,
      unit: unit ?? this.unit,
    );
  }

  factory AddItemState.newStateByParameter({
    required String image,
    required String prevImage,
    required String unit,
    required String name,
    required String quantity,
    required String category,
    required String note,
    required String addedDate,
    required String expiryDate,
  }) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final noteController = TextEditingController();
    noteController.text = note;
    quantityController.text = quantity;
    nameController.text = name;
    return AddItemState(
      prevImage: prevImage,
      category: category,
      unit: unit,
      nameController: nameController,
      image: image,
      addedDate: addedDate,
      expiryDate: expiryDate,
      noteController: noteController,
      quantityController: quantityController,
    );
  }
}
