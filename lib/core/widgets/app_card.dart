import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// AppCard is a reusable surface card with clean borders,
/// elevation, and responsive tap feedback.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderSide? border;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? accentColor;
  final List<BoxShadow>? customShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
    this.gradient,
    this.accentColor,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final BorderRadius effectiveRadius = borderRadius ?? AppDimensions.borderRadiusLarge;

    final BoxBorder effectiveBorder;
    if (border != null) {
      effectiveBorder = Border.fromBorderSide(border!);
    } else if (accentColor != null) {
      effectiveBorder = Border.all(
        color: accentColor!.withValues(alpha: 0.35),
        width: 1.5,
      );
    } else {
      effectiveBorder = Border.all(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        width: 1.0,
      );
    }

    final effectiveShadow = customShadow ??
        (isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 10.0,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                  blurRadius: 4.0,
                  offset: const Offset(0, 1),
                ),
              ]);

    final cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? (isDark ? theme.cardColor : Colors.white)) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
        boxShadow: effectiveShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: Stack(
            children: [
              if (accentColor != null)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor!,
                      borderRadius: BorderRadius.only(
                        topLeft: effectiveRadius.topLeft,
                        bottomLeft: effectiveRadius.bottomLeft,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding ?? const EdgeInsets.all(AppDimensions.space16),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );

    return cardWidget;
  }
}
