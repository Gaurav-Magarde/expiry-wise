import 'package:expiry_wise_app/features/inventory/data/models/category_helper_model.dart';

class AiQuickListModel{
  final String title;
  AiQuickListModel({required this.title,});

  factory AiQuickListModel.fromMap({required Map<String,dynamic> mapItem}){
    return AiQuickListModel( title: mapItem['title']);
  }
}