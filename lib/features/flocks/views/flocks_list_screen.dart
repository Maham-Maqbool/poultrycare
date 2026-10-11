import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../controllers/flock_controller.dart';
import 'add_flock_modal.dart';
import 'flock_detail_screen.dart';

class FlocksListScreen extends StatelessWidget {
  const FlocksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final flockController = context.watch<FlockController>();
    final flocks = flockController.flocks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flocks & Sheds'),
        actions: [
          IconButton(
            tooltip: 'Add Shed',
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => AddFlockModal.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Flock'),
        onPressed: () => AddFlockModal.show(context),
      ),
      body: flocks.isEmpty
          ? EmptyStateView(
              icon: Icons.home_work_outlined,
              title: 'No Flocks Added Yet',
              message: 'Organize your poultry sheds to track clinical history separately.',
              actionText: 'Register First Flock',
              onAction: () => AddFlockModal.show(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: flocks.length,
              itemBuilder: (context, index) {
                final flock = flocks[index];
                final hasDisease = flock.activeDiseaseCount > 0;

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FlockDetailScreen(flock: flock),
                      ),
                    );
                  },
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
                              '${flock.birdCount ?? 'Unknown'} birds | ${flock.breed ?? 'Standard Breed'}',
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Added: ${AppFormatters.formatDate(flock.createdAt)}',
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
                              hasDisease ? 'Active Risk' : 'Healthy',
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
