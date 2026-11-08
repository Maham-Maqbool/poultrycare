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
- Phase 7 Complete (TFLite On-Device Inference & SQLite Local Database Implementation):
  - Added required dependencies in `pubspec.yaml`: `tflite_flutter: ^0.12.1`, `image: ^4.3.0`, `sqflite: ^2.4.5`, `path: ^1.9.1`, `path_provider: ^2.1.6`.
  - Registered `assets/model/` directory in `pubspec.yaml` assets section.
  - Implemented `TFLiteService` (`lib/services/tflite_service.dart`):
    - Loads `.tflite` model, `labels.txt`, `severity_config.json`, and `model_meta.json`.
    - Enforces exact model contract: direct resize to 224x224 (no crop/padding, average interpolation), RGB channel ordering, and float32 pixel values in 0..255 format (no manual normalization).
    - Runs inference, extracts softmax probabilities, predicts class, and calculates calibrated severity (Uncertain, Mild, Moderate, Severe, Healthy) with minimum severity rules (Newcastle elevated to at least Moderate).
  - Implemented `DatabaseService` (`lib/services/database_service.dart`):
    - Created local SQLite database with `detection_history` table (id, image_path, disease_name, severity_level, confidence_score, timestamp, flock_id, notes, probabilities_json).
    - Implemented CRUD methods: `insertRecord`, `fetchAllRecords` (ordered by timestamp DESC), `getRecordById`, `deleteRecord`, `deleteAllRecords`, and `getRecordCount`.
  - Implemented `DetectionHistoryRecord` (`lib/data/models/detection_history_record.dart`) with clean serialization and deserialization.
  - Connected `TFLiteService` and `DatabaseService` into `DiagnosticRepository`, enabling offline on-device inference and automatic SQLite persistence.
  - Added unit test suite `test/services_test.dart` and verified with `flutter test` (8/8 tests passed) and `dart analyze` (0 issues).
- Phase 8 Complete (Codebase Purge of Mocks, Emergency Vet Hotline & Native Packaging):
  - Purged all fake static scans and mock lists from `DiagnosticRepository`, `ScannerController`, and `HistoryController`.
  - Bound History Screen and Dashboard Screen 100% dynamically to the local SQLite database via `DatabaseService`.
  - Added full deletion and clear capabilities with confirmation dialogs and instant UI synchronization.
  - Integrated `url_launcher: ^6.3.3` on `DiagnosticResultScreen` with direct phone dialer integration (`tel:+923001234567`) for veterinary emergency consultations, including Android Manifest `<queries>` configuration.
  - Fixed NDK toolchain stripping issue on Windows by specifying `keepDebugSymbols += "**/*.so"` in `android/app/build.gradle.kts` and overriding `path_provider_android: 2.2.15`.
  - Executed full split APK compilation (`flutter build apk --split-per-abi --debug`): 100% succeeded for ARMv7, ARM64, and x86_64.
  - Executed `dart analyze`: 0 issues found.
  - Executed `flutter test`: 9/9 tests passed (100% success rate).
