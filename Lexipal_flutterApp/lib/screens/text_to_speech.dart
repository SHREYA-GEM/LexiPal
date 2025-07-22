import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

class TextToSpeechScreen extends StatefulWidget {
  @override
  _TextToSpeechScreenState createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  String _recognizedText = "Text will appear here after recognition.";
  bool _isProcessing = false;

  // Function to capture or pick an image
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      _performOCR(File(image.path));
    }
  }

  // Function to perform OCR using Google ML Kit
  Future<void> _performOCR(File imageFile) async {
    setState(() {
      _isProcessing = true;
      _recognizedText = "Processing image...";
    });

    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        _recognizedText = recognizedText.text.isNotEmpty
            ? recognizedText.text
            : "No text found.";
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _recognizedText = "Failed to recognize text.";
        _isProcessing = false;
      });
    } finally {
      textRecognizer.close();
    }
  }

  // Function to read text aloud using TTS
  Future<void> _speak() async {
    if (_recognizedText.isNotEmpty && _recognizedText != "No text found.") {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.speak(_recognizedText);
    }
  }

  // Function to stop TTS
  Future<void> _stop() async {
    await _flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OCR & Text-to-Speech"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _recognizedText,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "OpenDyslexic", // Apply the Open Dyslexic font
                  ),
                ),
              ),
            ),
            if (_isProcessing)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.image),
                        label: Text("Pick Image"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera),
                        label: Text("Capture Image"),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Spacing between the two rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _speak,
                        icon: Icon(Icons.volume_up),
                        label: Text("Text to Audio"),
                      ),
                      ElevatedButton.icon(
                        onPressed: _stop,
                        icon: Icon(Icons.stop),
                        label: Text("Stop"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
