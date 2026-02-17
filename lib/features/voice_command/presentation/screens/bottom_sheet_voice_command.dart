import 'package:expiry_wise_app/features/voice_command/presentation/controller/voice_command_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/theme/colors.dart';

class BottomSheetMic extends ConsumerStatefulWidget {
  const BottomSheetMic({super.key});

  @override
  ConsumerState<BottomSheetMic> createState() {
    return _BottomSheetMic();
  }
}

class _BottomSheetMic extends ConsumerState<BottomSheetMic> {
  late SpeechToText stt;
  bool _isSpeechInitialized = false;

  @override
  void initState() {
    super.initState();
    stt = SpeechToText();
    Future.microtask(() async {
      if (!mounted) return;
      _isSpeechInitialized = await stt.initialize(
        onError: (e) => debugPrint('STT Error: $e'),
      );
    });
  }

  @override
  void dispose() {
    stt.cancel();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_isSpeechInitialized) return;
    ref.read(voiceCommandControllerProvider.notifier).startListen();
    final available = await stt.hasPermission;
    if (available && mounted) {
      await stt.listen(
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 30),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: true,
        ),
        onResult: (result) {
          if (mounted) {
            ref
                .read(voiceCommandControllerProvider.notifier)
                .addIntoCommand(result.recognizedWords);
          }
        },
      );
    }
  }

  Future<void> close() async {
    await stt.stop();
    if (mounted) {
      await ref.read(voiceCommandControllerProvider.notifier).close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      voiceCommandControllerProvider.select((s) => s.isLoading),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Prevents taking up full screen
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 60,
                    child: Icon(
                      Icons.mic,
                      size: 50,
                      color: EColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: Consumer(
                      builder: (_, ref, __) {
                        final speech = ref
                            .watch(voiceCommandControllerProvider)
                            .command;
                        return Text(
                          (speech == null || speech.isEmpty)
                              ? 'e.g. "I bought half litre milk"'
                              : speech,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                          maxLines: 5,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer(
                    builder: (_, ref, __) {
                      final command = ref.watch(
                        voiceCommandControllerProvider.select((s) => s.command),
                      );

                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _startListening,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: EColors.primaryDark,
                                side: const BorderSide(color: Colors.grey),
                              ),
                              child: ((command == null))
                                  ? const Text('Start')
                                  : const Text('Start Again'),
                            ),
                          ),
                          if ((command != null && command.isNotEmpty))
                            const SizedBox(width: 8),
                          if ((command != null && command.isNotEmpty))
                            Expanded(
                              child: ElevatedButton(
                                onPressed: close,
                                child: const Text('Save'),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