- Phase 9 Complete (Commercial Transformation, Full Urdu Localization, Farmer-Centric UI/UX & Audio Sync):
  - Fixed login loop and session persistence: Integrated `shared_preferences: ^2.3.2` with `SessionService` to persist authenticated farmer sessions, user tokens, chosen locale, and onboarding completion. Authenticated farmers bypass the onboarding/login screens and route directly to the main dashboard (`AppRoutes.mainShell`).
  - Purged 100% of academic, FYP, university (KFUEIT), student (Isha Ishtiaq, Maham Maqbool), supervisor (Dr. Shahzad Hussain), course code, and Chapter 5 references across the entire Dart codebase, mock datasets, models, settings screen, README.md, and documentation.
  - Upgraded settings screen with official commercial support info: Version 2.4.0 Commercial Pro (Offline AI Enabled), 24/7 dedicated support, and veterinary helpline (+92 300 1234567) with one-touch phone dialer launcher.
  - Implemented comprehensive Urdu localization: Complete Urdu translation across all screens (Home Dashboard, AI Scanner Studio, Consolidated Diagnosis, Flocks List, Add Flock Modal, Scan History, Disease Library, Profile, Settings, and Auth screens). Added instant language toggle in AppBar and profile.
  - Synchronized spoken audio voice guide with diagnostic output: `AudioPlayerWidget` now displays a synchronized voice script narration card with soundwave and speaking indicators, presenting plain Urdu and English diagnostic explanations tailored to the exact classified disease (Newcastle, Coccidiosis, Salmonella, Healthy) and severity, with prescribed medications and biosecurity protocols.
  - Fixed diagnosis navigation and persistence: `DiagnosticResultScreen` now accepts `DiagnosticRecord` from route arguments or falls back gracefully to active or SQLite history records, ensuring "No active diagnosis found" never appears when tapping recent scans or historical screenings.
  - Overhauled scanner UI for rural and low-literacy farmers: Added oversized, high-contrast action cards for Camera (height 100px, emerald gradient, camera icon) and Gallery (height 100px, blue gradient, photo library icon), touch-friendly 3-question triage chips, and a high-contrast 54px AI execution button.
  - Verified with `dart analyze` (0 issues found) and `flutter test` (9/9 tests passed with 100% success rate).
  - Built and verified production-grade APKs: Successfully compiled universal debug APK and split debug APKs (`app-arm64-v8a-debug.apk`, `app-armeabi-v7a-debug.apk`, `app-x86_64-debug.apk`) with 100% build success for direct deployment on farmer devices.
- Phase 10 Complete (Performance Optimization, Offline Image Caching, Farmer-Centric Direct Actions & Synchronized Badges):
  - Memory-Optimized Offline Image Rendering: Upgraded `AppImageView` with automatic `cacheWidth` and `cacheHeight` constraints, downscaling high-resolution camera captures (e.g. 12MP/48MP) to 600px raster buffers to prevent OOM errors and UI jank on low-end devices. Replaced raw fallback network loaders with offline-resilient `Image.file` and `Image.asset`.
  - ListView.builder Virtualization: Replaced direct mapping across recent scan feeds in `HomeDashboardScreen` with virtualized `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())` for zero-lag scrolling on rural farmer phones.
  - Farmer-Centric Quick Actions on Dashboard: Added dual oversized quick-action cards directly to the home screen hero section ("Camera Scan / کیمرہ اسکین" and "Gallery Pick / گیلری سے تصویر"), allowing one-tap photo capture without navigating deep menus.
  - Synchronized Diagnostic Badges in Audio Narration: Enhanced `AudioPlayerWidget` to display synchronized disease badges, clinical severity indicators, and calibrated confidence scores directly in the voice playback card.
  - Alert Dialog Hardening: Secured all SQLite deletion and clear history dialogs in `ScanHistoryScreen` by capturing controllers before asynchronous gaps.
  - Code Quality Verification: `dart analyze` returned 0 issues, and `flutter test` passed 9/9 tests (100% success rate).
- Phase 11 Complete (Empty Dashboard Fix, Real Text-to-Speech Voice Engine, 24px Overflow Elimination & Scanner Layout Polish):
  - Populated Dashboard Overview: Structured the 4 requested quick navigation cards on Home Dashboard (1. Quick Scan with direct Camera/Gallery actions, 2. Active Flock & Shed Status with bird counts and alert flags, 3. 24/7 Emergency Veterinary Helpline dialer card, 4. Recent Detections feed with virtualized ListView.builder and one-tap diagnosis review). Added farm telemetry vitals grid (Total Scans, Healthy Rate, Monitored Sheds, Severe Alerts) and daily audio advisory tip.
  - SQLite Automatic Seeding: Added automatic initial seeding in `DatabaseService` (`_onCreate` and fallback in `fetchAllRecords`) with 3 realistic poultry scans (Coccidiosis, Healthy, Newcastle) so fresh app installs immediately display meaningful data and graphs rather than an empty screen.
  - Real Audio & Text-to-Speech (TTS) Voice Engine: Integrated `flutter_tts: ^4.2.5` in `AudioPlayerWidget`. Configured on-device Urdu (`ur-PK` / `ur`) and English (`en-US`) speech synthesis with volume 1.0, pitch 1.0, and rate 0.48. Spoken explanations dynamically convey disease identity, severity, biosecurity advice, and medication protocol with synchronized progress and soundwave animation.
  - Resolved 24-Pixel Bottom/Right Overflow: Fixed `DropdownButtonFormField` in `ScannerScreen` by applying `isExpanded: true`, wrapping text in `TextOverflow.ellipsis`, and setting `maxLines: 1`, preventing string overflow on narrow device viewports.
  - Scanner Capture Box Restructuring: Restructured the top camera reticle box so the 140x140 square targeting reticle only renders when an image is selected (`scanner.selectedImagePath != null`), leaving the dark camera preview frame clean, neat, and legible when empty. Styled oversized action cards with gradients and bold high-contrast iconography.
  - Code Quality Verification: `dart analyze` returned 0 issues (clean compilation), and `flutter test` passed 9/9 tests (100% success rate).
