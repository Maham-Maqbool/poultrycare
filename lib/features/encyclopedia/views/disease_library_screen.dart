import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/disease_model.dart';
import '../../../data/repositories/disease_repository.dart';
import '../../profile/controllers/settings_controller.dart';
import 'disease_detail_screen.dart';

class DiseaseLibraryScreen extends StatefulWidget {
  const DiseaseLibraryScreen({super.key});

  @override
  State<DiseaseLibraryScreen> createState() => _DiseaseLibraryScreenState();
}

class _DiseaseLibraryScreenState extends State<DiseaseLibraryScreen> {
  List<DiseaseModel> _diseases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  void _loadDiseases() async {
    final repo = context.read<DiseaseRepository>();
    final list = await repo.getAllDiseases();
    setState(() {
      _diseases = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Scaffold(
      appBar: AppBar(
        title: Text(isUrdu ? 'پولٹری بیماریوں کی گائیڈ' : 'Poultry Disease Library'),
        actions: [
          IconButton(
            tooltip: 'Language Toggle',
            icon: Icon(isUrdu ? Icons.language : Icons.translate),
            onPressed: settings.toggleLocale,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              itemCount: _diseases.length,
              itemBuilder: (context, index) {
                final d = _diseases[index];

                return AppCard(
                  margin: const EdgeInsets.only(bottom: 14.0),
                  padding: const EdgeInsets.all(16.0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiseaseDetailScreen(disease: d),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge.forDisease(d.code),
                          if (d.isNotifiable)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.severeLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Notifiable Disease',
                                style: TextStyle(
                                  color: AppColors.severe,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        d.getName(isUrdu),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        d.getSummary(isUrdu),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondaryLight),
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          Text(
                            '${d.getSigns(isUrdu).length} visible indicators documented',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
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
