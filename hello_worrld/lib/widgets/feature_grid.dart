


// import 'package:hello_world/screens/text_to_speech.dart'; // Import the TextToSpeechScreen
// import 'package:hello_world/screens/speech_to_text_screen.dart'; // Import the SpeechToTextScreen
// import 'package:flutter/material.dart';
// import 'package:hello_world/screens/gaze_tracking_screen.dart';
// import 'package:camera/camera.dart';

// class FeatureGrid extends StatelessWidget {
//   const FeatureGrid({Key? key}) : super(key: key);

//   final List<Map<String, String>> features = const [
//     {"title": "Text to Speech", "padding": "20"},
//     {"title": "Speech to Text", "padding": "20"},
//     {"title": "Gaze Tracking", "padding": "20"}
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // Set background color to white
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: features.sublist(0, 2).map((feature) {
//                   return Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: FeatureCard(
//                         title: feature["title"]!,
//                         padding: double.parse(feature["padding"]!).toInt(),
//                         onTap: feature["title"] == "Speech to Text"
//                             ? () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => SpeechToTextScreen(),
//                                   ),
//                                 );
//                               }
//                             : feature["title"] == "Text to Speech"
//                                 ? () {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                         builder: (context) => TextToSpeechScreen(),
//                                       ),
//                                     );
//                                   }
//                                 : null,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 32),
//               GestureDetector(
//                 onTap: () async {
//                   final cameras = await availableCameras();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => GazeTrackingScreen(cameras: cameras),
//                     ),
//                   );
//                 },
//                 child: Card(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       //Icon(Icons.remove_red_eye, size: 50, color: Colors.indigo),
//                       SizedBox(height: 10),
//                       Text("Gaze Tracking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class FeatureCard extends StatelessWidget {
//   final String title;
//   final int padding;
//   final VoidCallback? onTap;

//   const FeatureCard({
//     required this.title,
//     required this.padding,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         margin: EdgeInsets.all(padding.toDouble()),
//         child: Center(
//           child: Text(
//             title,
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:hello_world/screens/text_to_speech.dart'; // Import the TextToSpeechScreen
import 'package:hello_world/screens/speech_to_text_screen.dart'; // Import the SpeechToTextScreen
import 'package:flutter/material.dart';
import 'package:hello_world/screens/gaze_tracking_screen.dart';
import 'package:camera/camera.dart';

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({Key? key}) : super(key: key);

  final List<Map<String, String>> features = const [
    {"title": "Text to Speech", "padding": "20"},
    {"title": "Speech to Text", "padding": "20"},
    {"title": "Gaze Tracking", "padding": "20"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons vertically
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: features.sublist(0, 2).map((feature) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FeatureCard(
                        title: feature["title"]!,
                        padding: double.parse(feature["padding"]!).toInt(),
                        onTap: feature["title"] == "Speech to Text"
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SpeechToTextScreen(),
                                  ),
                                );
                              }
                            : feature["title"] == "Text to Speech"
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TextToSpeechScreen(),
                                      ),
                                    );
                                  }
                                : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FeatureCard(
                title: "Gaze Tracking",
                padding: 20,
                onTap: () async {
                  final cameras = await availableCameras();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GazeTrackingScreen(cameras: cameras),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final int padding;
  final VoidCallback? onTap;

  const FeatureCard({
    required this.title,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(padding.toDouble()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
