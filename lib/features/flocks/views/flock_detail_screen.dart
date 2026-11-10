import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/flock_model.dart';
import '../../../data/mock/mock_scans_data.dart';
import '../../../data/repositories/diagnostic_repository.dart';
import '../../scanner/controllers/scanner_controller.dart';
import '../../../routes/app_routes.dart';

class FlockDetailScreen extends StatefulWidget {
  final FlockModel flock;

  const FlockDetailScreen({super.key, required this.flock});

  @override
  State<FlockDetailScreen> createState() => _FlockDetailScreenState();
}

class _FlockDetailScreenState extends State<FlockDetailScreen> {
  List<DiagnosticRecord> _flockScans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  void _loadScans() async {
    final repo = context.read<DiagnosticRepository>();
    final results = await repo.getAllRecords(flockId: widget.flock.id);
    setState(() {
      _flockScans = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flock = widget.flock;
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentScans = _flockScans.where((s) => s.scan.createdAt.isAfter(thirtyDaysAgo));
    final hasActiveRisk = recentScans.any((s) {
      final disease = s.prediction.predictedClass?.toLowerCase() ?? 'healthy';
      final severity = s.prediction.severity?.toLowerCase() ?? 'mild';
      return disease != 'healthy' || severity == 'severe';
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(flock.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shed Overview Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          flock.name,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: hasActiveRisk ? AppColors.severeLight : AppColors.healthyLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          hasActiveRisk ? 'Active Risk' : 'Healthy',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: hasActiveRisk ? AppColors.severe : AppColors.healthy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainerLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          flock.breed ?? 'Standard Breed',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.egg_outlined, size: 18, color: AppColors.secondary),
                          const SizedBox(width: 6),
                          Text(
                            'Total Birds: ${flock.birdCount ?? 'Unspecified'}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.textMutedLight),
                          const SizedBox(width: 6),
                          Text(
                            'Registered: ${AppFormatters.formatDate(flock.createdAt)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (flock.notes != null && flock.notes!.isNotEmpty) ...[
                    const Divider(height: 20),
                    Text(
                      'Shed Notes:',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      flock.notes!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space20),

            // Scan Action
            CustomButton(
              text: 'Scan Dropping for this Flock',
              icon: Icons.camera_alt_outlined,
              onPressed: () async {
                final scanner = context.read<ScannerController>();
                scanner.setFlockId(flock.id);
                await Navigator.pushNamed(context, AppRoutes.scanner);
                if (mounted) {
                  _loadScans();
                }
              },
            ),
            const SizedBox(height: AppDimensions.space24),

            // Diagnostic Timeline for this flock
            const Text(
              'Diagnostic History for this Shed',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_flockScans.isEmpty)
              AppCard(
                padding: const EdgeInsets.all(20),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(Icons.health_and_safety_outlined, size: 40, color: AppColors.primary),
                      SizedBox(height: 8),
                      Text(
                        'No health scans filed for this shed yet.',
                        style: TextStyle(fontSize: 13.5, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _flockScans.length,
                itemBuilder: (context, index) {
                  final item = _flockScans[index];
                  final disease = item.prediction.predictedClass ?? 'healthy';

                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    onTap: () {
                      context.read<ScannerController>().setLastResult(item);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.diagnosticResult,
                        arguments: item,
                      );
                    },
                    child: Row(
                      children: [
                        AppImageView(
                          imagePath: item.scan.imagePath,
                          width: 58,
                          height: 58,
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
                                  StatusBadge.forSeverity(item.prediction.severity),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${AppFormatters.formatConfidence(item.prediction.calibratedConfidence)} confidence',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                              Text(
                                AppFormatters.formatDate(item.scan.createdAt),
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
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }
}
