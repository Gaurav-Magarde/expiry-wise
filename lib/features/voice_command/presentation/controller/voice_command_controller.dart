import 'package:expiry_wise_app/core/utils/snackbars/snack_bar_service.dart';
import 'package:expiry_wise_app/features/Space/presentation/controllers/current_space_provider.dart';
import 'package:expiry_wise_app/features/User/presentation/controllers/user_controller.dart';
import 'package:expiry_wise_app/features/expenses/data/repository/expense_repository.dart';
import 'package:expiry_wise_app/features/expenses/presentation/controllers/services/expense_services.dart';
import 'package:expiry_wise_app/features/inventory/data/repository/item_repository_impl.dart';
import 'package:expiry_wise_app/features/inventory/presentation/controllers/services/item_services.dart';
import 'package:expiry_wise_app/features/quick_list/data/repository/quick_list_repository_impl.dart';
import 'package:expiry_wise_app/features/quick_list/presentation/controllers/services/quick_list.dart';
import 'package:expiry_wise_app/features/voice_command/domain/voice_command_repository_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../data/model/voice_response_model.dart';

final speechToTextInstance = Provider<SpeechToText>((ref) => SpeechToText());

final voiceCommandControllerProvider =
NotifierProvider.autoDispose<VoiceCommandController, VoiceCommandState>(
      () => VoiceCommandController(),
);

class VoiceCommandController extends Notifier<VoiceCommandState> {
  @override
  VoiceCommandState build() {
    return VoiceCommandState(
      isLoading: false,
      isListening: false,
      command: null,
    );
  }

  void resetState() {
    state = VoiceCommandState(isLoading: false, isListening: false, command: null);
  }

  void addIntoCommand(String command) {
    state = state.copyWith(command: command);
  }

  void listeningEnded() {
    state = state.copyWith(isListening: false);
  }

  Future<void> close() async {
    if (state.command != null && state.command!.isNotEmpty) {
      await processCommand();
    }
    state = state.copyWith(command: '', isListening: false, isLoading: false);
  }

  Future<void> processCommand() async {
    final command = state.command ?? '';
    state = state.copyWith(isLoading: true, isListening: false);
    try {
      final user = ref.read(currentUserProvider).value;
      final space = ref.read(currentSpaceProvider).value;
      if(space==null) return;
      final expenseServices = ref.read(expenseServiceProvider);
      final quickListServices = ref.read(quickListServiceProvider);
      final itemServices = ref.read(inventoryServiceProvider);

      final VoiceResponseModel response =
      await ref.read(voiceCommandRepositoryProvider).processCommand(command: command);

      await expenseServices.addItemFromVoiceCommandUseCase(
          expenses: response.expenses, space: space, user: user);
      await itemServices.addItemFromVoiceCommand(
          items: response.inventory, user: user, space: space);
      await quickListServices.addItemFromVoiceCommand(
          items: response.quickList, user: user, space: space);
      ref.read(inventoryRepoProvider).refreshItems(spaceId: space.id);
      ref.read(expenseRepositoryProvider).refreshExpenses(space.id);
      ref.read(quickListRepoProvider).refreshList(spaceId: space.id);
    } catch (e) {
      SnackBarService.showMessage(e.toString());
    } finally {
      state = state.copyWith(isLoading: false, isListening: false);
    }
  }

  void startListen() {
    state = state.copyWith(command: '');
  }
}

class VoiceCommandState {
  final String? command;
  final bool isLoading;
  final bool isListening;

  VoiceCommandState({
    required this.isLoading,
    required this.isListening,
    required this.command,
  });

  VoiceCommandState copyWith({
    String? command,
    bool? isLoading,
    bool? isListening,
  }) {
    return VoiceCommandState(
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      command: command ?? this.command,
    );
  }
}