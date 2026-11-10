import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../routes/app_routes.dart';
import '../controllers/scanner_controller.dart';
import '../../flocks/controllers/flock_controller.dart';
import '../../profile/controllers/settings_controller.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  void _showSamplePicker(BuildContext context, bool isUrdu) {
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
                    Expanded(
                      child: Text(
                        isUrdu ? 'ٹیسٹ نمونہ تصویر منتخب کریں' : 'Select Test Sample Specimen',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isUrdu
                      ? 'مصدقہ معیاری نمونہ تصاویر برائے تجرباتی معائنہ:'
                      : 'Authentic poultry fecal dropping photographs for laboratory demonstration:',
                  style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12.5),
                ),
                const SizedBox(height: 14),
                _buildSampleTile(
                  ctx,
                  title: isUrdu ? 'کوکسیڈیوسس (خونی پیچش)' : 'Coccidiosis (Bloody / Mucoid)',
                  subtitle: isUrdu ? 'انتڑیوں کے زخم اور خونی فضلہ' : 'Eimeria tenella intestinal lesion exudate',
                  imagePath: AppAssets.sampleCoccidiosis,
                  disease: 'coccidiosis',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleCoccidiosis, targetDisease: 'coccidiosis');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: isUrdu ? 'رانی کھیت کی بیماری (سبز پتلا پاخانہ)' : 'Newcastle Disease (Green Watery)',
                  subtitle: isUrdu ? 'سبز پتلا فضلہ اور جھٹکے' : 'Velogenic paramyxovirus diarrhea',
                  imagePath: AppAssets.sampleNewcastle,
                  disease: 'ncd',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleNewcastle, targetDisease: 'ncd');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: isUrdu ? 'سالمونیلا (سفید چونا پیچش)' : 'Salmonella (Chalky White)',
                  subtitle: isUrdu ? 'پلورم بیماری کا سفید فضلہ' : 'Pullorum disease chalky paste',
                  imagePath: AppAssets.sampleSalmonella,
                  disease: 'salmonella',
                  onSelect: () {
                    scanner.selectSampleImage(AppAssets.sampleSalmonella, targetDisease: 'salmonella');
                    Navigator.pop(ctx);
                  },
                ),
                _buildSampleTile(
                  ctx,
                  title: isUrdu ? 'صحت مند مرغی (عام ہاضمہ)' : 'Healthy (Normal Digestion)',
                  subtitle: isUrdu ? 'سخت اور عام ہاضمے کا فضلہ' : 'Firm cylindrical feces with urate cap',
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
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'اے آئی اسکینر اسٹوڈیو' : 'AI Diagnostic Studio'),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            icon: const Icon(Icons.language_rounded, size: 18),
            label: Text(
              isUrdu ? 'English' : 'اردو',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            onPressed: settings.toggleLocale,
          ),
          IconButton(
            tooltip: isUrdu ? 'معیاری نمونہ تصاویر' : 'Standard Test Specimens',
            icon: const Icon(Icons.collections_bookmark_outlined),
            onPressed: () => _showSamplePicker(context, isUrdu),
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
                          height: 220,
                          width: double.infinity,
                          color: const Color(0xFF0F172A),
                          child: scanner.selectedImagePath != null
                              ? AppImageView(
                                  imagePath: scanner.selectedImagePath!,
                                  width: double.infinity,
                                  height: 220,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white.withValues(alpha: 0.15),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 40,
                                            color: AppColors.primaryLight,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          isUrdu
                                              ? 'مرغی کے فضلے کا نمونہ شامل کریں'
                                              : 'Add Fecal Specimen Photo',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          isUrdu
                                              ? 'نیچے دیے گئے بٹن سے کیمرے سے تصویر لیں یا گیلری سے منتخب کریں'
                                              : 'Capture photo with camera or choose from gallery below',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.75),
                                            fontSize: 12.5,
                                            height: 1.35,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // Clinical AI Reticle Overlay (Only shown when image is loaded)
                      if (scanner.selectedImagePath != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.75),
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 28,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 9,
                                height: 9,
                                decoration: const BoxDecoration(
                                  color: AppColors.healthy,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                scanner.selectedImagePath != null
                                    ? (isUrdu ? 'تصویر منتخب شدہ ہے' : 'Specimen Loaded')
                                    : (isUrdu ? 'کیمرہ تیار ہے' : 'Camera Ready'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (scanner.selectedImagePath != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withValues(alpha: 0.7),
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                              onPressed: scanner.clearSelectedImage,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // LARGE FARMER-CENTRIC ACTION BUTTONS
            Row(
              children: [
                // HUGE CAMERA CARD
                Expanded(
                  child: InkWell(
                    borderRadius: AppDimensions.borderRadiusLarge,
                    onTap: () async {
                      final success = await scanner.pickImageFromCamera();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (isUrdu
                                      ? 'کیمرے سے تصویر کامیابی سے لی گئی'
                                      : 'Photograph captured successfully.')
                                  : (isUrdu ? 'کیمرہ بند کر دیا گیا' : 'Camera capture cancelled.'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 94,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppDimensions.borderRadiusLarge,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt_rounded, size: 32, color: Colors.white),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isUrdu ? 'کیمرے سے تصویر لیں' : 'Take Photo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // HUGE GALLERY CARD
                Expanded(
                  child: InkWell(
                    borderRadius: AppDimensions.borderRadiusLarge,
                    onTap: () async {
                      final success = await scanner.pickImageFromGallery();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? (isUrdu
                                      ? 'گیلری سے تصویر لوڈ کر لی گئی'
                                      : 'Specimen image loaded from gallery.')
                                  : (isUrdu ? 'گیلری بند کر دی گئی' : 'Image selection cancelled.'),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 94,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondary.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppDimensions.borderRadiusLarge,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library_rounded, size: 32, color: Colors.white),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isUrdu ? 'گیلری سے منتخب کریں' : 'Pick from Gallery',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Demo Samples Shortcut
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.science_outlined, size: 18),
                label: Text(
                  isUrdu ? 'یا تصدیق شدہ نمونہ تصویر چنیں (4 اقسام) [ڈیمو]' : 'Or Choose Test Fecal Sample (4 Classes) [Demo]',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                onPressed: () => _showSamplePicker(context, isUrdu),
              ),
            ),
            const SizedBox(height: AppDimensions.space12),

            // Pre-Inference Quality Checklist
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isUrdu ? 'تصویر کے معیار کی جانچ' : 'Pre-Inference Quality Checks',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: scanner.selectedImagePath == null
                              ? AppColors.borderLight
                              : (scanner.isImageValid ? AppColors.healthyLight : AppColors.severeLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          scanner.selectedImagePath == null
                              ? (isUrdu ? 'پہلے تصویر لیں' : 'Select Photo First')
                              : (scanner.isImageValid
                                  ? (isUrdu ? 'تشخیص کے لیے تیار' : 'Ready for AI')
                                  : (isUrdu ? '3 معیارات تصدیق کریں' : 'Confirm 3 Checks')),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scanner.selectedImagePath == null
                                ? AppColors.textMutedLight
                                : (scanner.isImageValid ? AppColors.healthy : AppColors.severe),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildCheckRow(
                    title: isUrdu ? 'مناسب روشنی اور واضح تصویر' : 'Lighting & Specimen Visibility',
                    passed: scanner.lightingPassed,
                    onToggle: scanner.toggleLighting,
                  ),
                  _buildCheckRow(
                    title: isUrdu ? 'فوکس اور تفصیلات کی صفائی' : 'Focal Sharpness & Detail',
                    passed: scanner.sharpnessPassed,
                    onToggle: scanner.toggleSharpness,
                  ),
                  _buildCheckRow(
                    title: isUrdu ? 'ایک ہی بیٹ پر واضح فوکس' : 'Isolated Dropping in Target',
                    passed: scanner.singleDroppingPassed,
                    onToggle: scanner.toggleSingleDropping,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Shed Selection
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.home_work_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'متاثرہ پولٹری شیڈ یا فلاک' : 'Target Flock / Shed Assignment',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    initialValue: scanner.selectedFlockId,
                    items: flockController.flocks.map((flock) {
                      return DropdownMenuItem(
                        value: flock.id,
                        child: Text(
                          '${flock.name} (${flock.breed ?? 'Standard'}, ${flock.birdCount ?? 0} birds)',
                          style: const TextStyle(fontSize: 13.0),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: scanner.setFlockId,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // 3-Question Clinical Flock Triage
            AppCard(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUrdu ? 'پرندوں کی جسمانی علامات (3 سوالات)' : 'Clinical Flock Triage (3 Vital Signals)',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUrdu
                        ? 'یہ علامات اے آئی ماڈل کے ساتھ مل کر بیماری کی درست شدت کا تعین کرتی ہیں:'
                        : 'These vitals synthesize with image classification to derive calibrated clinical severity:',
                    style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                  ),
                  const Divider(height: 24),

                  // Q1: Lethargy
                  Text(
                    isUrdu ? '1. پرندوں میں سستی یا پر لٹکانا:' : '1. Bird Lethargy & Wing Droop:',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTriageChip(
                        label: isUrdu ? 'بالکل نہیں' : 'None',
                        selected: scanner.lethargy == 'None',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'None',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? '10 فیصد سے کم' : 'Under 10% of birds',
                        selected: scanner.lethargy == 'Under 10% of birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'Under 10% of birds',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? '10 فیصد سے زیادہ' : 'Over 10% of birds',
                        selected: scanner.lethargy == 'Over 10% of birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: 'Over 10% of birds',
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Q2: Intake Drop
                  Text(
                    isUrdu ? '2. خوراک اور پانی کی کھپت میں کمی:' : '2. Feed & Water Consumption:',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTriageChip(
                        label: isUrdu ? 'معمول کے مطابق' : 'Normal',
                        selected: scanner.intakeDrop == 'Normal',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Normal',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? 'کچھ کمی آئی ہے' : 'Reduced consumption',
                        selected: scanner.intakeDrop == 'Reduced consumption',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Reduced consumption',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? 'شدید کمی آئی ہے' : 'Severely dropped',
                        selected: scanner.intakeDrop == 'Severely dropped',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: 'Severely dropped',
                          suddenMortality: scanner.suddenMortality,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Q3: Sudden Mortality
                  Text(
                    isUrdu ? '3. پچھلے 24 گھنٹوں میں اموات:' : '3. Sudden Mortality in Last 24 Hours:',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildTriageChip(
                        label: isUrdu ? 'کوئی موت نہیں' : 'None in 24h',
                        selected: scanner.suddenMortality == 'None in 24h',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: 'None in 24h',
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? '1 یا 2 پرندے' : '1 to 2 birds',
                        selected: scanner.suddenMortality == '1 to 2 birds',
                        onSelect: () => scanner.setFlockSignals(
                          lethargy: scanner.lethargy,
                          intakeDrop: scanner.intakeDrop,
                          suddenMortality: '1 to 2 birds',
                        ),
                      ),
                      _buildTriageChip(
                        label: isUrdu ? 'کئی پرندے مرے' : 'Multiple birds died',
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

            if (scanner.errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.severe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.severe.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.severe, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scanner.errorMessage!,
                        style: const TextStyle(color: AppColors.severe, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Builder(
                builder: (context) {
                  final bool hasPhoto = scanner.selectedImagePath != null;
                  final bool isValidImage = scanner.isImageValid;
                  final bool isTriageDone = scanner.isTriageComplete;
                  final bool canRunDiagnosis = hasPhoto && isValidImage && isTriageDone;

                  String buttonLabel;
                  if (!hasPhoto) {
                    buttonLabel = isUrdu
                        ? 'تشخیص کے لیے پہلے تصویر لیں یا منتخب کریں'
                        : 'Select or Capture Photo to Run AI Diagnosis';
                  } else if (!isValidImage) {
                    buttonLabel = isUrdu
                        ? 'تصویر کے 3 معیارات کی تصدیق کریں'
                        : 'Confirm 3 Image Quality Checks Above';
                  } else if (!isTriageDone) {
                    buttonLabel = isUrdu
                        ? 'پرندوں کی 3 جسمانی علامات منتخب کریں'
                        : 'Select 3 Flock Triage Answers Above';
                  } else {
                    buttonLabel = isUrdu
                        ? 'اے آئی تشخیص اور شدت معلوم کریں'
                        : 'Run AI Disease & Severity Diagnosis';
                  }

                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canRunDiagnosis
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        elevation: canRunDiagnosis ? 3 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                      ),
                      icon: const Icon(Icons.analytics_outlined, size: 22),
                      label: Text(
                        buttonLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      onPressed: canRunDiagnosis
                          ? () async {
                              final res = await scanner.executeDiagnosis();
                              if (res != null && context.mounted) {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.diagnosticResult,
                                  arguments: res,
                                );
                              }
                            }
                          : null,
                    ),
                  );
                },
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Switch.adaptive(
            value: passed,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainerLight,
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
          fontSize: 12.5,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
          color: selected ? Colors.white : null,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primary,
      onSelected: (_) => onSelect(),
    );
  }
}
