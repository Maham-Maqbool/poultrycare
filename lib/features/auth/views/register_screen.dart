import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../../profile/controllers/settings_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _consent = true;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
      consent: _consent,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'نیا اکاؤنٹ بنائیں' : 'Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrdu ? 'پولٹری کیئر میں شمولیت' : 'Join PoultryCare Pro',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  isUrdu
                      ? 'اپنے شیڈز اور پرندوں کی صحت کی خودکار نگرانی کریں'
                      : 'Track your sheds and get tailored poultry health advice',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                CustomTextField(
                  controller: _nameController,
                  label: isUrdu ? 'فارم یا کسان کا نام' : 'Farm or Farmer Name',
                  hint: isUrdu ? 'مثلاً چوہدری پولٹری فارم' : 'e.g. Ali Farm / Tariq Poultry',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => AppValidators.validateRequired(v, 'Name'),
                ),
                const SizedBox(height: AppDimensions.space16),
                CustomTextField(
                  controller: _identifierController,
                  label: isUrdu ? 'موبائل نمبر یا ای میل' : 'Mobile Phone or Email',
                  hint: isUrdu ? 'مثلاً 03001234567' : 'e.g. 03001234567 or email@domain.com',
                  prefixIcon: Icons.contact_mail_outlined,
                  validator: AppValidators.validateEmailOrPhone,
                ),
                const SizedBox(height: AppDimensions.space16),
                CustomTextField(
                  controller: _passwordController,
                  label: isUrdu ? 'پاس ورڈ (خفیہ کوڈ)' : 'Password',
                  hint: isUrdu ? 'کم از کم 6 ہندسے' : 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.space20),

                // Research and Model Improvement Consent
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight.withValues(alpha: 0.5),
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _consent,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setState(() {
                            _consent = val ?? false;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUrdu ? 'تصویری تشخیص کی بہتری کی اجازت' : 'Consent for Image Improvement',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isUrdu
                                  ? 'تصاویر کو محفوظ طریقے سے ماڈل کی درستگی بڑھانے کے لیے استعمال کیا جا سکتا ہے'
                                  : 'Allow anonymized encrypted image tokens to be retained locally for diagnostic model refinement.',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                CustomButton(
                  text: isUrdu ? 'اکاؤنٹ رجسٹر کریں' : 'Register Account',
                  isLoading: auth.isLoading,
                  onPressed: _submitRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
