import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_image_view.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/mock/mock_scans_data.dart';
import '../controllers/history_controller.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  void _showRecordDetail(BuildContext context, DiagnosticRecord record) {
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
                          'Scan: ${scan.id}',
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
              const Text(
                'Triage Rules That Fired:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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
              if (record.feedback != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Recorded Farmer Feedback:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            record.feedback!.wasHelpful == true
                                ? Icons.thumb_up
                                : Icons.thumb_down,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              record.feedback!.confirmedByVet
                                  ? 'Confirmed by Vet: ${record.feedback!.actualClass ?? 'Same'}'
                                  : 'Farmer Assessment',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      if (record.feedback!.comment != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '"${record.feedback!.comment}"',
                          style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryController>();
    final records = history.filteredRecords;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Scan History'),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by scan ID or disease class...',
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
                  label: 'All Scans',
                  selected: history.selectedDiseaseFilter == 'all',
                  onSelect: () => history.setDiseaseFilter('all'),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Coccidiosis',
                  selected: history.selectedDiseaseFilter == 'coccidiosis',
                  onSelect: () => history.setDiseaseFilter('coccidiosis'),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Newcastle Disease',
                  selected: history.selectedDiseaseFilter == 'ncd',
                  onSelect: () => history.setDiseaseFilter('ncd'),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Salmonella',
                  selected: history.selectedDiseaseFilter == 'salmonella',
                  onSelect: () => history.setDiseaseFilter('salmonella'),
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'Healthy Only',
                  selected: history.selectedDiseaseFilter == 'healthy',
                  onSelect: () => history.setDiseaseFilter('healthy'),
                ),
              ],
            ),
          ),

          // Records List View
          Expanded(
            child: records.isEmpty
                ? const EmptyStateView(
                    icon: Icons.history_rounded,
                    title: 'No Matching Scans Found',
                    message: 'Try clearing the search query or selecting a different filter.',
                  )
                : ListView.builder(
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
                        onTap: () => _showRecordDetail(context, item),
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
                                    '${AppFormatters.formatConfidence(pred.calibratedConfidence)} confidence | ${pred.triageRules.length} rules fired',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    AppFormatters.relativeTime(scan.createdAt),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
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
