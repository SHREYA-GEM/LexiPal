



import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';



class GazeTrackingScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const GazeTrackingScreen({super.key, required this.cameras});

  @override
  GazeTrackingScreenState createState() => GazeTrackingScreenState();
}

class GazeTrackingScreenState extends State<GazeTrackingScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  final WebSocketChannel _channel = WebSocketChannel.connect(Uri.parse("ws://172.20.10.13:5000"));
  bool _isSending = false;
  int _selectedCameraIndex = 0;
  double? _gazeX, _gazeY;
  double? _globalGazeX, _globalGazeY;
  String extractedText = "";
  List<Map<String, dynamic>> wordWidgets = [];
  String? highlightedWord;
  final GlobalKey _scrollKey = GlobalKey();
  final GlobalKey _cameraKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera().then((_) => startCapturing());
    listenToServer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (_controller != null) await _controller!.dispose();
      if (widget.cameras.isEmpty) return;
      final camera = widget.cameras[_selectedCameraIndex];
      _controller = CameraController(camera, ResolutionPreset.low);
      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      developer.log("Camera initialization failed: $e");
    }
  }

  void _toggleCamera() async {
    if (widget.cameras.length < 2) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % widget.cameras.length;
    });
    await _initializeCamera();
  }

  void startCapturing() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (mounted) {
        await _captureAndSendImage();
        startCapturing();
      }
    });
  }

  Future<void> _captureAndSendImage() async {
    if (_controller == null || !_controller!.value.isInitialized || _isSending) return;
    _isSending = true;
    try {
      XFile file = await _controller!.takePicture();
      Uint8List imageData = await file.readAsBytes();
      Uint8List resizedImage = await compute(_resizeImage, imageData);
      String base64Image = base64Encode(resizedImage);
      _channel.sink.add(jsonEncode({"image": base64Image}));
    } catch (e) {
      developer.log("Error sending image: $e");
    } finally {
      _isSending = false;
    }
  }

  static Uint8List _resizeImage(Uint8List imageData) {
    img.Image? original = img.decodeImage(imageData);
    if (original == null) return imageData;
    img.Image resized = img.copyResize(original, width: 224, height: 224);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 70));
  }

  void listenToServer() {
    _channel.stream.listen((message) {
      Map<String, dynamic> data = jsonDecode(message);
      double gazeX = (data["gaze_x"] as num?)?.toDouble() ?? 0;
      double gazeY = (data["gaze_y"] as num?)?.toDouble() ?? 0;

      setState(() {
        _globalGazeX = gazeX;
        _globalGazeY = gazeY;
      });

      if (extractedText.isEmpty) {
        final cameraContext = _cameraKey.currentContext;
        if (cameraContext != null) {
          final cameraBox = cameraContext.findRenderObject() as RenderBox;
          final position = cameraBox.localToGlobal(Offset.zero);

          setState(() {
            _gazeX = gazeX - position.dx;
            _gazeY = gazeY - position.dy;
          });
        }
      } else {
        setState(() {
          _gazeX = gazeX;
          _gazeY = gazeY;
          highlightedWord = null;

          for (var entry in wordWidgets) {
            final key = entry["key"] as GlobalKey;
            final context = key.currentContext;
            if (context != null) {
              final box = context.findRenderObject() as RenderBox;

              // Get accurate global position using getTransformTo(null)
              final transform = box.getTransformTo(null);
              final translation = transform.getTranslation();
              final position = Offset(translation.x, translation.y);
              final size = box.size;

              if (gazeX >= position.dx &&
                  gazeX <= position.dx + size.width &&
                  gazeY >= position.dy &&
                  gazeY <= position.dy + size.height) {
                highlightedWord = entry["text"];
                break;
              }
            }
          }
        });
      }
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) await _extractTextFromImage(pickedFile);
  }

  Future<void> _extractTextFromImage(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer();
    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      List<Map<String, dynamic>> newWordWidgets = [];
      StringBuffer buffer = StringBuffer();
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          for (TextElement word in line.elements) {
            buffer.write("${word.text} ");
            newWordWidgets.add({"text": word.text, "key": GlobalKey()});
          }
          buffer.write("\n");
        }
      }
      setState(() {
        extractedText = buffer.toString();
        wordWidgets = newWordWidgets;
      });
    } catch (e) {
      developer.log("Error recognizing text: $e");
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gaze Tracking")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: extractedText.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          key: _scrollKey,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children: wordWidgets.map((entry) {
                              return Container(
                                key: entry["key"],
                                child: Text(
                                  entry["text"],
                                  style: TextStyle(
                                    fontFamily: 'OpenDyslexic',
                                    fontSize: 20,
                                    backgroundColor: highlightedWord == entry["text"] ? Colors.yellow : null,
                                    color: highlightedWord == entry["text"] ? Colors.red : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    : (_controller == null || !_controller!.value.isInitialized)
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            key: _cameraKey,
                            children: [
                              CameraPreview(_controller!),
                              if (_gazeX != null && _gazeY != null)
                                Positioned(
                                  left: _gazeX!,
                                  top: _gazeY!,
                                  child: const Icon(Icons.circle, color: Colors.red, size: 15),
                                ),
                            ],
                          ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: _pickImage, child: const Text("Upload Image")),
                  ElevatedButton(onPressed: _toggleCamera, child: const Text("Toggle Camera")),
                ],
              ),
            ],
          ),
          if (extractedText.isNotEmpty && _gazeX != null && _gazeY != null)
            Positioned(
              left: _gazeX!,
              top: _gazeY!,
              child: const Icon(Icons.circle, color: Colors.red, size: 15),
            ),
        ],
      ),
    );
  }
}


