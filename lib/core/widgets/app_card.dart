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

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveRadius = borderRadius ?? AppDimensions.borderRadiusLarge;

    final cardWidget = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? (isDark ? theme.cardColor : Colors.white),
        borderRadius: effectiveRadius,
        border: border != null
            ? Border.fromBorderSide(border!)
            : Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.space16),
            child: child,
          ),
        ),
      ),
    );

    return cardWidget;
  }
}
