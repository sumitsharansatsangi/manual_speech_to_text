import 'package:flutter/material.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';

void main(List<String> args) {
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
  String _recognizedText = '';
  ManualSttState _currentState = ManualSttState.stopped;
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = ManualSttController();
    _setupController();
  }

  void _setupController() {
    _controller.listen(
      onListeningStateChanged: (state) {
        setState(() => _currentState = state);
      },
      onListeningTextChanged: (text) {
        setState(() => _recognizedText += text);
      },
      onSoundLevelChanged: (level) {
        setState(() => _soundLevel = level);
      },
    );

    // Optional: Set language
    _controller.localId = 'en-US';

    // Optional: Enable haptic feedback
    _controller.enableHapticFeedback = true;
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
            Text('State: $_currentState'),
            const SizedBox(height: 16),
            Text('Recognized: $_recognizedText'),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _soundLevel),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentState == ManualSttState.stopped
                      ? () {
                          // clearing intial recognized text
                          _recognizedText = '';
                          _controller.startStt();
                        }
                      : null,
                  child: const Text('Start'),
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
