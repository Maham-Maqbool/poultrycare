import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../routes/app_routes.dart';
import '../controllers/scanner_controller.dart';
import '../../flocks/controllers/flock_controller.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  void _showSamplePicker(BuildContext context) {
    final scanner = context.read<ScannerController>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Test Sample Image',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose an authentic poultry fecal dropping photograph for instant demonstration:',
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
              ),
              const SizedBox(height: 16),
              _buildSampleTile(
                ctx,
                title: 'Coccidiosis (Bloody / Mucoid)',
                subtitle: 'Severe reddish mucoid dropping',
                imagePath: AppAssets.sampleCoccidiosis,
                disease: 'coccidiosis',
                onSelect: () {
                  scanner.setImagePath(AppAssets.sampleCoccidiosis, targetDisease: 'coccidiosis');
                  Navigator.pop(ctx);
                },
              ),
              _buildSampleTile(
                ctx,
                title: 'Newcastle Disease (Greenish Watery)',
                subtitle: 'Fluorescent green diarrhea',
                imagePath: AppAssets.sampleNewcastle,
                disease: 'ncd',
                onSelect: () {
                  scanner.setImagePath(AppAssets.sampleNewcastle, targetDisease: 'ncd');
                  Navigator.pop(ctx);
                },
              ),
              _buildSampleTile(
                ctx,
                title: 'Salmonella (Chalky White)',
                subtitle: 'Watery white vent paste',
                imagePath: AppAssets.sampleSalmonella,
                disease: 'salmonella',
                onSelect: () {
                  scanner.setImagePath(AppAssets.sampleSalmonella, targetDisease: 'salmonella');
                  Navigator.pop(ctx);
                },
              ),
              _buildSampleTile(
                ctx,
                title: 'Healthy (Normal Digestion)',
                subtitle: 'Firm cylindrical with white urate cap',
                imagePath: AppAssets.sampleHealthy,
                disease: 'healthy',
                onSelect: () {
                  scanner.setImagePath(AppAssets.sampleHealthy, targetDisease: 'healthy');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildSampleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imagePath,
    required String disease,
    required VoidCallback onSelect,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          imagePath,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 52,
            height: 52,
            color: AppColors.primaryContainerLight,
            child: const Icon(Icons.broken_image, color: AppColors.primary),
          ),
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onSelect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanner = context.watch<ScannerController>();
    final flockController = context.watch<FlockController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Diagnostic Studio'),
        actions: [
          IconButton(
            tooltip: 'Pick Test Sample',
            icon: const Icon(Icons.collections_bookmark_outlined),
            onPressed: () => _showSamplePicker(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview & Capture Container
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 220,
                          width: double.infinity,
                          color: Colors.black,
                          child: scanner.selectedImagePath != null
                              ? Image.network(
                                  scanner.selectedImagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.image, size: 64, color: Colors.white54),
                                  ),
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 56,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.center_focus_strong, size: 14, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Focal Target',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Pick Image'),
                            onPressed: () => _showSamplePicker(context),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('Camera'),
                            onPressed: () {
                              scanner.setImagePath(AppAssets.sampleNewcastle, targetDisease: 'ncd');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Simulated live camera snapshot loaded.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Image Quality Validation Checklist (FR-11)
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Image Quality Checks',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: scanner.isImageValid ? AppColors.healthyLight : AppColors.severeLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          scanner.isImageValid ? 'Ready for AI' : 'Check Quality',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scanner.isImageValid ? AppColors.healthy : AppColors.severe,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCheckRow(
                    title: 'Lighting & Visibility',
                    passed: scanner.lightingPassed,
                    onToggle: scanner.toggleLighting,
                  ),
                  _buildCheckRow(
                    title: 'Focus & Sharpness',
                    passed: scanner.sharpnessPassed,
                    onToggle: scanner.toggleSharpness,
                  ),
                  _buildCheckRow(
                    title: 'Single Dropping in Focus',
                    passed: scanner.singleDroppingPassed,
                    onToggle: scanner.toggleSingleDropping,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Target Flock Assignment
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assign to Farm Flock',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: scanner.selectedFlockId,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: flockController.flocks.map((f) {
                      return DropdownMenuItem<String>(
                        value: f.id,
                        child: Text(
                          '${f.name} (${f.birdCount ?? 0} birds)',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: scanner.setFlockId,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3-Question Clinical Flock Triage (Chapter 5)
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medical_services_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Clinical Flock Triage (3 Questions)',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'These signals combine with photo classification to derive true disease severity:',
                    style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12.5),
                  ),
                  const Divider(height: 24),

                  // Q1: Lethargy
                  const Text(
                    '1. Lethargy & Droopy Birds:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTriageChip(
                        label: 'None',
                        selected: scanner.lethargy == 'None',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'None',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: 'Under 10% of birds',
                        selected: scanner.lethargy == 'Under 10% of birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'Under 10% of birds',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: 'Over 10% of birds',
                        selected: scanner.lethargy == 'Over 10% of birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'Over 10% of birds',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Q2: Intake Drop
                  const Text(
                    '2. Feed & Water Consumption:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTriageChip(
                        label: 'Normal',
                        selected: scanner.intakeDrop == 'Normal',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Normal',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: 'Reduced consumption',
                        selected: scanner.intakeDrop == 'Reduced consumption',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Reduced consumption',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: 'Severely dropped',
                        selected: scanner.intakeDrop == 'Severely dropped',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Severely dropped',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Q3: Sudden Mortality
                  const Text(
                    '3. Sudden Mortality in Last 24 Hours:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildTriageChip(
                        label: 'None in 24h',
                        selected: scanner.suddenMortality == 'None in 24h',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: 'None in 24h',
                        ),
                      ),
                      _buildTriageChip(
                        label: '1 to 2 birds',
                        selected: scanner.suddenMortality == '1 to 2 birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: '1 to 2 birds',
                        ),
                      ),
                      _buildTriageChip(
                        label: 'Multiple birds died',
                        selected: scanner.suddenMortality == 'Multiple birds died',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: 'Multiple birds died',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Execution Button
            if (scanner.isAnalyzing) ...[
              AppCard(
                color: AppColors.primaryContainerLight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const LinearProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      scanner.analysisStep,
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              CustomButton(
                text: 'Run AI Disease & Severity Diagnosis',
                icon: Icons.analytics_outlined,
                onPressed: scanner.isImageValid
                    ? () async {
                        final res = await scanner.executeDiagnosis();
                        if (res != null && context.mounted) {
                          Navigator.pushNamed(context, AppRoutes.diagnosticResult);
                        }
                      }
                    : null,
              ),
            ],
            const SizedBox(height: AppDimensions.space32),
          ],
        ),
      ),
    );
  }

  static Widget _buildCheckRow({
    required String title,
    required bool passed,
    required void Function(bool) onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 18,
                color: passed ? AppColors.healthy : AppColors.severe,
              ),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 13.5)),
            ],
          ),
          Switch(
            value: passed,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  static Widget _buildTriageChip({
    required String label,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      selected: selected,
      selectedColor: AppColors.primaryContainerLight,
      onSelected: (_) => onSelect(),
    );
  }
}
