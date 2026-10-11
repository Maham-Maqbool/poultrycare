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
- Ready for user testing and execution (`flutter run`).
