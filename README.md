# PoultryCare: Poultry Disease Detection & Severity Assessment Mobile Application

Final Year Project (FYP) Flutter mobile application for AI-assisted poultry disease detection, clinical flock triage, and veterinary treatment advisory from fecal images.

## Project Details
- **Institution**: Khwaja Fareed University of Engineering & Information Technology (KFUEIT), Rahim Yar Khan
- **Developers**: Isha Ishtiaq (COSC232101047), Maham Maqbool (COSC232101029)
- **Supervisor**: Dr. Shahzad Hussain
- **Target Domain**: 100% Chicken & Poultry Focused (Broiler, Layer, Desi breeds)
- **Target Diseases**: Coccidiosis, Newcastle Disease (NCD), Salmonella, Healthy Digestion

## Key Features
- **Real Device Camera & Gallery Upload**: Take live photos using the device camera or select high-resolution images from the gallery. Full fallback to 4 authentic domain test specimens.
- **Enterprise-Grade AI Viewfinder Studio**: Clinical specimen targeting reticle with corner brackets and pre-inference quality validation.
- **Instant Fecal AI Screening**: MobileNetV3 deep learning classifier for Coccidiosis, Newcastle Disease, Salmonella, and Healthy droppings.
- **Explainable Clinical Flock Triage**: Combines image inference with 3 farmer flock signals (lethargy, intake drop, sudden mortality) to assess disease severity (`Mild`, `Moderate`, `Severe`) and urgency (`Monitor`, `Treat Today`, `Vet Soon`, `Vet Now`).
- **Consolidated Single Result Screen (FR-08)**: Diagnostic badge, confidence rating, severity gauge, Newcastle urgent warning, bilingual spoken audio simulator, medical prescriptions, ordered care steps, biosecurity protocols, and farmer feedback.
- **Flock & Shed Management**: Manage up to 20 farm sheds with breed, bird count, and shed-specific diagnostic records.
- **Disease Encyclopedia**: Complete reference for all 4 disease classes with English and Urdu clinical signs and treatments.
- **Bilingual & Dark Mode Support**: Full English and Urdu support with seamless live theme switching.
- **Adaptive Layout Architecture**: Tested for zero overflow across small and large mobile screen form factors.

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

## Machine Learning & Inference Service
- **Model Architecture**: MobileNetV2 with transfer learning (ImageNet base) trained on Kaggle/Zenodo poultry fecal image dataset.
- **Preprocessing Contract**: Input shape `[1, 224, 224, 3]`, RGB, `float32`, raw pixel values `0..255` (normalization embedded in model head). Direct resize to 224x224 with bilinear interpolation and EXIF orientation transpose.
- **Output Classes (0..3)**: 0: Coccidiosis, 1: Healthy, 2: Newcastle, 3: Salmonella.
- **Severity Assessment**: Calibrated thresholds (`severity_config.json`) with Newcastle floor protection and flock triage escalation.
- **Backend Inference API**: Python HTTP microservice located at `backend/inference_server.py` listening on `http://0.0.0.0:8000/api/diagnose`.
- **Resources Directory**: Located at `resources/` containing `labels.txt`, `severity_config.json`, `model_meta.json`, and model `.tflite` artifacts.

To start the local ML backend inference service:
```bash
python backend/inference_server.py
```

To run ML verification tests:
```bash
python backend/test_inference.py
```

## Directory Structure
- `lib/core/`: Design system, themes (Light & Dark), Plus Jakarta Sans typography, custom buttons, text fields, cards, status badges, AppImageView, and audio narration simulator.
- `lib/data/`: Models reflecting Chapter 5 schema, mock repositories, and clinical triage rules engine.
- `lib/features/`: Feature modules (Auth, Dashboard, Scanner Studio, Flocks, History, Encyclopedia, Profile/Settings).
- `lib/routes/`: Declarative AppRouter with named routes.
- `resources/`: Model metadata, labels, severity config, and exported model artifacts.
- `backend/`: Inference server, test suite, and client verification scripts.
- `project-docs/`: FYP documentation, training notebook, and Colab evaluation results.
