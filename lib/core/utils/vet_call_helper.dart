import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../features/profile/controllers/settings_controller.dart';
import '../constants/app_colors.dart';

/// Centralized veterinary call helper ensuring no fake numbers are dialed.
/// Dials the farmer's saved vet number directly.
/// If no number is saved, shows an inline modal on the same screen to save and immediately dial.
class VetCallHelper {
  static Future<void> dialVet(BuildContext context) async {
    final settings = Provider.of<SettingsController>(context, listen: false);
    final number = settings.vetPhone?.trim();
    final isUrdu = settings.isUrdu;

    if (number != null && number.isNotEmpty) {
      await _launchPhone(number, context, isUrdu);
    } else {
      if (context.mounted) {
        await _showInlineSaveDialog(context, settings, isUrdu);
      }
    }
  }

  static Future<void> _launchPhone(String number, BuildContext context, bool isUrdu) async {
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
  }

  static Future<void> _showInlineSaveDialog(
    BuildContext context,
    SettingsController settings,
    bool isUrdu,
  ) async {
    final phoneController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.severe.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.severe, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isUrdu ? 'اپنے ویٹ کا نمبر محفوظ کریں' : 'Save Your Vet Number',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isUrdu
                  ? 'ہنگامی رابطے اور مشاورت کے لیے اپنے ویٹرنری ڈاکٹر کا فون نمبر درج کریں:'
                  : 'Enter your veterinarian phone number for direct one-touch emergency calls:',
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                hintText: isUrdu ? 'مثال: 03001234567' : 'e.g. 03001234567',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              isUrdu ? 'منسوخ کریں' : 'Cancel',
              style: const TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.phone_forwarded_rounded, size: 18),
            label: Text(
              isUrdu ? 'محفوظ کریں اور کال کریں' : 'Save & Call',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onPressed: () async {
              final input = phoneController.text.trim();
              if (input.isNotEmpty) {
                await settings.saveVetPhone(input);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (context.mounted) {
                  await _launchPhone(input, context, isUrdu);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
