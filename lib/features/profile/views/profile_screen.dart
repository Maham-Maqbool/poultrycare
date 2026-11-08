import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/controllers/dashboard_controller.dart';
import '../controllers/settings_controller.dart';
import '../../../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final dashboard = context.watch<DashboardController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'فارم اکاؤنٹ' : 'Farm Account'),
        actions: [
          IconButton(
            tooltip: isUrdu ? 'ایپ سیٹنگز' : 'App Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // User Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.primaryContainerLight,
                    child: Text(
                      (user.displayName ?? 'F')[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.displayName ?? (isUrdu ? 'مہمان فارمر' : 'Guest Farmer'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? user.phone ?? (isUrdu ? 'لوکل ڈیوائس سیشن' : 'Guest Session (Local Device)'),
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: user.isGuest ? AppColors.mildLight : AppColors.primaryContainerLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user.isGuest
                          ? (isUrdu ? 'مہمان موڈ' : 'Guest Mode')
                          : (isUrdu ? 'تصدیق شدہ فارمر' : 'Verified Farmer'),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: user.isGuest ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Farm Activity Stats Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(isUrdu ? 'کل اسکینز' : 'Total Scans', '${dashboard.totalScans}'),
                  _buildStatItem(isUrdu ? 'صحت مند شرح' : 'Healthy Rate', '${dashboard.healthyRate.toStringAsFixed(0)}%'),
                  _buildStatItem(isUrdu ? 'فعال شیڈز' : 'Active Sheds', '${dashboard.flockCount}'),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Navigation Menu Card
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.history_rounded, color: AppColors.primary),
                    title: Text(isUrdu ? 'تشخیصی تاریخ و ریکارڈز' : 'Diagnostic History Archive'),
                    subtitle: Text(
                      isUrdu ? 'پچھلے ٹیسٹ اور علاج کا ریکارڈ دیکھیں' : 'Review past fecal scans and treatments',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.history);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.home_work_outlined, color: AppColors.primary),
                    title: Text(isUrdu ? 'پولٹری شیڈز کا انتظام' : 'Manage Farm Flocks'),
                    subtitle: Text(
                      isUrdu ? 'پرندوں کی تعداد اور نسل کا اندراج' : 'Update bird counts and breeds',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.flocks);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                    title: Text(isUrdu ? 'امراض کی انسائیکلوپیڈیا' : 'Poultry Disease Encyclopedia'),
                    subtitle: Text(
                      isUrdu ? 'علامات، ادویات اور حفاظتی اقدامات' : 'Clinical symptoms and medicines',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.encyclopedia);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
                    title: Text(isUrdu ? 'سیٹنگز اور زبان' : 'Settings & Localization'),
                    subtitle: Text(
                      isUrdu ? 'اردو زبان، نائٹ موڈ، کسٹمر کیئر' : 'Urdu language, dark mode, AI version',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.settings);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Logout / Switch User Button
            CustomButton(
              text: user.isGuest
                  ? (isUrdu ? 'اکاؤنٹ میں سائن ان کریں' : 'Sign In with Account')
                  : (isUrdu ? 'اکاؤنٹ سے لاگ آؤٹ' : 'Sign Out'),
              variant: ButtonVariant.outlined,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
