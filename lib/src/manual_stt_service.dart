import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ManualSttService {
  final void Function(String, String) onTextChanged;
  final void Function(double) onSoundLevelChanged;
  final void Function(ManualSttState) onStateChanged;
  void Function()? permanentlyDeniedCallback;
  final bool enableHapticFeedback;
  final BuildContext context;

  /// [localeId] is an optional locale that can be used to listen in a language other than the current system default.
  /// See [locales] to find the list of supported languages for listening.
  final String? localId;

  final SpeechToText _speechToText = SpeechToText();
  final num sampleRate;
  bool _isInitialized = false;
  ManualSttService(
    this.context, {
    required this.onTextChanged,
    required this.onSoundLevelChanged,
    required this.onStateChanged,
    required this.enableHapticFeedback,
    this.permanentlyDeniedCallback,
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
    switch (status) {
      case PermissionStatus.granted:
        log('Microphone permission granted');
        return true;
      case PermissionStatus.denied:
        log('Microphone permission denied');
        return false;
      case PermissionStatus.permanentlyDenied:
        log('Microphone permission permanently denied');
        if (permanentlyDeniedCallback != null) {
          permanentlyDeniedCallback!();
          return false;
        }
        _handlePermantlyDeniedPermission();
        return false;
      case PermissionStatus.restricted:
        log('Microphone permission restricted');
        return false;
      case PermissionStatus.limited:
        log('Microphone permission limited');
        return true;
      default:
        return false;
    }
  }

  Future<void> startRecording() async {
    if (!await _initializeStt()) {
      onStateChanged(ManualSttState.stopped);
      return;
    }

    onStateChanged(ManualSttState.listening);
    // var manualTextResult = '';
    await _speechToText.listen(
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        autoPunctuation: false,
        enableHapticFeedback: enableHapticFeedback,
        sampleRate: sampleRate.toDouble(),
      ),
      onResult: (result) {
        // emitting live text
        onTextChanged('${result.recognizedWords} ', '');
        // emitting final text
        if (result.finalResult) {
          onTextChanged('', '${result.recognizedWords} ');
        }
        // Restart listening if it was interrupted
        if (!_speechToText.isListening && result.finalResult) {
          startRecording();
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

// handle permission when it is permanently denied
  void _handlePermantlyDeniedPermission() {
    onStateChanged(ManualSttState.stopped);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
            'This app needs microphone access to perform speech recognition. Please enable it in your device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
