import 'package:expiry_wise_app/features/voice_command/data/data_source/voice_remote_data_source_interface.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_expense_model.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_item_model.dart';
import 'package:expiry_wise_app/features/voice_command/data/model/ai_quick_list_model.dart';

import '../../domain/voice_command_repository_interface.dart';
import '../model/voice_response_model.dart';

class VoiceCommandRepositoryImpl implements IVoiceCommandRepository{

  const VoiceCommandRepositoryImpl({required this.remoteDataSource});
  final IVoiceRemoteDataSource remoteDataSource;
  @override
  Future<VoiceResponseModel> processCommand({required  command}) async {
    try{
      final data = await remoteDataSource.processCommand(command: command);
      final inventoryItemMap = data['inventory'] as List;
      final expensesMap = data['expense'] as List;
      final quickListMap = data['quick_list'] as List;
      final inventoryItems = inventoryItemMap.map((map) {
        return AiItemModel.fromMap(mapItem: map);
      }).toList();
      final quickList = quickListMap.map((map) {
        return AiQuickListModel.fromMap(mapItem: map);
      }).toList();
      final expenses = expensesMap.map((map) {
        return AiExpenseModel.fromMap(mapItem: map);
      }).toList();
      return VoiceResponseModel(
          expenses: expenses, quickList: quickList, inventory: inventoryItems);
    }catch(e){
      throw e.toString();
    }
  }


}