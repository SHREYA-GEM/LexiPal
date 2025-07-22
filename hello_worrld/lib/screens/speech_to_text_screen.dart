// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';

// class SpeechToTextScreen extends StatefulWidget {
//   @override
//   _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
// }

// class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
//   late stt.SpeechToText _speechToText;
//   bool _isListening = false;
//   String _text = "Press the button and start speaking...";
//   bool _speechAvailable = false;

//   @override
//   void initState() {
//     super.initState();
//     _speechToText = stt.SpeechToText();
//     _checkMicrophonePermissionAndInitialize();
//   }

//   Future<void> _checkMicrophonePermissionAndInitialize() async {
//     var status = await Permission.microphone.request();
//     if (status.isGranted) {
//       bool available = await _speechToText.initialize(
//         onStatus: (status) => print('Speech status: $status'),
//         onError: (error) => print('Speech error: $error'),
//       );
//       setState(() {
//         _speechAvailable = available;
//       });
//     } else {
//       setState(() {
//         _text = "Microphone permission denied. Please enable it in settings.";
//       });
//     }
//   }

//   void _toggleListening() async {
//     if (!_speechAvailable) {
//       setState(() {
//         _text = "Speech recognition is not available on this device.";
//       });
//       return;
//     }

//     if (!_isListening) {
//       setState(() {
//         _text = "Listening...";
//       });
//       _speechToText.listen(onResult: (result) {
//         setState(() {
//           _text = result.recognizedWords;
//         });
//       });
//       setState(() {
//         _isListening = true;
//       });
//     } else {
//       setState(() {
//         _text = "Stopped listening.";
//         _isListening = false;
//       });
//       _speechToText.stop();
//     }
//   }

//   // Method to save text to a file
//   Future<void> _saveTextToFile() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/recognized_text.txt');
//     await file.writeAsString(_text);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Text saved to ${file.path}')),
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _speechToText.stop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speech to Text'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _text,
//               style: TextStyle(fontSize: 20),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: _toggleListening,
//                   child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
//                 ),
//                 SizedBox(width: 10),
//                 ElevatedButton(
//                   onPressed: _saveTextToFile,
//                   child: Text('Save to File'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:io';

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _text = "Press the button and start speaking...";
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _checkMicrophonePermissionAndInitialize();
  }

  Future<void> _checkMicrophonePermissionAndInitialize() async {
    var micStatus = await Permission.microphone.request();
    if (micStatus.isGranted) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      setState(() {
        _speechAvailable = available;
      });
    } else {
      setState(() {
        _text = "Microphone permission denied. Please enable it in settings.";
      });
    }
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      setState(() {
        _text = "Speech recognition is not available on this device.";
      });
      return;
    }

    if (!_isListening) {
      setState(() {
        _text = "Listening...";
      });
      _speechToText.listen(onResult: (result) {
        setState(() {
          _text = result.recognizedWords;
        });
      });
      setState(() {
        _isListening = true;
      });
    } else {
      setState(() {
        _text = "Stopped listening.";
        _isListening = false;
      });
      _speechToText.stop();
    }
  }

  // Save text to Downloads directory
  Future<void> _saveTextToFile() async {
    var storageStatus = await Permission.manageExternalStorage.request();

    if (!storageStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied. Please enable it from settings.')),
      );
      return;
    }

    final downloadsDir = Directory('/storage/emulated/0/Download');

    if (await downloadsDir.exists()) {
      final file = File('${downloadsDir.path}/recognized_text.txt');
      await file.writeAsString(_text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Text saved to ${file.path}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloads directory not found.')),
      );
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _text,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleListening,
                  child: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveTextToFile,
                  child: Text('Save to File'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
