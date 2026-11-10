import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../features/profile/controllers/settings_controller.dart';
import '../../routes/app_routes.dart';
import '../constants/app_colors.dart';

/// Centralized veterinary call helper ensuring no fake numbers are dialed.
/// Dials the farmer's saved vet number or directs them to Settings to save one.
class VetCallHelper {
  static Future<void> dialVet(BuildContext context) async {
    final settings = Provider.of<SettingsController>(context, listen: false);
    final number = settings.vetPhone?.trim();
    final isUrdu = settings.isUrdu;

    if (number != null && number.isNotEmpty) {
      final cleanNumber = number.replaceAll(' ', '');
      final uri = Uri.parse('tel:$cleanNumber');
      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isUrdu ? 'ڈاکٹر کا فون: $number' : 'Vet Phone: $number',
              ),
              backgroundColor: AppColors.severe,
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.phone_missed_rounded, color: AppColors.severe, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isUrdu ? 'پہلے اپنے ویٹ کا نمبر محفوظ کریں' : 'Save Vet Number First',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Text(
              isUrdu
                  ? 'آپ نے ابھی تک اپنے ویٹرنری ڈاکٹر کا نمبر سیو نہیں کیا ہے۔ براہ کرم سیٹنگز میں جا کر اپنے علاقے کے ڈاکٹر کا نمبر درج کریں۔'
                  : 'You have not saved your veterinarian phone number yet. Please configure it in Settings so you can call them directly in an emergency.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  isUrdu ? 'منسوخ کریں' : 'Cancel',
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
                child: Text(
                  isUrdu ? 'سیٹنگز کھولیں' : 'Open Settings',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
