import 'package:flutter/material.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: ManualSpeechRecognitionExample()));
}

class ManualSpeechRecognitionExample extends StatefulWidget {
  const ManualSpeechRecognitionExample({super.key});

  @override
  State<ManualSpeechRecognitionExample> createState() =>
      _ManualSpeechRecognitionStateExample();
}

class _ManualSpeechRecognitionStateExample
    extends State<ManualSpeechRecognitionExample> {
  late ManualSttController _controller;
  String _finalRecognizedText = '';
  ManualSttState _currentState = ManualSttState.stopped;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = ManualSttController(context);
    _setupController();
  }

  void _setupController() {
    _controller.listen(
      onListeningStateChanged: (state) {
        setState(() => _currentState = state);
      },
      onListeningTextChanged: (recognizedText) {
        setState(() => _finalRecognizedText = recognizedText);
      },
      onSoundLevelChanged: (level) {
        setState(() => _soundLevel = level);
      },
    );

    // Optional: Set language
    _controller.localId = 'en-US';

    // Optional: Enable haptic feedback
    _controller.enableHapticFeedback = true;

    //? Optional: Handle permanently denied microphone permission
    // _controller.handlePermanentlyDeniedPermission(() {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Microphone permission is required')),
    //   );
    // });

    // Optional: Customize Permission Dialog
    // NOTE: if [handlePermanentlyDeniedPermission] this function is used, then below dialog customization won't work.
    _controller.permanentDenialDialogTitle = 'Microphone Access Required';
    _controller.permanentDenialDialogContent =
        'Speech-to-text functionality needs microphone permission.';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manual Speech Recognition")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('State: ${_currentState.name}'),
            const SizedBox(height: 16),
            Text(
              'Final Recognized Text: $_finalRecognizedText',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _soundLevel),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentState == ManualSttState.stopped
                      ? _controller.startStt
                      : null,
                  child: const Text(
                    'Start',
                  ),
                ),
                ElevatedButton(
                  onPressed: _currentState == ManualSttState.listening
                      ? _controller.pauseStt
                      : _currentState == ManualSttState.paused
                          ? _controller.resumeStt
                          : null,
                  child: Text(_currentState == ManualSttState.paused
                      ? 'Resume'
                      : 'Pause'),
                ),
                ElevatedButton(
                  onPressed: _currentState != ManualSttState.stopped
                      ? _controller.stopStt
                      : null,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
