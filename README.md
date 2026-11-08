# PoultryCare Pro: Commercial Poultry Health Diagnostic Mobile Application

PoultryCare Pro is a commercial Flutter mobile application for AI-assisted poultry disease detection, clinical flock triage, and veterinary treatment advisory from chicken fecal droppings. Tailored specifically for rural poultry farmers and field veterinarians.

## Enterprise Overview
- **Product**: PoultryCare Pro (Commercial Farmer Edition v2.4.1)
- **Target Domain**: 100% Chicken and Poultry Focused (Broiler, Layer, and Desi breeds)
- **Target Diseases**: Coccidiosis, Newcastle Disease (NCD), Salmonella, and Healthy Digestion
- **Field Support Helpline**: +92 300 1234567 (24/7 Veterinary Assistance)
- **Email Support**: support@poultrycare.farm

## Key Features
- **Farmer-Centric UI/UX**: Designed for rural farmers and low-literacy users with oversized touch buttons, bold high-contrast fonts, clear visual icons, and zero clutter.
- **Full Urdu and English Localization**: Complete bilingual interface with live language toggling across all screens, buttons, alert dialogs, and triage questionnaires.
- **Real Text-to-Speech (TTS) Voice Narration**: Integrated `flutter_tts` engine providing spoken audio guidance in Urdu (`ur-PK`) and English (`en-US`), explaining diagnostic findings, severity levels, and treatment steps with animated progress and soundwaves.
- **Populated Farmer Dashboard**: Rich dashboard with 4 quick navigation cards (Quick Scan, Active Flock & Shed Status, 24/7 Veterinary Helpline, Recent Detections feed) and telemetry vitals grid.
- **Session Persistence and Login Loop Bypass**: Automatic session persistence using SharedPreferences allowing authenticated farmers to bypass onboarding and login directly to their sheds.
- **Real Device Camera and Gallery Capture**: Seamlessly capture fresh photos using the device camera or select existing high-resolution specimens from the gallery, with built-in quality validation.
- **On-Device TFLite AI Inference**: Real-time on-device classification executing quantized PoultryCare Neural Vision Engine with 224x224 RGB tensors in float32 format.
- **Explainable Clinical Flock Triage**: Combines image classification with 3 farmer flock signals (lethargy, feed intake, sudden mortality) to assess disease severity (Mild, Moderate, Severe) and urgency (Monitor, Treat Today, Consult Vet Soon, Urgent Vet Required).
- **Consolidated Diagnostic Result Screen**: Single-screen diagnostic summary featuring disease badges, calibrated confidence, severity gauges, Newcastle emergency warnings, bilingual voice narration, prescriptions, care steps, and farmer feedback.
- **Emergency Vet Call Hotline**: Integrated one-tap dialer via `url_launcher` connecting directly to the 24/7 poultry veterinary helpline (+92 300 1234567).
- **Offline SQLite Local Database**: Automatically saves every diagnostic screening to device storage with full historical review and search capabilities.
- **Flock and Shed Management**: Manage up to 20 farm sheds with breed, bird count, and shed-specific diagnostic records.
- **Disease Encyclopedia**: Complete reference for all 4 disease classes with English and Urdu clinical signs and treatments.

## How to Run the App
To run the Flutter mobile frontend on an Android device, iOS simulator, or Chrome:

```bash
flutter pub get
flutter run
```

To run automated unit and widget tests:
```bash
flutter test
```

## Machine Learning & On-Device Architecture
- **On-Device TFLite Service (`TFLiteService`)**: Located at `lib/services/tflite_service.dart`. Directly loads `.tflite` model and labels from `assets/model/`.
- **Image Preprocessing Contract**: Resizes directly to `224x224` (no crop or padding, using average interpolation), converts channels to RGB, and preserves raw pixel values in `0..255` float32 format as specified in model metadata.
- **Severity Assessment Engine**: Reads thresholds from `assets/model/severity_config.json` (`uncertain_below: 0.50`, `mild_max: 0.67`, `moderate_max: 0.83`) with minimum severity floor rules (Newcastle elevated to at least Moderate).
- **Local SQLite Database (`DatabaseService`)**: Located at `lib/services/database_service.dart`. Persists detection sessions offline with image path, disease name, severity level, confidence score, and timestamp. Includes full CRUD methods.
- **Backend Inference API (Optional Hybrid)**: Python HTTP microservice located at `backend/inference_server.py` listening on `http://0.0.0.0:8000/api/diagnose`.
- **Resources & Assets Directory**: Model artifacts located in `assets/model/` and `resources/` containing `labels.txt`, `severity_config.json`, `model_meta.json`, and `.tflite` files.

To start the local ML backend inference service:
```bash
python backend/inference_server.py
```

To run ML verification tests:
```bash
python backend/test_inference.py
```

## Directory Structure
- `lib/core/`: Design system, themes (Light and Dark), Plus Jakarta Sans typography, custom buttons, text fields, cards, status badges, AppImageView, and synchronized audio narration widget.
- `lib/data/`: Domain models, mock repositories, and clinical triage rules engine.
- `lib/features/`: Feature modules (Auth, Dashboard, Scanner Studio, Flocks, History, Encyclopedia, Profile/Settings).
- `lib/routes/`: Declarative AppRouter with named routes.
- `lib/services/`: On-device TFLite inference service, SQLite database service, and session persistence service.
- `resources/`: Model metadata, labels, severity config, and exported model artifacts.
