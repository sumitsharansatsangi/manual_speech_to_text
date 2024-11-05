import 'dart:developer';

import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ManualSttService {
  final void Function(String) onTextChanged;
  final void Function(double) onSoundLevelChanged;
  final void Function(ManualSttState) onStateChanged;
  final bool enableHapticFeedback;

  /// [localeId] is an optional locale that can be used to listen in a language other than the current system default.
  /// See [locales] to find the list of supported languages for listening.
  final String? localId;

  final SpeechToText _speechToText = SpeechToText();
  final num sampleRate;
  bool _isInitialized = false;

  ManualSttService({
    required this.onTextChanged,
    required this.onSoundLevelChanged,
    required this.onStateChanged,
    required this.enableHapticFeedback,
    this.localId,
    this.sampleRate = 0,
  });

  Future<bool> _initializeStt() async {
    if (!await _checkPermission()) {
      onStateChanged(ManualSttState.stopped);
      return false;
    }
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) {
          // Restart listening if the error is permanent
          if (error.permanent) {
            startRecording();
          }
        },
        finalTimeout: const Duration(seconds: 5),
      );
      return _isInitialized;
    } catch (e, s) {
      log('Error initializing STT: $e\n$s');
      return false;
    }
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      log('Microphone permission granted');
      return true;
    }
    log('Microphone permission denied');
    return false;
  }

  Future<void> startRecording() async {
    if (!await _initializeStt()) {
      onStateChanged(ManualSttState.stopped);
      return;
    }

    onStateChanged(ManualSttState.listening);

    await _speechToText.listen(
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        autoPunctuation: false,
        enableHapticFeedback: enableHapticFeedback,
        sampleRate: sampleRate.toDouble(),
      ),
      onResult: (result) {
        if (result.finalResult) {
          onTextChanged('${result.recognizedWords} ');
        }
        if (!_speechToText.isListening && result.finalResult) {
          startRecording(); // Restart listening if it was interrupted
        }
      },
      onSoundLevelChange: onSoundLevelChanged,
      localeId: localId,
    );
  }

  Future<void> stopRecording() async {
    await _speechToText.stop();
    onStateChanged(ManualSttState.stopped);
    onSoundLevelChanged(0);
  }

  Future<void> pauseRecording() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      onStateChanged(ManualSttState.paused);
    }
  }

  Future<void> resumeRecording() async {
    if (!_speechToText.isListening) {
      onStateChanged(ManualSttState.listening);
      await startRecording();
    }
  }

  Future<void> dispose() async {
    await _speechToText.stop();
    _isInitialized = false;
  }
}
