import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../controllers/flock_controller.dart';

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

  void _saveFlock() async {
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
        const SnackBar(content: Text('New poultry flock registered successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  const Expanded(
                    child: Text(
                      'Register Farm Flock / Shed',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
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
                label: 'Flock / Shed Name *',
                hint: 'e.g. Shed 3 (Broiler Batch 5)',
                prefixIcon: Icons.home_work_outlined,
                validator: (v) => AppValidators.validateRequired(v, 'Flock Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _countController,
                      label: 'Bird Count (Approx.)',
                      hint: 'e.g. 500',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.format_list_numbered,
                      validator: (v) => AppValidators.validateNumber(v, 'Count'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _breedController,
                      label: 'Poultry Breed',
                      hint: 'e.g. Cobb 500, Desi',
                      prefixIcon: Icons.egg_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _notesController,
                label: 'Notes & Shed Location',
                hint: 'Vaccination history, litter condition...',
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.space20),
              CustomButton(
                text: 'Save Flock',
                isLoading: _isLoading,
                onPressed: _saveFlock,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
