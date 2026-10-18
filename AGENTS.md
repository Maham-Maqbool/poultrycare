# AGENTS Memory & Project Log

## Project Scope
- Final Year Project (FYP) Mobile Application in Flutter (Frontend Only).
- Documentation Directory: `project-docs/`.
- Automation Skill: `.agents/skills/start-fyp-flutter/` triggered by `/start-fyp-flutter`.

## Agent Rules Reference
All 11 project rules documented in `.agents/rules/project-rules.md` are actively enforced:
1. Stay in the project directory.
2. Memory file: Track progress and decisions in this file (`AGENTS.md`).
3. Follow rules at all times.
4. Local installs only.
5. Official CLI commands only.
6. Stop all processes before stopping.
7. No em dashes anywhere.
8. Maintain README.md.
9. Never create artifacts: Save plans and reports as regular project files.
10. Do not change global settings.
11. Commit regularly, never push.

## Progress & Status
- Installed skills loaded into context: `start-fyp-flutter`, `flutter-expert`, `mobile-design`, `ui-ux-pro-max`, `senior-architect`.
- Analyzed FYP project document: `project-docs/FYP_PoultryDiseaseDetection_Documentation_with_Chapter5 (3).docx`.
  - Extracted 10 User Needs (N-01 to N-10), 13 Functional Requirements (FR-01 to FR-13), 9 Non-Functional Requirements.
  - Extracted system diagrams (ERD, Use Case, Class, Activity, Sequence, Component) and PostgreSQL schema (10 tables, enums, write-path).
  - Designed clinical flock triage integration (3 vital signals) and explainable rule-based advisory engine.
- Generated comprehensive implementation plan in `FRONTEND_PLAN.md`.
- Phase 1 Complete. Approval Gate passed: User approved FRONTEND_PLAN.md.
- Phase 2 Complete: Generated complete Flutter frontend codebase:
  - `lib/core/`: Tailored design system, themes (Light/Dark), Plus Jakarta Sans typography, custom buttons, text fields, cards, status badges, empty/error states, and bilingual audio narration widget.
  - `lib/data/`: 8 Dart 3 domain models (`UserModel`, `FlockModel`, `DiseaseModel`, `TreatmentModel`, `ScanModel`, `PredictionModel`, `FeedbackModel`, `ModelVersionModel`), 4 rich mock datasets with complete English & Urdu content, and 4 in-memory repositories with simulated MobileNetV3 inference and clinical triage rules engine.
  - `lib/features/`: 11 complete screens across Auth, Home Dashboard, AI Scanner Studio, Consolidated Results (FR-08), Flocks Management, Diagnostic History, Disease Encyclopedia, and Profile/Settings.
  - `lib/routes/`: Declarative AppRouter and named routes.
  - `test/widget_test.dart`: Smoke test passing with 100% success rate.
- Phase 3 Complete (Camera, Layout & Enterprise Polish):
  - Added real camera capture (`ImagePicker.pickImage(source: ImageSource.camera)`) and device gallery picker (`ImagePicker.pickImage(source: ImageSource.gallery)`) in `ScannerController` and `ScannerScreen`.
  - Created `AppImageView` supporting local `File` paths and network URLs with clinical specimen fallbacks.
  - Purged all non-poultry references and images. AppAssets updated to 100% authentic chicken, broiler, and layer photography. Replaced paw icons with poultry egg and veterinary symbols.
  - Fixed all Right Overflowed by X pixels errors across all screens by applying `Expanded`, `Flexible`, `FittedBox`, and `Wrap` on metric tiles, chips, and headers.
  - Upgraded deprecated `withOpacity` calls to `.withValues(alpha: ...)`, `activeColor` to `activeThumbColor`, and `value` to `initialValue`.
  - Executed `flutter analyze`: 0 issues found.
  - Executed `flutter test`: 3/3 tests passed with 100% success rate.
- Phase 4 Complete (Android Build & Gradle Cache Fix):
  - Resolved `image_picker_android:compileDebugKotlin` incremental cache lock on Windows by disabling `kotlin.incremental` in `android/gradle.properties` and adding `--enable-native-access=ALL-UNNAMED`.
  - Verified full APK build: `flutter build apk --debug` succeeded (`Built build/app/outputs/flutter-apk/app-debug.apk`).
- Phase 5 Complete (Colab ML Model & Inference Pipeline Integration):
  - Inspected Colab training notebook (`project-docs/poultry_training.ipynb`) and PDF execution log (`project-docs/poultry_training.ipynb - Colab.pdf`).
  - Extracted exact model contract: MobileNetV2 architecture, input shape `[1, 224, 224, 3]`, float32, RGB, values `0..255` (internal rescaling layer `1/127.5, offset -1`), direct resize to 224x224, EXIF orientation transpose.
  - Extracted class index mapping: 0: Coccidiosis, 1: Healthy, 2: Newcastle, 3: Salmonella.
  - Extracted calibrated severity assessment rules: `uncertain_below: 0.50`, `mild_max: 0.67`, `moderate_max: 0.83`, with Newcastle class floor (`Moderate`) and sudden mortality triage escalation.
  - Created `resources/` directory containing `labels.txt`, `severity_config.json`, `model_meta.json`, and `README.md`.
  - Implemented `backend/inference_server.py` serving HTTP inference on `http://0.0.0.0:8000/api/diagnose` supporting multipart and JSON payloads.
  - Implemented `backend/test_inference.py` and verified all 4 pipeline checks passed with 100% success rate.
  - Connected Flutter frontend via `DiagnosticRepository._callInferenceApi` with seamless local fallback to preserve existing UI state and offline stability.
  - Verified with `flutter test` (4/4 tests passed) and `dart analyze` (0 issues).
- Phase 6 Complete (Physical Device Installation & Storage Optimization):
  - Diagnosed `INSTALL_FAILED_INSUFFICIENT_STORAGE` on physical Realme device (RMX3268).
  - ADB diagnostics revealed device internal storage was 99% full (only 777 MB available out of 48 GB).
  - Universal debug APK (167 MB) exceeded Android safety installation buffer.
  - Resolved by building architecture-specific split APK (`flutter build apk --split-per-abi --debug`), reducing size to 93 MB for ARM64 (`app-arm64-v8a-debug.apk`).
  - Successfully installed APK onto device via ADB and launched `com.example.poultrycare/.MainActivity`.

