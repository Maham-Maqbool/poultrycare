import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// AppImageView provides robust, error-tolerant, memory-optimized rendering
/// for local device files (camera snapshots, gallery uploads), asset images,
/// and fallback remote URLs. Includes cacheWidth and cacheHeight constraints
/// to guarantee lightning-fast decoding and offline resilience on low-end devices.
class AppImageView extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final int? cacheWidth;
  final int? cacheHeight;

  const AppImageView({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.cacheWidth,
    this.cacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    Widget content;

    // Derive memory cache dimensions to prevent high-res camera memory bloat
    // Ensure finite dimensions to avoid 'Infinity or NaN toInt' exception when double.infinity is passed
    final int effectiveCacheWidth = cacheWidth ??
        (width != null && width!.isFinite ? (width! * 2.5).round().clamp(60, 1024) : 600);
    final int effectiveCacheHeight = cacheHeight ??
        (height != null && height!.isFinite ? (height! * 2.5).round().clamp(60, 1024) : 600);

    if (path == null || path.trim().isEmpty) {
      content = placeholder ?? _buildPoultryPlaceholder();
    } else if (path.startsWith('http://') || path.startsWith('https://')) {
      content = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _buildPoultryPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: const Color(0xFF0F172A),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      );
    } else if (path.startsWith('assets/')) {
      // Local Flutter bundled assets
      content = Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _buildPoultryPlaceholder(),
      );
    } else {
      // Offline local device storage: Camera photo, gallery image, or local file
      final file = File(path);
      content = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: effectiveCacheWidth,
        cacheHeight: effectiveCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            placeholder ?? _buildPoultryPlaceholder(),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }
    return content;
  }

  Widget _buildPoultryPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF0F172A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.biotech_rounded,
              color: AppColors.primaryLight,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              'Poultry Specimen',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
