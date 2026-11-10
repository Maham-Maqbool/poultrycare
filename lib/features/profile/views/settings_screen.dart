import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/vet_call_helper.dart';
import '../../../core/utils/bidi_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _vetPhoneController;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final settings = Provider.of<SettingsController>(context, listen: false);
      _vetPhoneController = TextEditingController(text: settings.vetPhone ?? '');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _vetPhoneController.dispose();
    super.dispose();
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

            // My Vet Number Section (Finding C1)
            Text(
              isUrdu ? 'اپنے ویٹ کا نمبر (My Vet Number)' : 'My Veterinarian Contact',
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
                      const Icon(Icons.medical_services_outlined, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'مستند ویٹرنری ڈاکٹر کا رابطہ' : 'Emergency Doctor Contact',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isUrdu
                        ? 'ہنگامی صورتحال میں فوری رابطہ کے لیے اپنے مقامی ڈاکٹر یا ہیلپ لائن کا درست نمبر درج کریں:'
                        : 'Enter your local poultry veterinarian or clinic phone number for instant one-touch emergency calls:',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _vetPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                            hintText: isUrdu ? 'مثال: 03001234567' : 'e.g., 03001234567',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final newNumber = _vetPhoneController.text.trim();
                          await settings.saveVetPhone(newNumber);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUrdu
                                      ? (newNumber.isNotEmpty
                                          ? 'ڈاکٹر کا نمبر محفوظ ہو گیا ہے'
                                          : 'ڈاکٹر کا نمبر ہٹا دیا گیا ہے')
                                      : (newNumber.isNotEmpty
                                          ? 'Vet phone number saved successfully.'
                                          : 'Vet phone number removed.'),
                                ),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                        child: Text(
                          isUrdu ? 'محفوظ کریں' : 'Save',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  if (settings.vetPhone != null && settings.vetPhone!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      isUrdu
                          ? 'محفوظ شدہ رابطہ: ${BidiUtils.ltr(settings.vetPhone!)}'
                          : 'Currently Saved: ${settings.vetPhone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                          isUrdu
                              ? (settings.vetPhone != null && settings.vetPhone!.isNotEmpty
                                  ? 'محفوظ شدہ ڈاکٹر: ${BidiUtils.ltr(settings.vetPhone!)}'
                                  : 'ویٹرنری ڈاکٹر: نمبر محفوظ نہیں (اوپر درج کریں)')
                              : (settings.vetPhone != null && settings.vetPhone!.isNotEmpty
                                  ? 'Saved Vet: ${settings.vetPhone}'
                                  : 'Veterinary Doctor: None saved (configure above)'),
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
                    text: isUrdu ? 'اپنے ویٹرنری ڈاکٹر کو کال کریں' : 'Call Saved Veterinary Doctor',
                    onPressed: () => VetCallHelper.dialVet(context),
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