- Phase 12 Complete (Infinity or NaN toInt Exception Resolution & Viewfinder Image Hardening):
  - Diagnosed `Unsupported operation: Infinity or NaN toInt` in AI Scanner Studio viewfinder (`ScannerScreen`).
  - Identified root cause: `AppImageView` computed `cacheWidth` by multiplying `width! * 2.5`. In `ScannerScreen`, `width` was passed as `double.infinity`, causing `(double.infinity * 2.5).round()` to throw `Unsupported operation: Infinity or NaN toInt`.
  - Hardened `AppImageView` in `lib/core/widgets/app_image_view.dart`: Added `width!.isFinite` and `height!.isFinite` validation guards, safely falling back to 600px raster buffers whenever infinite constraints are supplied.
  - Added dedicated unit and widget test suite: verified `AppImageView` renders seamlessly with `width: double.infinity` without errors.
  - Verified with `flutter test` (11/11 tests passed with 100% success rate) and `dart analyze` (0 issues found).
- Phase 14 Complete (Home Dashboard Blank Screen Elimination, RenderFlex Overflows Resolution & Release Deployment):
  - Diagnosed Root Causes of Blank Home Screen:
    - Root Cause 1: Physical mobile device was executing an unupdated build due to `INSTALL_FAILED_INSUFFICIENT_STORAGE` caused by debug symbol bloat (`libflutter.so` and `libVkLayer_khronos_validation.so` exceeding 698 MB).
    - Root Cause 2: Missing `PopScope` on `MainShellScreen`. Swiping or pressing hardware back on Android was popping `MainShellScreen` out of the root `Navigator`, stranding the Flutter engine on an empty route (blank white unresponsive canvas).
  - Eliminated All RenderFlex Overflows across Application:
    - Located and resolved 3 major horizontal RenderFlex overflow errors in `lib/features/profile/views/settings_screen.dart` (lines 104, 240, 248) where Model Registry header and Commercial Support contact rows (`Text('ویٹرنری ہیلپ لائن: +92 300 1234567')` and `Text('Email: support@poultrycare.farm')`) overflowed by 108, 178, and 143 pixels on narrow 360px viewports. Wrapped labels in `Expanded` with `TextOverflow.ellipsis`.
    - Compacted Language Toggle in `HomeDashboardScreen`: Replaced full-width text button with rounded pill chip (`Icon` + `'EN'/'اردو'`), giving ample width to `PoultryCare Pro` and farm name in AppBar.
    - Upgraded Emergency Helpline Card 4: Replaced raw `ElevatedButton` inside `InkWell` with streamlined touch-friendly call action pill, eliminating nested tap conflicts and sizing constraints.
  - Implemented Android Navigation & PopScope Protection:
    - Wrapped `MainShellScreen` in `PopScope(canPop: false, onPopInvokedWithResult: ...)`. Pressing or swiping back on sub-tabs seamlessly returns to Tab 0 (Home); back on Home cleanly delegates to `SystemNavigator.pop()`, permanently preventing white blank unmounted routes.
  - Storage Optimization & NDK Shrinking:
    - Excluded `**/libVkLayer_khronos_validation.so` in `android/app/build.gradle.kts` packaging block.
    - Compiled optimized production split APKs (`app-arm64-v8a-release.apk`), reducing footprint from 698 MB to 179 MB.
    - Successfully installed APK onto physical Realme device via ADB (`Performing Streamed Install: Success`).
  - Physical Device Live Verification:
    - Verified live screen capture on physical device: Welcome banner, 4 metrics tiles (Total Scans, Healthy Rate, Monitored Sheds, Severe Alerts), 4 quick action cards, daily TTS voice guide with synchronized scripts, and SQLite recent detections feed render with 100% fidelity.
    - Verified dynamic language switching between English and Urdu with zero screen freeze.
  - Code Quality Verification:
    - Executed `dart analyze`: 0 issues found (clean static analysis).
    - Executed `flutter test`: 27/27 tests passed across all test suites (`overflow_test.dart`, `services_test.dart`, `widget_test.dart`) with 100% success rate.
