import 'package:expiry_wise_app/features/voice_command/data/model/ai_expense_model.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_item_model.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_quick_list_model.dart';

class VoiceResponseModel{
  final List<AiExpenseModel> expenses;
  final List<AiQuickListModel> quickList;
  final List<AiItemModel> inventory;

  VoiceResponseModel({required this.expenses,required this.quickList,required this.inventory});
}