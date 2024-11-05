import 'manual_stt_service.dart';

/// Listening states for Manual-speech-to-text
enum ManualSttState { listening, paused, stopped }

class ManualSttController {
  late final ManualSttService _sttService;
  void Function(ManualSttState)? _onListeningStateChanged;
  void Function(String)? _onListeningTextChanged;
  void Function(double)? _onSoundLevelChanged;
  // Enable haptic feedback by default
  bool _enableHapticFeedback = false;
  String? _localId;

  /// Constructor to initialize the service and set up callbacks
  ManualSttController() {
    _sttService = ManualSttService(
      onTextChanged: (String text) {
        _onListeningTextChanged?.call(text);
      },
      onSoundLevelChanged: (double level) {
        _onSoundLevelChanged?.call(level);
      },
      onStateChanged: (ManualSttState state) {
        _onListeningStateChanged?.call(state);
      },
      enableHapticFeedback: _enableHapticFeedback,
      localId: _localId,
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

  // Control methods
  void startStt() => _sttService.startRecording();
  void stopStt() => _sttService.stopRecording();
  void pauseStt() => _sttService.pauseRecording();
  void resumeStt() => _sttService.resumeRecording();
  void dispose() => _sttService.dispose();

  /// Enable/disable haptic feedback
  set enableHapticFeedback(bool enable) {
    _enableHapticFeedback = enable;
  }

  /// [localeId] is an optional locale that can be used to listen in a language other than the current system default.
  /// See [locales] to find the list of supported languages for listening.
  set localId(String localId) {
    _localId = localId;
  }
}
