
import 'package:flutter/material.dart';
import 'package:hello_world/widgets/feature_grid.dart';
import 'package:hello_world/screens/gaze_tracking_screen.dart';
import 'package:camera/camera.dart';
import 'dart:async';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    runApp(LexipalApp(cameras: cameras));
  }, (error, stackTrace) {
    debugPrint("Error in main(): $error\n$stackTrace");
  });
}

class LexipalApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const LexipalApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexipal',
      theme: ThemeData(primarySwatch: Colors.indigo,
                       fontFamily: 'OpenDyslexic',),
      initialRoute: '/',
      routes: {
        '/': (context) => LexipalLanding(cameras: cameras),
        '/gaze-tracking': (context) => GazeTrackingScreen(cameras: cameras),
      },
    );
  }
}

class LexipalLanding extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const LexipalLanding({Key? key, required this.cameras}) : super(key: key);

  void handleGetStarted(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeatureGrid()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'LEXIPAL',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.indigo[800],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'YOUR DYSLEXIC ASSISTANT',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: () => handleGetStarted(context),
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: const Text('GET STARTED'),
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromARGB(255, 167, 170, 194), // Updated color
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18,fontFamily: 'OpenDyslexic',),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