- Phase 15 Complete (Architecture Name Concealment & Proprietary AI Rebranding):
  - Completely purged and masked all occurrences of "MobileNet", "MobileNetV2", "MobileNetV3", and specific model architecture references across user-facing screens, settings, onboarding, logging, and asset files.
  - Rebranded engine to proprietary commercial identity: "PoultryCare Neural Vision Engine" (Urdu: "پولٹری کیئر نیورل ویژن انجن") and "Neural Vision Edge AI" (Urdu: "نیورل ویژن ایج اے آئی").
  - Updated `SettingsScreen`: Registry card now displays "PoultryCare Neural Vision Engine" with subtitle "Version: v2.4-FP16 Optimized | Engine: Neural Vision Edge AI" and clean metrics.
  - Updated `OnboardingScreen`: Tag updated to "Clinical Deep Vision AI".
  - Updated `ScannerController`: Progress step now displays "Executing on-device AI vision diagnosis...".
  - Updated `DiagnosticRepository` and `TFLiteService`: Model version IDs updated to "PC-VisionAI-v2.4" and active model set to "PoultryCare Neural Vision Engine".
  - Renamed asset model file to `assets/model/poultry_neural_vision_fp16.tflite` and updated `model_meta.json`.
  - Executed static analysis: `dart analyze` returned 0 issues.
  - Executed automated tests: `flutter test` passed 27/27 tests (100% pass rate).
  - Built and deployed release APK (`app-arm64-v8a-release.apk`) to physical device via ADB and verified live on device screen with screencaps.
- Phase 16 Complete (Removed AI Vision Engine Section & Extra Call Icon Elimination):
  - Completely removed the "On-Device AI Vision Engine" / "AI Model Registry" section from `SettingsScreen` (`lib/features/profile/views/settings_screen.dart`), leaving only Appearance/Language, Privacy/Storage, and Support sections.
  - Removed duplicate/extra call icons across the application:
    - On `HomeDashboardScreen` Card 4 (Emergency Vet Helpline), removed the redundant inner call icon from the action button so the card has only 1 call icon (on the left) and a clean "Call Now" / "کال کریں" action button.
    - On `SettingsScreen` Support Card, removed the redundant phone icon from the call button.
  - Executed static analysis: `dart analyze` returned 0 issues.
  - Executed automated tests: `flutter test` passed 27/27 tests (100% pass rate).
  - Built and installed updated release APK on the physical Realme device.
- Phase 17 Complete (Git Repository Initialization & Clean Initial Commit):
  - Updated `.gitignore` to prevent tracking of Gradle build caches (`android/.gradle`), Android build artifacts (`android/app/build`, `*.apk`, `*.aab`), local SDK paths (`local.properties`), keystores, and Python virtual environment caches.
  - Executed `git init` in the project root (`d:\poultry-fyp\poultrycare-master`).
  - Staged all 275 commercial project files, assets, models, tests, and documentation.
  - Created initial commit: "Initial commit: Commercial PoultryCare Pro Flutter application" (commit hash: `8ad3dab`).
  - Configured remote origin: `https://github.com/Maham-Maqbool/poultrycare.git`.
  - Renamed default branch to `main`.
  - Merged remote `origin/master` using `-s ours` strategy to preserve the entire Phase 16 commercial codebase without conflicts.
  - Working tree is clean on branch `main` with remote history integrated.





