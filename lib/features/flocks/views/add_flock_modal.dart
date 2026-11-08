import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/flock_controller.dart';
import '../../profile/controllers/settings_controller.dart';

class AddFlockModal extends StatefulWidget {
  const AddFlockModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddFlockModal(),
    );
  }

  @override
  State<AddFlockModal> createState() => _AddFlockModalState();
}

class _AddFlockModalState extends State<AddFlockModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _countController = TextEditingController();
  final _breedController = TextEditingController(text: 'Cobb 500 Broiler');
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _countController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveFlock(bool isUrdu) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final count = int.tryParse(_countController.text.trim());
    final flockController = context.read<FlockController>();
    final success = await flockController.addFlock(
      name: _nameController.text.trim(),
      birdCount: count,
      breed: _breedController.text.trim(),
      notes: _notesController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUrdu
                ? 'نیا پولٹری شیڈ کامیابی سے رجسٹر ہو گیا'
                : 'New poultry flock registered successfully!',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final isUrdu = settings.isUrdu;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
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
                      isUrdu ? 'نیا پولٹری شیڈ رجسٹر کریں' : 'Register Farm Flock / Shed',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _nameController,
                label: isUrdu ? 'شیڈ کا نام *' : 'Flock / Shed Name *',
                hint: isUrdu ? 'مثلاً شیڈ نمبر 3 (برائلر)' : 'e.g. Shed 3 (Broiler Batch 5)',
                prefixIcon: Icons.home_work_outlined,
                validator: (v) => AppValidators.validateRequired(v, 'Flock Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _countController,
                      label: isUrdu ? 'پرندوں کی تعداد' : 'Bird Count (Approx.)',
                      hint: '500',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.format_list_numbered,
                      validator: (v) => AppValidators.validateNumber(v, 'Count'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _breedController,
                      label: isUrdu ? 'پرندوں کی نسل' : 'Poultry Breed',
                      hint: 'Cobb 500, Desi',
                      prefixIcon: Icons.egg_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: isUrdu ? 'شیڈ کے بارے میں نوٹس' : 'Notes & Shed Location',
                hint: isUrdu ? 'ویکسینیشن یا برادے کی حالت...' : 'Vaccination history, litter condition...',
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.space20),
              CustomButton(
                text: isUrdu ? 'شیڈ محفوظ کریں' : 'Save Flock',
                isLoading: _isLoading,
                onPressed: () => _saveFlock(isUrdu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
