import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _callHelpline(BuildContext context) async {
    const phoneNumber = '+923001234567';
    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veterinary Support: +92 300 1234567'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'ایپ سیٹنگز اور سپورٹ' : 'App Settings & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display & Localization
            Text(
              isUrdu ? 'ظاہری شکل اور زبان' : 'Appearance & Language',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: Text(isUrdu ? 'ڈارک موڈ (نائٹ موڈ)' : 'Dark Mode'),
                    subtitle: Text(
                      isUrdu
                          ? 'دھوپ میں اسکرین کی چمک کم کرتا ہے اور بیٹری بچاتا ہے'
                          : 'Reduces outdoor screen glare and saves battery',
                      style: const TextStyle(fontSize: 12),
                    ),
                    value: settings.isDarkMode,
                    activeThumbColor: AppColors.primary,
                    onChanged: (_) => settings.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: Text(isUrdu ? 'ایپ کی زبان (Language)' : 'App Language (زبان)'),
                    subtitle: Text(isUrdu ? 'اردو (Urdu)' : 'English'),
                    trailing: DropdownButton<String>(
                      value: settings.locale,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'ur', child: Text('اردو (Urdu)')),
                      ],
                      onChanged: (val) {
                        if (val != null) settings.setLocale(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Privacy & Temporary Storage
            Text(
              isUrdu ? 'پرائیویسی اور اسٹوریج صفائی' : 'Privacy & Storage Hygiene',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.cleaning_services_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu
                              ? 'عارضی کیشے: ${(settings.cacheSizeKb / 1024).toStringAsFixed(1)} MB'
                              : 'Temporary Image Cache: ${(settings.cacheSizeKb / 1024).toStringAsFixed(1)} MB',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isUrdu
                        ? 'موبائل اسٹوریج محفوظ رکھنے کے لیے عارضی ٹیسٹ فائلز صاف کی جا سکتی ہیں'
                        : 'Temporary diagnostic image caches can be cleared safely without losing diagnosis history.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: settings.cacheSizeKb == 0
                        ? (isUrdu ? 'کیشے صاف ہے' : 'Cache Cleaned')
                        : (isUrdu ? 'عارضی تصویر کیشے ابھی صاف کریں' : 'Purge Temporary Image Cache Now'),
                    variant: ButtonVariant.outlined,
                    onPressed: settings.cacheSizeKb == 0
                        ? null
                        : () async {
                            await settings.clearCache();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isUrdu ? 'عارضی کیشے صاف کر دیا گیا' : 'Temporary image cache purged.',
                                  ),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Commercial Customer Support & Veterinary Hotline
            Text(
              isUrdu ? 'کسٹمر سپورٹ اور ویٹرنری فیلڈ سروس' : 'PoultryCare Support & Field Service',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PoultryCare Commercial Field Edition',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version: 2.4.0 Commercial Pro (Offline AI Enabled)',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isUrdu
                        ? 'پولٹری فارمرز کے لیے 24 گھنٹے دستیاب تشخیصی سروس اور ویٹرنری ہیلپ لائن:'
                        : '24/7 dedicated support and veterinary advisory for commercial poultry farms:',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone_in_talk_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'ویٹرنری ہیلپ لائن: +92 300 1234567' : 'Veterinary Helpline: +92 300 1234567',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Email: support@poultrycare.farm',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: isUrdu ? 'سپورٹ ہیلپ لائن پر کال کریں' : 'Call Support Helpline',
                    onPressed: () => _callHelpline(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }
}
