import 'package:flutter/material.dart';

/// AppDimensions defines consistent spacing, padding, radiuses,
/// and touch ergonomics across PoultryCare screens.
class AppDimensions {
  // Spacing & Padding
  static const double space2 = 2.0;
  static const double space4 = 4.0;
  static const double space6 = 6.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space28 = 28.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Screen Padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );

  static const EdgeInsets screenPaddingWide = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );

  // Border Radiuses
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusCircular = 100.0;

  static const BorderRadius borderRadiusSmall = BorderRadius.all(Radius.circular(radiusSmall));
  static const BorderRadius borderRadiusMedium = BorderRadius.all(Radius.circular(radiusMedium));
  static const BorderRadius borderRadiusLarge = BorderRadius.all(Radius.circular(radiusLarge));
  static const BorderRadius borderRadiusXLarge = BorderRadius.all(Radius.circular(radiusXLarge));
  static const BorderRadius borderRadiusCircular = BorderRadius.all(Radius.circular(radiusCircular));

  // Touch Ergonomics (Mobile-first requirement: minimum 48dp)
  static const double minTouchTarget = 48.0;
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 40.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 22.0;
  static const double iconLarge = 28.0;
  static const double iconXLarge = 36.0;
  static const double iconHero = 56.0;

  // Elevations
  static const double elevationNone = 0.0;
  static const double elevationLow = 1.0;
  static const double elevationMedium = 3.0;
  static const double elevationHigh = 6.0;
}
