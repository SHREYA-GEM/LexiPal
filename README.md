# LexiPal

LexiPal is an assistive reading app designed for individuals with dyslexia. It offers features like gaze-tracking-based text highlighting and text-to-speech to improve reading fluency and comfort. The app is built with Flutter and powered by a Python backend for gaze tracking.

---

## 🧠 Features

- 👁️ **Gaze Tracking** – Detects eye position and highlights the word being looked at
- 🗣️ **Text-to-Speech** – Reads aloud the extracted or typed text
- 🔠 **OCR Support** – Extracts text from uploaded images
- 🧩 **Dyslexia-Friendly Design** – Uses fonts and UI optimized for readability

---

###  Technologies Used

- **Flutter** – Cross-platform mobile app development framework  
- **Python** – Backend processing for gaze estimation and image handling  
- **Roboflow Inference SDK** – Real-time eye tracking using a pre-trained gaze estimation model  
- **Google ML Kit** – Optical Character Recognition (OCR) for extracting text from images  
- **Flutter TTS & STT Plugins** – Text-to-Speech (TTS) and Speech-to-Text (STT) functionality for accessibility  
- **WebSocket** – Enables real-time communication between the Flutter frontend and Python backend


###  Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/SHREYA-GEM/LexiPal.git
cd LexiPal
```

#### 2. Backend Setup

```bash
cd backend
python server.py
```

#### 3. Flutter App Setup

```bash
cd Lexipal_flutterapp
flutter pub get
flutter run
```

###  Contributors

- [Sandra](https://github.com/Sandraanand)  
- [Saniya Sebastian](https://github.com/SaniyaSebastian)  
- [Shreya Gem Mathew](https://github.com/SHREYA-GEM)  
- [Vinsu Susan Thomas](https://github.com/vinsu353)

