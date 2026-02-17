import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:expiry_wise_app/features/voice_command/data/data_source/voice_remote_data_source_interface.dart';

class GeminiRemoteDataSource implements IVoiceRemoteDataSource{

  final GenerativeModel model;
  GeminiRemoteDataSource(this.model);
  @override
  Future<Map<String,dynamic>> processCommand({required String command})async {
    final content = [Content.text(command)];
    try{
      final response = await model.generateContent(content);
    final rawText = response.text??'';
    String cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    Map<String, dynamic> data = jsonDecode(cleanJson);
    return data;
    }catch(e){
      rethrow;
    }
  }
}
