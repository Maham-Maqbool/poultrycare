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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await auth.login(
      _identifierController.text.trim(),
      _passwordController.text,
    );
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.mainShell);
    }
  }

  void _continueAsGuest() async {
    final auth = context.read<AuthController>();
    await auth.continueAsGuest();
    if (mounted) {
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            icon: const Icon(Icons.language_rounded, size: 18),
            label: Text(
              isUrdu ? 'English' : 'اردو',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            onPressed: settings.toggleLocale,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainerLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.egg_alt_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space20),
                  Center(
                    child: Text(
                      isUrdu ? 'پولٹری کیئر میں خوش آمدید' : 'Welcome to PoultryCare Pro',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space4),
                  Center(
                    child: Text(
                      isUrdu
                          ? 'اپنے پولٹری فلاک کے معائنے اور تاریخ کے لیے سائن ان کریں'
                          : 'Sign in to sync your sheds and diagnostic history',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space32),
                  if (auth.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.severeLight,
                        borderRadius: AppDimensions.borderRadiusMedium,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.severe, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(color: AppColors.severe, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],
                  CustomTextField(
                    controller: _identifierController,
                    label: isUrdu ? 'موبائل نمبر یا ای میل' : 'Email or Mobile Number',
                    hint: isUrdu ? 'مثلاً 03001234567 یا فارمر ای میل' : 'e.g. 03001234567 or email@farm.com',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: AppValidators.validateEmailOrPhone,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  CustomTextField(
                    controller: _passwordController,
                    label: isUrdu ? 'پاس ورڈ (خفیہ کوڈ)' : 'Password',
                    hint: isUrdu ? 'اپنا پاس ورڈ درج کریں' : 'Enter your password',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  CustomButton(
                    text: isUrdu ? 'اکاؤنٹ میں لاگ ان کریں' : 'Sign In to Account',
                    isLoading: auth.isLoading,
                    onPressed: _submitLogin,
                  ),
                  const SizedBox(height: AppDimensions.space12),
                  CustomButton(
                    text: isUrdu
                        ? 'بغیر لاگ ان فوری اسکین کریں (بطور مہمان)'
                        : 'Continue as Guest (Instant Scan)',
                    variant: ButtonVariant.outlined,
                    onPressed: _continueAsGuest,
                  ),
                  const SizedBox(height: AppDimensions.space24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isUrdu ? 'کیا اکاؤنٹ موجود نہیں ہے؟' : "Don't have an account?",
                          style: const TextStyle(fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          child: Text(
                            isUrdu ? 'نیا اکاؤنٹ بنائیں' : 'Create Account',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
