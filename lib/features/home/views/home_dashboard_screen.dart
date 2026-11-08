import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../scanner/controllers/scanner_controller.dart';
import '../../flocks/controllers/flock_controller.dart';
import '../../profile/controllers/settings_controller.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../../routes/app_routes.dart';

/// HomeDashboardScreen provides the primary commercial poultry farming dashboard.
/// Features a farm overview banner, 4 oversized quick action cards,
/// farm telemetry vitals, audio advisory, and local SQLite recent detections.
class HomeDashboardScreen extends StatefulWidget {
  final void Function(int index)? onTabSelected;

  const HomeDashboardScreen({super.key, this.onTabSelected});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardController>().loadDashboard();
        context.read<FlockController>().loadFlocks();
      }
    });
  }

  void _navigateToTabOrRoute(int tabIndex, String routeName) {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(tabIndex);
    } else {
      Navigator.pushNamed(context, routeName);
    }
  }

  Future<void> _callEmergencyVet(BuildContext context) async {
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
            content: Text('Emergency Helpline: +92 300 1234567'),
            backgroundColor: AppColors.severe,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final dashboard = context.watch<DashboardController>();
    final flockController = context.watch<FlockController>();
    final scanner = context.read<ScannerController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    final user = auth.user;
    final farmName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : 'Chaudhary Poultry Farms';

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainerLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.egg_alt_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PoultryCare Pro',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    farmName,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Language Toggle Action (English <-> Urdu)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: settings.toggleLocale,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 11, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    isUrdu ? 'EN' : 'اردو',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // History Screen Action
          IconButton(
            tooltip: isUrdu ? 'تشخیصی تاریخ' : 'Diagnostic History',
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.history);
            },
          ),
          // Settings Screen Action
          IconButton(
            tooltip: isUrdu ? 'سیٹنگز' : 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dashboard.loadDashboard();
          await flockController.loadFlocks();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. WELCOME BANNER ("Chaudhary Poultry Farms / PoultryCare Pro")
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF132D18), const Color(0xFF0F172A)]
                        : [AppColors.primary, const Color(0xFF1E5E22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppDimensions.borderRadiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.verified_rounded, size: 13, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'PoultryCare Pro',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                farmName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isUrdu
                                    ? 'خوش آمدید: فلاک ہیلتھ مانیٹرنگ اور مصنوعی ذہانت سے فوری تشخیصی پورٹل فعال ہے۔'
                                    : 'Welcome: Commercial flock health monitoring & AI fecal diagnostics active.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Farm Vitals Telemetry Grid
              Text(
                isUrdu ? 'فارم کے اہم اعداد و شمار' : 'Farm Telemetry & Status',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: isUrdu ? 'کل اسکینز' : 'Total Scans',
                      value: '${dashboard.totalScans}',
                      icon: Icons.biotech_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: isUrdu ? 'صحت مند شرح' : 'Healthy Rate',
                      value: '${dashboard.healthyRate.toStringAsFixed(0)}%',
                      icon: Icons.health_and_safety_outlined,
                      color: AppColors.healthy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: isUrdu ? 'زیر نگرانی شیڈز' : 'Monitored Sheds',
                      value: '${dashboard.flockCount}',
                      icon: Icons.home_work_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      title: isUrdu ? 'شدید خطرات' : 'Severe Alerts',
                      value: '${dashboard.severeAlerts}',
                      icon: Icons.notification_important_outlined,
                      color: AppColors.severe,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              // 2. THE 4 HIGH-CONTRAST QUICK ACTION CARDS
              Text(
                isUrdu ? 'فوری سروسز و ایکشنز' : 'Quick Actions & Services',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // CARD 1: QUICK SCAN (Scan Fecal Image)
              AppCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? const Color(0xFF132D18) : const Color(0xFFF0FDF4),
                border: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                onTap: () => _navigateToTabOrRoute(1, AppRoutes.scanner),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.camera_enhance_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'فوری اسکین (بیٹھ کی تصویر)' : 'Quick Scan (Scan Fecal Image)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUrdu
                                ? 'کیمرہ یا گیلری سے مرغی کے فضلے کا فوری تجزیہ کریں'
                                : 'Instant on-device AI pathogen detection via camera/gallery',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CARD 2: FLOCK STATUS
              AppCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: BorderSide(color: AppColors.secondary.withValues(alpha: 0.3)),
                onTap: () => _navigateToTabOrRoute(2, AppRoutes.flocks),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'فلاک و شیڈز کی صورتحال' : 'Flock Status & Sheds',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.secondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUrdu
                                ? 'زیر نگرانی شیڈز، پرندوں کی تعداد اور الرٹس دیکھیں'
                                : 'Monitor farm sheds, bird counts, and active health warnings',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.secondary),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CARD 3: DISEASE LIBRARY
              AppCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFFAF5FF),
                border: BorderSide(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                onTap: () => _navigateToTabOrRoute(3, AppRoutes.encyclopedia),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'بیماریوں کی گائیڈ لائبریری' : 'Poultry Disease Library',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF8B5CF6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUrdu
                                ? 'رانی کھیت، کوکسیڈیوسس، اور سالمونیلا کی علامات و علاج'
                                : 'Clinical guide for Newcastle, Coccidiosis & Salmonella',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF8B5CF6)),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // CARD 4: EMERGENCY VET HELPLINE
              AppCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
                border: BorderSide(color: AppColors.severe.withValues(alpha: 0.4)),
                onTap: () => _callEmergencyVet(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.severe,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.phone_in_talk_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? '24/7 ڈاکٹر ایمرجنسی ہیلپ لائن' : 'Emergency Vet Helpline',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.severe,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isUrdu
                                ? 'ہنگامی مشورے کے لیے فوراً کال کریں: +92 300 1234567'
                                : 'One-touch direct vet call: +92 300 1234567',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.severe,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isUrdu ? 'کال کریں' : 'Call Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Daily Audio Advisory Tip (With Real Text-to-Speech Voice Guide)
              AudioPlayerWidget(
                title: isUrdu
                    ? 'روزانہ کی آڈیو رہنمائی: برادے کی نمی کنٹرول'
                    : 'Daily Advisory: Broiler Litter Moisture Control',
                durationText: '0:45',
                isUrdu: isUrdu,
                customScript: isUrdu
                    ? 'محترم کسان بھائی: شیڈ میں موجود برادے کو خشک رکھیں۔ ضرورت سے زیادہ نمی امونیا گیس اور کوکسیڈیوسس کے جراثیم کو جنم دیتی ہے۔ روزانہ برادے کی گہرائی چیک کریں اور گیلے حصے فوری تبدیل کریں۔'
                    : 'Attention Farmers: Keep poultry shed litter dry at all times. Excessive moisture triggers ammonia buildup and rapid coccidiosis sporulation. Check and turn litter regularly.',
              ),
              const SizedBox(height: AppDimensions.space20),

              // 3. RECENT DETECTIONS SUMMARY WIDGET (FETCHED FROM LOCAL SQLITE)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      isUrdu ? 'حالیہ ٹیسٹ و تشخیص (لوکل ڈیٹا بیس)' : 'Recent Detections & History',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.history);
                    },
                    child: Text(
                      isUrdu ? 'تمام دیکھیں' : 'View All',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (dashboard.recentRecords.isEmpty)
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.biotech_outlined, size: 36, color: AppColors.textMutedLight),
                        const SizedBox(height: 8),
                        Text(
                          isUrdu ? 'ابھی تک کوئی اسکین محفوظ نہیں ہے' : 'No Scans Recorded Yet',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUrdu
                              ? 'کیمرے سے تصویر کھینچیں یا گیلری سے منتخب کر کے پہلا اسکین شروع کریں۔'
                              : 'Capture a dropping photo with your camera or select from gallery to start.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.camera_alt_rounded, size: 16),
                          label: Text(isUrdu ? 'پہلا اسکین شروع کریں' : 'Start First Scan'),
                          onPressed: () => _navigateToTabOrRoute(1, AppRoutes.scanner),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dashboard.recentRecords.length,
                  itemBuilder: (context, index) {
                    final item = dashboard.recentRecords[index];
                    final pred = item.prediction;
                    final scan = item.scan;
                    final disease = pred.predictedClass ?? 'healthy';

                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      onTap: () async {
                        final treat = await context
                            .read<DiseaseRepository>()
                            .getTreatment(disease, pred.severity ?? 'mild');
                        scanner.setLastResult(item, treat);
                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.diagnosticResult,
                            arguments: item,
                          );
                        }
                      },
                      child: Row(
                        children: [
                          AppImageView(
                            imagePath: scan.imagePath,
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    StatusBadge.forDisease(disease),
                                    StatusBadge.forSeverity(pred.severity),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '${AppFormatters.formatConfidence(pred.calibratedConfidence)} ${isUrdu ? 'یقینی' : 'confidence'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                Text(
                                  AppFormatters.relativeTime(scan.createdAt),
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.textMutedLight,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: AppDimensions.space28),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
