import 'package:expiry_wise_app/features/voice_command/data/data_source/voice_remote_data_source_interface.dart';
import 'package:expiry_wise_app/features/voice_command/data/repository/voice_command_repo_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart%20%20';

import '../data/model/voice_response_model.dart';

abstract interface class IVoiceCommandRepository{
  Future<VoiceResponseModel> processCommand({required String command});
}

final voiceCommandRepositoryProvider = Provider<IVoiceCommandRepository>((ref){
  final remoteDataSource = ref.read(voiceRemoteProvider);
  return VoiceCommandRepositoryImpl(remoteDataSource: remoteDataSource);
});