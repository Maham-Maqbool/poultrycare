import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
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
                  'Join PoultryCare',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimensions.space4),
                Text(
                  'Track your sheds and get tailored poultry health advice',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Farm or Farmer Name',
                  hint: 'e.g. Ali Farm / Maham Maqbool',
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) => AppValidators.validateRequired(v, 'Name'),
                ),
                const SizedBox(height: AppDimensions.space16),
                CustomTextField(
                  controller: _identifierController,
                  label: 'Mobile Phone or Email',
                  hint: 'e.g. 03001234567 or email@domain.com',
                  prefixIcon: Icons.contact_mail_outlined,
                  validator: AppValidators.validateEmailOrPhone,
                ),
                const SizedBox(height: AppDimensions.space16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: AppDimensions.space20),
                // Chapter 5 consent_to_retain_images requirement
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight.withOpacity(0.5),
                    borderRadius: AppDimensions.borderRadiusMedium,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                            const Text(
                              'Consent for Image Research',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Allow encrypted, anonymized scan images to assist retraining the poultry AI model.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space28),
                CustomButton(
                  text: 'Register Account',
                  isLoading: auth.isLoading,
                  onPressed: _submitRegister,
                ),
                const SizedBox(height: AppDimensions.space16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Already registered? Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
