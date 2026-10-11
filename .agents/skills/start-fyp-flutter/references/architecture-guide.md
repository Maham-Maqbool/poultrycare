# Flutter Frontend Architecture Guide for FYP Applications

When implementing the pure-frontend Flutter mobile application from project documentation, follow this architectural structure. This ensures maintainability, realistic state handling without a real backend, and high visual quality.

---

## 1. Directory Structure (Feature-First Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_assets.dart       # Asset paths (images, icons, SVGs)
│   │   ├── app_colors.dart       # Primary, secondary, neutral, semantic palettes
│   │   ├── app_strings.dart      # All UI strings and labels
│   │   └── app_dimensions.dart   # Paddings, radiuses, icon sizes
│   ├── theme/
│   │   ├── app_theme.dart        # ThemeData (light & dark mode)
│   │   ├── color_schemes.dart    # ColorScheme definitions
│   │   └── text_theme.dart       # Google Fonts / Inter / Roboto typography styles
│   ├── utils/
│   │   ├── formatters.dart       # Date, currency, number formatting
│   │   └── validators.dart       # Form input validation rules
│   └── widgets/
│       ├── custom_button.dart    # Primary, secondary, outline, icon buttons
│       ├── custom_text_field.dart# Styled input fields with validation and icons
│       ├── app_card.dart         # Glassmorphism or styled elevated cards
│       ├── empty_state_view.dart # Visual placeholder when lists are empty
│       ├── error_state_view.dart # Visual placeholder when error occurs
│       ├── shimmer_loader.dart   # Skeleton loader for mock delay states
│       └── custom_app_bar.dart   # Clean, modern app bars with actions
│
├── data/
│   ├── models/                   # Clean Dart data classes (copyWith, toJson, fromJson)
│   │   ├── user_model.dart
│   │   └── [feature]_model.dart
│   ├── mock/                     # Rich, realistic mock datasets
│   │   ├── mock_users.dart
│   │   └── mock_[feature]_data.dart
│   └── repositories/             # Mock repository layer with simulated async delays
│       ├── mock_auth_repository.dart
│       └── mock_[feature]_repository.dart
│
├── features/                     # Feature modules (one folder per domain)
│   ├── auth/
│   │   ├── controllers/          # State controllers / ChangeNotifier
│   │   ├── views/                # Login, Register, Forgot Password, Onboarding
│   │   └── widgets/              # Auth-specific widgets (social buttons, OTP fields)
│   ├── home/
│   │   ├── controllers/
│   │   ├── views/                # Home dashboard, search, highlights
│   │   └── widgets/              # Banners, category chips, recent cards
│   ├── [core_feature_1]/
│   │   ├── controllers/
│   │   ├── views/                # List view, detail view, form/create view
│   │   └── widgets/
│   └── profile/
│       ├── controllers/
│       ├── views/                # Profile view, settings, edit profile, help
│       └── widgets/
│
├── routes/
│   ├── app_routes.dart           # Route name constants
│   └── app_router.dart           # GoRouter or onGenerateRoute setup
│
├── app.dart                      # MaterialApp configuration (theme, routes, localization)
└── main.dart                     # App entry point with initialized mock providers
```

---

## 2. State Management Strategy (Frontend Only)

Choose a clean, standard Flutter state management approach that requires zero backend configuration:

### Option A: `ChangeNotifier` + `ListenableBuilder` / `Provider` (Recommended Default)
- Simple, built into Flutter framework (or lightweight `provider` package).
- Controllers expose state properties (`isLoading`, `items`, `errorMessage`) and methods (`search()`, `toggleFavorite()`, `add()`).
- Methods call mock repositories, update state, and call `notifyListeners()`.

### Option B: `flutter_bloc` / `riverpod` (If Project Docs Explicitly Request)
- State classes: `Initial`, `Loading`, `Loaded`, `Error`.
- Clear unidirectional data flow.

---

## 3. Mock Repository Pattern

To make the app feel alive and authentic during demonstrations/FYP defense:
1. Include realistic async delays using `await Future.delayed(const Duration(milliseconds: 600));`.
2. Allow state modifications in memory (e.g. adding an item appends to the in-memory mock list so it immediately appears in UI).
3. Provide realistic status indicators (e.g. `Pending`, `Approved`, `Active`, `Completed`).
4. Include search and filter methods operating on the mock lists.

```dart
class MockTaskRepository {
  final List<TaskModel> _tasks = List.from(mockTasksData);

  Future<List<TaskModel>> getTasks({String? query, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var results = _tasks;
    if (query != null && query.isNotEmpty) {
      results = results.where((t) => t.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    if (status != null && status != 'All') {
      results = results.where((t) => t.status == status).toList();
    }
    return results;
  }

  Future<void> addTask(TaskModel task) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _tasks.insert(0, task);
  }
}
```

---

## 4. UI/UX Standards for Final Year Projects

Evaluators grade heavily on visual presentation, polish, and intuitiveness:
1. **Curated Color Palette**: Avoid default Flutter blue/purple. Use tailored primary (e.g. Deep Indigo `#3F51B5`, Emerald `#00A86B`, or Royal Blue `#1E3A8A`), smooth surfaces (`#F8FAFC` light / `#0F172A` dark), and high-contrast text.
2. **Consistent Typography**: Use `google_fonts` (e.g., `Plus Jakarta Sans`, `Inter`, or `Outfit`).
3. **Interactive Polish**:
   - Touch targets $\ge 48\times48$ dp.
   - Micro-interactions (ripple effects, card scale on tap, bottom navigation transitions).
   - Empty states with illustrative icons and clear call-to-actions ("No items found. Tap + to add").
   - Form validation with descriptive inline error messages.
