# manual_speech_to_text

[![pub package](https://img.shields.io/pub/v/manual_speech_to_text.svg)](https://pub.dev/packages/manual_speech_to_text)

A Flutter plugin that enhances the standard speech-to-text functionality by providing manual control over speech recognition, including pause and resume capabilities, and improved continuous listening. This package addresses common issues like automatic stopping during silence and lack of manual control in the standard speech-to-text implementation.

## Author

Sagar Kalel

- ✉️ [Email](sagarkalel4141@gmail.com)
- 👔 [LinkedIn](https://www.linkedin.com/in/sagar-kalel-06207a1b0?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=android_app)
- 💻 [Github](https://github.com/sagarkalel)
- 📸 [Instagram](https://www.instagram.com/kalel337/?utm_source=qr&igsh=NHpyaXZ2ZHE1dGk0)

## Features

- 🎯 **Manual Control**: Full control over the speech recognition process with start, stop, pause, and resume capabilities
- 🔄 **Continuous Listening**: Automatically restarts listening if interrupted, ensuring no speech is missed
- 📢 **Sound Level Monitoring**: Track sound levels during speech recognition
- 🌍 **Language Support**: Option to specify custom locale for recognition
- 📱 **Platform Support**:
  - ✅ Android
  - 🚧 iOS (Coming Soon)

## Quick Start

```dart
final controller = ManualSttController();

// Set up listeners
controller.listen(
  onListeningStateChanged: (state) => print('State: $state'),
  onListeningTextChanged: (text) => print('Text: $text'),
  onSoundLevelChanged: (level) => print('Level: $level'),
);

// Start recognition
controller.startStt();
```

## Comparison with Standard speech_to_text

| Feature                   | manual_speech_to_text | speech_to_text |
| ------------------------- | --------------------- | -------------- |
| Pause/Resume              | ✅                    | ❌             |
| Continuous Listening      | ✅                    | ❌             |
| Sound Level Monitoring    | ✅                    | ✅             |
| Manual Control            | ✅                    | Limited        |
| Auto-restart on interrupt | ✅                    | ❌             |

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  manual_speech_to_text: ^1.0.0
```

### Dependencies

This package depends on the following packages:

```yaml
dependencies:
  permission_handler: ^[latest_version]
  speech_to_text: ^[latest_version]
```

### Android Setup

Add the following permission to your Android Manifest (`android/app/src/main/AndroidManifest.xml`):

```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.BLUETOOTH"/>
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
  <!-- other tags -->
  <queries>
      <intent>
          <action android:name="android.speech.RecognitionService" />
      </intent>
  </queries>
```

## Usage

### Basic Implementation

```dart
import 'package:manual_speech_to_text/manual_speech_to_text.dart';

void main() {
  final controller = ManualSttController();

  // Set up listeners
  controller.listen(
    onListeningStateChanged: (ManualSttState state) {
      print('State changed to: $state');
    },
    onListeningTextChanged: (String text) {
      print('Recognized text: $text');
    },
    onSoundLevelChanged: (double level) {
      print('Sound level: $level');
    },
  );

  // Start listening
  controller.startStt();

  // Pause recognition
  controller.pauseStt();

  // Resume recognition
  controller.resumeStt();

  // Stop recognition
  controller.stopStt();

  // Don't forget to dispose when done
  controller.dispose();
}
```

### Complete Example

```dart

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

    // Optional: Handle permanently denied microphone permission
    _controller.handlePermanentlyDeniedPermission(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    });

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

```

## API Reference

### ManualSttController

The main controller class for managing speech recognition.

#### Methods

- `listen({required onListeningStateChanged, required onListeningTextChanged, onSoundLevelChanged})`: Set up callbacks for state changes, text recognition, and sound level monitoring
- `startStt()`: Start speech recognition
- `stopStt()`: Stop speech recognition
- `pauseStt()`: Pause speech recognition
- `resumeStt()`: Resume paused speech recognition
- `dispose()`: Clean up resources

#### Properties

- `enableHapticFeedback`: Enable/disable haptic feedback during recognition
- `localId`: Set the locale for speech recognition (e.g., 'en-US')
- `handlePermanentlyDeniedPermission`: Handle Permanently denied microphone permission
- `permanentDenialDialogTitle` : Set the title of the permanent denialization dialog
- `permanentDenialDialogContent` : Set the content of the permanent denialization dialog

### ManualSttState

Enum representing the possible states of speech recognition:

```dart
enum ManualSttState {
  listening,  // Currently listening for speech
  paused,     // Recognition is paused
  stopped     // Recognition is stopped
}
```

## Permission Handling

### Automatic Microphone Permission

The package now includes built-in microphone permission handling:

- Automatically requests microphone permission when speech-to-text is initiated
- Handles first-time and permanent permission denials
- Provides a custom dialog for permanently denied permissions

#### Permanent Permission Denial Handling

If microphone permission is permanently denied, the package:

- Displays a dialog explaining the necessity of microphone access
- Offers a direct link to app settings
- Provides a default callback for custom handling

Example of custom permission handling:

```dart
// Optional: Handle permanently denied microphone permission
    _controller.handlePermanentlyDeniedPermission(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required')),
      );
    });
```

### Customizing Permission Dialog

```dart
_controller.permanentDenialDialogTitle = 'Microphone Access Required';
_controller.permanentDenialDialogContent = 'Speech-to-text functionality needs microphone permission.';
```

### Manifest Configuration

Ensure your Android Manifest (`android/app/src/main/AndroidManifest.xml`) includes:

```xml
  <uses-permission android:name="android.permission.RECORD_AUDIO"/>
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.BLUETOOTH"/>
  <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
  <!-- other tags -->
  <queries>
      <intent>
          <action android:name="android.speech.RecognitionService" />
      </intent>
  </queries>

```

## Best Practices

1. **State Management**

   ```dart
   // Always check state before operations
   if (_currentState != ManualSttState.stopped) {
     await controller.stopStt();
   }
   ```

2. **Resource Management**

   ```dart
   // Proper disposal in StatefulWidget
   @override
   void dispose() {
     controller.dispose();
     super.dispose();
   }
   ```

3. **Error Handling**
   ```dart
   try {
     await controller.startStt();
   } catch (e) {
     print('Speech recognition error: $e');
     // Handle error appropriately
   }
   ```

## Platform-Specific Notes

### Android

- Minimum SDK version: 21
- Requires Google Play Services for speech recognition
- Works offline for some languages (device-dependent)

### iOS (Coming Soon)

## Troubleshooting

### Common Issues

1. **Microphone Permission**

   - Ensure you've added the RECORD_AUDIO permission in AndroidManifest.xml
   - Ensure you've added `<action android:name="android.speech.RecognitionService" />` tag in AndroidManifest.xml between proper tags
   - The package handles permission requests, but you might need to handle denied permissions in your app

2. **Recognition Stops Unexpectedly**

   - Check if the device is online
   - Verify that the locale is properly set
   - Ensure the app has proper permissions

3. **Recognition Quality Issues**

   - Ensure proper microphone proximity
   - Check for background noise interference
   - Verify language settings match spoken language

4. **Performance Optimization**
   - Consider enabling haptic feedback for better user experience
   - Implement error handling for network connectivity issues
   - Clear disposed controllers to prevent memory leaks

### Note:

- For initial setup, if you need more information, please follow the instructions from the documentation of standard [speech_to_text](https://pub.dev/packages/speech_to_text).
- If you encounter any challenges or need additional troubleshooting help, don't forget to refer to the standard [speech_to_text](https://pub.dev/packages/speech_to_text) package for more insights and best practices.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.

## Credits

This package builds upon the [speech_to_text](https://pub.dev/packages/speech_to_text) package, adding manual control and continuous listening capabilities.
