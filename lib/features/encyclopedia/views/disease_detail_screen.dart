import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/audio_player_widget.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/disease_model.dart';
import '../../../data/models/treatment_model.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../profile/controllers/settings_controller.dart';

class DiseaseDetailScreen extends StatefulWidget {
  final DiseaseModel disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  State<DiseaseDetailScreen> createState() => _DiseaseDetailScreenState();
}

class _DiseaseDetailScreenState extends State<DiseaseDetailScreen> {
  List<TreatmentModel> _treatments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  void _loadTreatments() async {
    final repo = context.read<DiseaseRepository>();
    final all = await repo.getAllTreatments();
    setState(() {
      _treatments = all
          .where((t) => t.diseaseCode.toLowerCase() == widget.disease.code.toLowerCase())
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;
    final d = widget.disease;

    return Scaffold(
      appBar: AppBar(
        title: Text(d.getName(isUrdu)),
        actions: [
          IconButton(
            tooltip: 'Language Toggle',
            icon: Icon(isUrdu ? Icons.language : Icons.translate),
            onPressed: settings.toggleLocale,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and Header Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge.forDisease(d.code, isLarge: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d.getName(isUrdu),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.getSummary(isUrdu),
                    style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Spoken Audio Narration
            AudioPlayerWidget(
              title: isUrdu
                  ? '${d.nameUr}: آڈیو رہنمائی سنیں'
                  : '${d.nameEn}: Spoken Overview',
              isUrdu: isUrdu,
              diseaseName: d.code,
              severity: null,
            ),
            const SizedBox(height: AppDimensions.space16),

            // Clinical Visible Signs Card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isUrdu ? 'پرندوں میں ظاہری علامات' : 'Key Diagnostic Signs',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...d.getSigns(isUrdu).map((sign) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_right_rounded, size: 20, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                sign,
                                style: const TextStyle(fontSize: 13.5, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Treatment Protocols Section
            if (d.code.toLowerCase() == 'healthy') ...[
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.healthy, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isUrdu ? 'کسی دوا کی ضرورت نہیں' : 'No treatment needed',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.healthy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isUrdu
                                ? 'معمول کی نگہداشت اور روزانہ نگرانی جاری رکھیں۔ متوازن خوراک اور صاف پانی دیں۔'
                                : 'Routine care and daily monitoring. Provide balanced feed and clean hydration.',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                isUrdu ? 'طبی علاج کے پروٹوکولز' : 'Clinical Treatment Regimens',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_treatments.isEmpty)
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    isUrdu
                        ? 'اس مرض کے لیے مخصوص علاج دستیاب نہیں ہے۔'
                        : 'No specific treatment tier available for this disease.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  ),
                )
              else
                ..._treatments.map((t) => AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge.forSeverity(t.severity),
                              StatusBadge.forUrgency(t.urgency),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isUrdu ? 'تجویز کردہ ادویات:' : 'Prescriptions:',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          ...t.getMedicines(isUrdu).map((m) => Padding(
                                padding: const EdgeInsets.only(left: 6, bottom: 4),
                                child: Text('• $m', style: const TextStyle(fontSize: 13)),
                              )),
                          const SizedBox(height: 8),
                          Text(
                            isUrdu ? 'بائیو سیکیورٹی اور نگہداشت:' : 'Biosecurity & Care:',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          ...t.getCareSteps(isUrdu).take(2).map((c) => Padding(
                                padding: const EdgeInsets.only(left: 6, bottom: 4),
                                child: Text('• $c', style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight)),
                              )),
                        ],
                      ),
                    )),
            ],
            const SizedBox(height: AppDimensions.space24),
          ],
        ),
      ),
    );
  }
}
