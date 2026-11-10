import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/diagnostic_record.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../scanner/controllers/scanner_controller.dart';
import '../../profile/controllers/settings_controller.dart';
import '../controllers/history_controller.dart';
import '../../../routes/app_routes.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HistoryController>().loadRecords();
      }
    });
  }

  void _confirmDelete(BuildContext context, DiagnosticRecord record, bool isUrdu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUrdu ? 'اسکین ریکارڈ حذف کریں؟' : 'Delete Scan Record?'),
        content: Text(
          isUrdu
              ? 'کیا آپ واقعی اس ریکارڈ کو مقامی ڈیٹا بیس سے حذف کرنا چاہتے ہیں؟'
              : 'Are you sure you want to delete scan ${record.scan.id}? This will remove it permanently from local device storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isUrdu ? 'منسوخ کریں' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.severe,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final historyCtrl = context.read<HistoryController>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await historyCtrl.deleteRecord(record.scan.id);
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isUrdu
                        ? 'ریکارڈ کامیابی سے حذف کر دیا گیا'
                        : 'Scan record deleted from SQLite database.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(isUrdu ? 'حذف کریں' : 'Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, bool isUrdu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUrdu ? 'تمام تاریخ صاف کریں؟' : 'Clear All History?'),
        content: Text(
          isUrdu
              ? 'اس سے آپ کے موبائل کے تمام محفوظ شدہ ٹیسٹ ریکارڈز صاف ہو جائیں گے۔'
              : 'This will delete all saved diagnostic scan sessions from your local SQLite database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isUrdu ? 'منسوخ کریں' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.severe,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final historyCtrl = context.read<HistoryController>();
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);
              await historyCtrl.clearAllHistory();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    isUrdu
                        ? 'تمام اسکین ریکارڈز صاف ہو گئے'
                        : 'All local scan history cleared.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(isUrdu ? 'تمام صاف کریں' : 'Clear All'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetail(BuildContext context, DiagnosticRecord record, bool isUrdu) {
    final pred = record.prediction;
    final scan = record.scan;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        minChildSize: 0.5,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppImageView(
                    imagePath: scan.imagePath,
                    width: 72,
                    height: 72,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge.forDisease(pred.predictedClass ?? 'healthy', isLarge: true),
                        const SizedBox(height: 6),
                        Text(
                          'ID: ${scan.id}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          AppFormatters.formatDateTime(scan.createdAt),
                          style: const TextStyle(fontSize: 12, color: AppColors.textMutedLight),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  StatusBadge.forSeverity(pred.severity, isLarge: true),
                  StatusBadge.forUrgency(pred.urgency, isLarge: true),
                  StatusBadge.forCertainty(pred.certainty, isLarge: true),
                ],
              ),
              const SizedBox(height: 20),

              // View Full Consolidated Diagnosis Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.analytics_outlined),
                  label: Text(
                    isUrdu ? 'مکمل تشخیصی رپورٹ اور آڈیو دیکھیں' : 'View Full Diagnosis & Voice Audio',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    final treat = await context
                        .read<DiseaseRepository>()
                        .getTreatment(pred.predictedClass ?? 'healthy', pred.severity ?? 'mild');
                    if (context.mounted) {
                      context.read<ScannerController>().setLastResult(record, treat);
                      Navigator.pushNamed(
                        context,
                        AppRoutes.diagnosticResult,
                        arguments: record,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                isUrdu ? 'فلاک ٹریج علامات:' : 'Triage Rules & Signals:',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: pred.triageRules.map((r) => Chip(
                  label: Text(r, style: const TextStyle(fontSize: 11)),
                  backgroundColor: AppColors.primaryContainerLight.withValues(alpha: 0.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.severe,
                    side: const BorderSide(color: AppColors.severe),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: Text(isUrdu ? 'یہ ریکارڈ حذف کریں' : 'Delete This Scan Record'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _confirmDelete(context, record, isUrdu);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;
    final records = history.filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isUrdu
              ? 'تشخیصی تاریخ (${records.length})'
              : 'Diagnostic History (${records.length})',
        ),
        actions: [
          IconButton(
            tooltip: isUrdu ? 'تازہ کریں' : 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => history.loadRecords(),
          ),
          if (records.isNotEmpty)
            IconButton(
              tooltip: isUrdu ? 'تمام صاف کریں' : 'Clear All History',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _confirmClearAll(context, isUrdu),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => history.loadRecords(),
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: TextField(
                decoration: InputDecoration(
                  hintText: isUrdu
                      ? 'بیماری کے نام یا آئی ڈی سے تلاش کریں...'
                      : 'Search by scan ID or disease class...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: history.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => history.setSearchQuery(''),
                        )
                      : null,
                ),
                onChanged: history.setSearchQuery,
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: isUrdu ? 'تمام' : 'All Scans',
                    selected: history.selectedDiseaseFilter == 'all',
                    onSelect: () => history.setDiseaseFilter('all'),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: isUrdu ? 'کوکسیڈیوسس' : 'Coccidiosis',
                    selected: history.selectedDiseaseFilter == 'coccidiosis',
                    onSelect: () => history.setDiseaseFilter('coccidiosis'),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: isUrdu ? 'رانی کھیت' : 'Newcastle Disease',
                    selected: history.selectedDiseaseFilter == 'newcastle' ||
                        history.selectedDiseaseFilter == 'ncd',
                    onSelect: () => history.setDiseaseFilter('newcastle'),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: isUrdu ? 'سالمونیلا' : 'Salmonella',
                    selected: history.selectedDiseaseFilter == 'salmonella',
                    onSelect: () => history.setDiseaseFilter('salmonella'),
                  ),
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: isUrdu ? 'صرف صحت مند' : 'Healthy Only',
                    selected: history.selectedDiseaseFilter == 'healthy',
                    onSelect: () => history.setDiseaseFilter('healthy'),
                  ),
                ],
              ),
            ),

            // Records List View
            Expanded(
              child: records.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: EmptyStateView(
                          icon: Icons.history_rounded,
                          title: isUrdu
                              ? 'کوئی اسکین ریکارڈ موجود نہیں ہے'
                              : 'No Diagnostic Scans Found',
                          message: history.searchQuery.isNotEmpty
                              ? (isUrdu
                                  ? 'تلاش کے مطابق کوئی نتیجہ نہیں ملا'
                                  : 'No records match "${history.searchQuery}". Try clearing search query.')
                              : (isUrdu
                                  ? 'کیمرے یا گیلری سے کیے گئے اسکینز یہاں محفوظ ہوں گے'
                                  : 'Scans captured from camera or gallery will be stored locally here.'),
                          actionText: isUrdu ? 'نیا اسکین شروع کریں' : 'Start New Scan',
                          onAction: () {
                            Navigator.pushNamed(context, AppRoutes.scanner);
                          },
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final item = records[index];
                        final pred = item.prediction;
                        final scan = item.scan;
                        final disease = pred.predictedClass ?? 'healthy';

                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          onTap: () => _showRecordDetail(context, item, isUrdu),
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
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatters.formatDate(scan.createdAt),
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: AppColors.textMutedLight,
                                ),
                                tooltip: isUrdu ? 'حذف کریں' : 'Delete scan',
                                onPressed: () => _confirmDelete(context, item, isUrdu),
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
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onSelect,
  }) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.primary : AppColors.textSecondaryLight,
        ),
      ),
      selected: selected,
      selectedColor: AppColors.primaryContainerLight,
      showCheckmark: false,
      onSelected: (_) => onSelect(),
    );
  }
}
