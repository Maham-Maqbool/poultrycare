import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/flock_status_helper.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../data/models/flock_model.dart';
import '../controllers/flock_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../profile/controllers/settings_controller.dart';
import 'add_flock_modal.dart';
import 'flock_detail_screen.dart';

class FlocksListScreen extends StatefulWidget {
  const FlocksListScreen({super.key});

  @override
  State<FlocksListScreen> createState() => _FlocksListScreenState();
}

class _FlocksListScreenState extends State<FlocksListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FlockController>().loadFlocks();
        context.read<HistoryController>().loadRecords();
      }
    });
  }

  Future<void> _handleAddFlock() async {
    await AddFlockModal.show(context);
    if (!mounted) return;
    context.read<FlockController>().loadFlocks();
  }

  Future<void> _handleOpenFlockDetail(FlockModel flock) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlockDetailScreen(flock: flock),
      ),
    );
    if (!mounted) return;
    context.read<FlockController>().loadFlocks();
    context.read<HistoryController>().loadRecords();
  }

  @override
  Widget build(BuildContext context) {
    final flockController = context.watch<FlockController>();
    final history = context.watch<HistoryController>();
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;
    final flocks = flockController.flocks;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'میرے پولٹری شیڈز' : 'My Flocks & Sheds'),
        actions: [
          IconButton(
            tooltip: isUrdu ? 'شیڈ شامل کریں' : 'Add Shed',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: _handleAddFlock,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(isUrdu ? 'نیا شیڈ' : 'New Flock'),
        onPressed: _handleAddFlock,
      ),
      body: flocks.isEmpty
          ? EmptyStateView(
              icon: Icons.home_work_outlined,
              title: isUrdu ? 'ابھی تک کوئی شیڈ شامل نہیں ہوا' : 'No Flocks Added Yet',
              message: isUrdu
                  ? 'اپنے فارم کے شیڈز کو الگ الگ ٹریک کرنے کے لیے نیا شیڈ رجسٹر کریں'
                  : 'Organize your poultry sheds to track clinical history separately.',
              actionText: isUrdu ? 'پہلا شیڈ رجسٹر کریں' : 'Register First Flock',
              onAction: _handleAddFlock,
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: flocks.length,
              itemBuilder: (itemCtx, index) {
                final flock = flocks[index];
                final hasDisease = FlockStatusHelper.isAtRisk(
                  flock: flock,
                  records: history.allRecords,
                );

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  onTap: () => _handleOpenFlockDetail(flock),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: hasDisease ? AppColors.severeLight : AppColors.primaryContainerLight,
                          borderRadius: AppDimensions.borderRadiusMedium,
                        ),
                        child: Icon(
                          Icons.home_work_rounded,
                          color: hasDisease ? AppColors.severe : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flock.name,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${flock.birdCount != null ? '${flock.birdCount} ${isUrdu ? "پرندے" : "birds"}' : (isUrdu ? "غیر متعین تعداد" : "Unspecified")} | ${flock.breed ?? (isUrdu ? 'معیاری نسل' : 'Standard Breed')}',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${isUrdu ? 'اندراج' : 'Added'}: ${AppFormatters.formatDate(flock.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: hasDisease ? AppColors.severeLight : AppColors.healthyLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              hasDisease
                                  ? (isUrdu ? 'بیماری کا خطرہ' : 'Active Risk')
                                  : (isUrdu ? 'صحت مند' : 'Healthy'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: hasDisease ? AppColors.severe : AppColors.healthy,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMutedLight),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
