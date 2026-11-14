# PoultryCare: On-Device Poultry Health Diagnostic System

PoultryCare is a Final Year Project (FYP) Flutter mobile application and Python backend for AI-assisted poultry disease detection, clinical flock triage, and veterinary treatment advisory from chicken fecal droppings. Tailored specifically for rural poultry farmers, field veterinarians, and flock managers.

## Project Overview
- **System**: PoultryCare Mobile Health Diagnostic Assistant (v2.4.0)
- **Target Domain**: Chicken and Poultry Focused (Broiler, Layer, and Desi breeds)
- **Target Pathologies**: Coccidiosis, Newcastle Disease (NCD), Salmonella, and Healthy Digestion
- **Field Support**: Configurable in Settings (Direct 1-touch dialer to your registered farm veterinarian)
- **Email Contact**: support@poultrycare.app

## Key Capabilities
- **Farmer-Centric UI/UX**: Designed for rural farmers and low-literacy users with oversized touch buttons, bold high-contrast fonts, clear visual icons, and zero clutter.
- **Full Urdu and English Localization**: Complete bilingual interface with live language toggling across all screens, buttons, alert dialogs, and triage questionnaires.
- **Real Text-to-Speech (TTS) Voice Narration**: Integrated `flutter_tts` engine providing spoken audio guidance in Urdu (`ur-PK`) and English (`en-US`), explaining diagnostic findings, severity levels, and treatment steps with animated progress and soundwaves.
- **Populated Farmer Dashboard**: Dashboard with 4 quick navigation cards (Quick Scan, Active Flock and Shed Status, Veterinary Helpline, Recent Detections feed) and farm telemetry vitals grid.
- **Session Persistence**: Automatic session persistence using SharedPreferences allowing authenticated farmers to bypass onboarding and login directly to their sheds.
- **Real Device Camera and Gallery Capture**: Capture fresh photos using the device camera or select existing high-resolution specimens from the gallery, with built-in quality validation (lighting and blur detection).
- **On-Device Edge AI Inference**: Real-time on-device classification executing quantized FP16 Neural Vision Engine with 224x224 RGB tensors in float32 format.
- **Explainable Clinical Flock Triage**: Combines image classification with 3 farmer flock signals (lethargy, feed intake, sudden mortality) and objective clinical sign ratios (watery, blood, abnormal color) to assess disease severity (`Mild`, `Moderate`, `Severe`) and urgency (`Monitor`, `Treat Today`, `Vet Soon`, `Vet Now`).
- **PostgreSQL 17 Cloud Relational Persistence**: Complete 10-table schema (`users`, `sessions`, `flocks`, `diseases`, `treatments`, `model_versions`, `scans`, `predictions`, `feedback`, `audit_logs`) matching Chapter 5 of the documentation.
- **Local SQLite Caching**: Offline-first SQLite database persisting detection sessions on-device with full CRUD capabilities.
- **Feed Conversion Ratio (FCR) & Economics Calculator**: Practical poultry calculator (FCR = Total Feed Consumed / Total Weight Gain) featuring dual bag/kg units, production vitals, market economics (feed costs, gross margins, net profit per bird, ROI), and a clinical Coccidiosis disease impact simulator linking directly to AI image diagnosis.
- **Professional Veterinary Prescription (Rx) Pad**: Clinical Rx section featuring structured medication cards with administration routes (water, feed, tonic), exact dosages, treatment duration, and a mandatory food safety Withdrawal Period warning banner.
- **Consolidated Single Result Screen**: Diagnostic badge, qualitative certainty indicator, clinical severity, Newcastle emergency advisory, bilingual spoken audio narration, prescribed medications, ordered care steps, biosecurity protocols, and farmer feedback.
- **Flock & Shed Management**: Manage farm sheds with breed, bird count, and shed-specific diagnostic records.
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

## Machine Learning & Backend Architecture
- **On-Device Inference Service (`TFLiteService`)**: Located at `lib/services/tflite_service.dart`. Directly loads `.tflite` model and labels from `assets/model/`.
- **Image Preprocessing Contract**: Resizes directly to `224x224` (no crop or padding, using average interpolation), converts channels to RGB, and preserves raw pixel values in `0..255` float32 format as specified in model metadata.
- **Severity Assessment Engine**: Reads thresholds from `assets/model/severity_config.json` (`uncertain_below: 0.50`, `mild_band_max: 1.0`, `moderate_band_max: 2.0`) with minimum severity floor rules (Newcastle elevated to at least Moderate).
- **Local SQLite Database (`DatabaseService`)**: Located at `lib/services/database_service.dart`. Persists detection sessions offline with image path, disease name, severity level, confidence score, and timestamp. Includes full CRUD methods.
- **Backend API & Database Service**: Python HTTP microservice located at `backend/inference_server.py` listening on `http://0.0.0.0:8000`.
- **Resources & Assets Directory**: Model artifacts located in `assets/model/` and `resources/` containing `labels.txt`, `severity_config.json`, `model_meta.json`, and `.tflite` files.

To start the local ML backend inference and database service:
```bash
& "backend/.venv/Scripts/python.exe" backend/inference_server.py
```

To run ML verification tests:
```bash
& "backend/.venv/Scripts/python.exe" backend/test_inference.py
```

## PostgreSQL Database Setup (Chapter 5)
For detailed step-by-step instructions on setting up a free cloud PostgreSQL 17 database in 60 seconds (Neon or Supabase), refer to `DATABASE_SETUP_GUIDE.md`.

Quick start:
1. Copy `.env.example` to `.env` and set your `DATABASE_URL`:
   ```env
   DATABASE_URL=postgresql://user:password@host:5432/dbname?sslmode=require
   ```
2. Run database migration and seeder:
   ```bash
   & "backend/.venv/Scripts/python.exe" backend/seed_db.py
   ```
3. Run database integration test suite:
   ```bash
   & "backend/.venv/Scripts/python.exe" backend/test_database_api.py
   ```

## Directory Structure
- `lib/core/`: Design system, themes (Light and Dark), Plus Jakarta Sans typography, custom buttons, text fields, cards, status badges, AppImageView, FlockStatusHelper, and synchronized audio narration widget.
- `lib/data/`: Domain models, repositories, and clinical triage rules engine.
- `lib/features/`: Feature modules (Auth, Dashboard, Scanner Studio, Flocks, History, Encyclopedia, Profile/Settings, FCR Calculator).
- `lib/routes/`: Declarative AppRouter with named routes.
- `lib/services/`: On-device inference service, automated image quality validation service (lighting and focal blur detection), SQLite database service, session persistence service, and disease audio voice narration service.
- `resources/`: Model metadata, labels, severity config, and exported model artifacts.
- `backend/`: Inference server, database engine (`db.py`), 10-table ORM models (`models_db.py`), seeder (`seed_db.py`), and test suites.
- `DATABASE_SETUP_GUIDE.md`: Step-by-step guide to connecting PostgreSQL on cloud or local Docker.
