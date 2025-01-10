import 'dart:async';

import 'package:flutter/material.dart';

import 'manual_stt_service.dart';

/// Listening states for Manual-speech-to-text
enum ManualSttState { listening, paused, stopped }

class ManualSttController {
  late final ManualSttService _sttService;
  final BuildContext context;
  void Function(ManualSttState)? _onListeningStateChanged;
  void Function(String)? _onListeningTextChanged;
  void Function(double)? _onSoundLevelChanged;
  String _finalText = '';
  Timer? _timer;

  /// Defaults to [True]
  bool clearTextOnStart = true;

  /// Constructor to initialize the service and set up callbacks
  ManualSttController(this.context) {
    _initializeService();
  }

  /// initialize the service
  void _initializeService() {
    _sttService = ManualSttService(
      context,
      timer: _timer,
      onTextChanged: (liveText, finalText) {
        _finalText += finalText;
        _onListeningTextChanged?.call(_finalText + liveText);
      },
      onSoundLevelChanged: (level) => _onSoundLevelChanged?.call(level),
      onStateChanged: (state) => _onListeningStateChanged?.call(state),
    );
  }

  /// Listen method to set up callbacks and start listening
  void listen({
    required void Function(ManualSttState)? onListeningStateChanged,
    required void Function(String)? onListeningTextChanged,
    void Function(double)? onSoundLevelChanged,
  }) {
    _onListeningStateChanged = onListeningStateChanged;
    _onListeningTextChanged = onListeningTextChanged;
    _onSoundLevelChanged = onSoundLevelChanged;
  }

  /// handle permanently denied microphone permission
  void handlePermanentlyDeniedPermission(VoidCallback callBack) =>
      _sttService.permanentlyDeniedCallback = callBack;

  // Control methods
  void startStt() {
    if (clearTextOnStart) _finalText = '';
    _sttService.startRecording();
  }

  void stopStt() => _sttService.stopRecording();
  void pauseStt() => _sttService.pauseRecording();
  void resumeStt() => _sttService.resumeRecording();
  void dispose() => _sttService.dispose();

  /// Enable/disable haptic feedback. Defaults to [False]
  set enableHapticFeedback(bool enable) =>
      _sttService.enableHapticFeedback = enable;

  /// [localeId] is an optional locale that can be used to listen in a language other than the current system default.
  /// See [locales] to find the list of supported languages for listening.
  /// Defaults to [null]
  set localId(String localId) => _sttService.localId = localId;

  /// Pause if mute for this duration, after this listening will pause automatically.
  /// Defaults to [Duration(seconds:5)]
  set pauseIfMuteFor(Duration duration) =>
      _sttService.pauseIfMuteFor = duration;

  /// Sample rate, defaults to [0]
  set sampleRate(num sampleRate) => _sttService.sampleRate = sampleRate;

  /// Defaults to ['Microphone Permission Required']
  set permanentDenialDialogTitle(String text) =>
      _sttService.permanentDenialDialogTitle = text;

  /// Defaults to ['This app needs microphone access to perform speech recognition. Please enable it in your device settings.']
  set permanentDenialDialogContent(String text) =>
      _sttService.permanentDenialDialogContent = text;
}
