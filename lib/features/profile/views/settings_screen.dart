import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings & System Info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display & Localization
            const Text(
              'Appearance & Language',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primary),
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Reduces outdoor screen glare and saves battery'),
                    value: settings.isDarkMode,
                    activeColor: AppColors.primary,
                    onChanged: (_) => settings.toggleTheme(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                    title: const Text('App Language (زبان)'),
                    subtitle: Text(settings.isUrdu ? 'Urdu (اردو)' : 'English'),
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

            // AI Model Registry (Chapter 5 model_versions table)
            const Text(
              'AI Model Registry & Diagnostics',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MobileNetV3-Poultry',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.healthyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(color: AppColors.healthy, fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Version: v1.2.0-quantized | Backbone: MobileNetV3-Small',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric('Macro F1', '94.6%'),
                      _buildMetric('Balanced Acc', '94.1%'),
                      _buildMetric('MCC', '0.92'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Privacy & Temporary Storage (FR-12)
            const Text(
              'Privacy & Storage Hygiene',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                      Text(
                        'Temporary Image Cache: ${(settings.cacheSizeKb / 1024).toStringAsFixed(1)} MB',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Per requirement FR-12, raw diagnostic photos are held in temporary storage and purged after result compilation.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: settings.cacheSizeKb == 0 ? 'Cache Cleaned' : 'Purge Temporary Image Cache Now',
                    variant: ButtonVariant.outlined,
                    onPressed: settings.cacheSizeKb == 0
                        ? null
                        : () async {
                            await settings.clearCache();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Temporary image cache purged.')),
                              );
                            }
                          },
                  ),
                  const Divider(height: 24),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Anonymized Research Consent', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Allow encrypted feature hashes for model retraining', style: TextStyle(fontSize: 12)),
                    value: settings.imageRetentionConsent,
                    activeColor: AppColors.primary,
                    onChanged: settings.toggleConsent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // FYP Attribution & Credits
            const Text(
              'About Project & Institution',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poultry Disease Detection & Severity Assessment',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'BS Computer Science Final Year Project (2023-2027)',
                    style: TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Khwaja Fareed University of Engineering & Information Technology (KFUEIT), Rahim Yar Khan',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                  ),
                  const Divider(height: 20),
                  const Text(
                    'Student Developers:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                  const SizedBox(height: 4),
                  const Text('• Isha Ishtiaq (COSC232101047)', style: TextStyle(fontSize: 13)),
                  const Text('• Maham Maqbool (COSC232101029)', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text(
                    'Project Supervisor:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                  ),
                  const SizedBox(height: 4),
                  const Text('• Dr. Shahzad Hussain', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }

  static Widget _buildMetric(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
      ],
    );
  }
}
