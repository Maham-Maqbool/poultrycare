import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Select Test Sample Specimen',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Authentic poultry fecal dropping photographs for laboratory demonstration:',
                  style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                _buildSampleTile(
                  ctx,
                  title: 'Coccidiosis (Bloody / Mucoid)',
                  subtitle: 'Eimeria tenella intestinal lesion exudate',
                  imagePath: AppAssets.sampleCoccidiosis,
                  disease: 'coccidiosis',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleCoccidiosis, targetDisease: 'coccidiosis');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: 'Newcastle Disease (Green Watery)',
                  subtitle: 'Velogenic paramyxovirus diarrhea',
                  imagePath: AppAssets.sampleNewcastle,
                  disease: 'ncd',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleNewcastle, targetDisease: 'ncd');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: 'Salmonella (Chalky White)',
                  subtitle: 'Pullorum disease chalky paste',
                  imagePath: AppAssets.sampleSalmonella,
                  disease: 'salmonella',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleSalmonella, targetDisease: 'salmonella');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: 'Healthy (Normal Digestion)',
                  subtitle: 'Firm cylindrical feces with urate cap',
                  imagePath: AppAssets.sampleHealthy,
                  disease: 'healthy',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleHealthy, targetDisease: 'healthy');
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
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
      leading: AppImageView(
        imagePath: imagePath,
        width: 52,
        height: 52,
        borderRadius: BorderRadius.circular(8),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11.5),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
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
            tooltip: 'Standard Test Specimens',
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
            // AI Viewfinder Camera Box
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Container(
                          height: 240,
                          width: double.infinity,
                          color: const Color(0xFF0F172A),
                          child: scanner.selectedImagePath != null
                              ? AppImageView(
                                  imagePath: scanner.selectedImagePath!,
                                  width: double.infinity,
                                  height: 240,
                                  fit: BoxFit.cover,
                                )
                              : const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 48,
                                        color: Colors.white54,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Capture or upload chicken dropping photo',
                                        style: TextStyle(color: Colors.white60, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),

                      // Clinical AI Reticle Overlay
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 24,
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Status Header Badge
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.healthy,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                scanner.isLocalFile ? 'Live Camera / File Specimen' : 'Standard Specimen',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '224x224 Tensor Target',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3 Real Upload Action Controls
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Real Camera Capture
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                label: const Text(
                                  'Camera',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                ),
                                onPressed: () async {
                                  final success = await scanner.pickImageFromCamera();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Poultry photograph captured successfully.'
                                              : 'Camera capture cancelled.',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Real Device Gallery Picker
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.photo_library_outlined, size: 18),
                                label: const Text(
                                  'Gallery',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                                ),
                                onPressed: () async {
                                  final success = await scanner.pickImageFromGallery();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Specimen image loaded from gallery.'
                                              : 'Image selection cancelled.',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Standard Samples Bottom Bar
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: const Icon(Icons.science_outlined, size: 16),
                            label: const Text(
                              'Or Choose Test Fecal Sample (4 Authentic Classes)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => _showSamplePicker(context),
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
                      const Expanded(
                        child: Text(
                          'Pre-Inference Quality Checks',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                    title: 'Lighting & Specimen Visibility',
                    passed: scanner.lightingPassed,
                    onToggle: scanner.toggleLighting,
                  ),
                  _buildCheckRow(
                    title: 'Focal Sharpness & Detail',
                    passed: scanner.sharpnessPassed,
                    onToggle: scanner.toggleSharpness,
                  ),
                  _buildCheckRow(
                    title: 'Isolated Dropping in Target',
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
                    'Assign Specimen to Farm Shed',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: scanner.selectedFlockId,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    items: flockController.flocks.map((f) {
                      return DropdownMenuItem<String>(
                        value: f.id,
                        child: Text(
                          '${f.name} (${f.birdCount ?? 0} chickens)',
                          style: const TextStyle(fontSize: 13.5),
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
                      Expanded(
                        child: Text(
                          'Clinical Flock Triage (3 Vital Signals)',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'These vitals synthesize with image classification to derive calibrated clinical severity:',
                    style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                  ),
                  const Divider(height: 24),

                  // Q1: Lethargy
                  const Text(
                    '1. Bird Lethargy & Wing Droop:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
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
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  passed ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                  color: passed ? AppColors.healthy : AppColors.severe,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: passed,
            activeThumbColor: AppColors.primary,
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
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primaryContainerLight,
      onSelected: (_) => onSelect(),
    );
  }
}
