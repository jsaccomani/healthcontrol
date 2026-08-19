import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../tokens/hc_colors.dart';
import '../tokens/hc_spacing.dart';
import '../tokens/hc_typography.dart';
import 'hc_button.dart';

/// Modal / Diálogo simplificado para cadastrar um novo filho na família.
class HCAddChildDialog extends StatefulWidget {
  final ValueChanged<PatientProfile> onChildCreated;

  const HCAddChildDialog({super.key, required this.onChildCreated});

  static Future<PatientProfile?> show({
    required BuildContext context,
    required ValueChanged<PatientProfile> onChildCreated,
  }) {
    return showDialog<PatientProfile>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => HCAddChildDialog(onChildCreated: onChildCreated),
    );
  }

  @override
  State<HCAddChildDialog> createState() => _HCAddChildDialogState();
}

class _HCAddChildDialogState extends State<HCAddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final HealthStorageService _storageService = HealthStorageService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _heightCtrl = TextEditingController(text: '105');
  final TextEditingController _weightCtrl = TextEditingController(text: '18.0');
  final TextEditingController _pefCtrl = TextEditingController(text: '200');
  final TextEditingController _susCtrl = TextEditingController();
  final TextEditingController _insuranceCtrl = TextEditingController();

  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 4));
  String _gender = 'Masculino';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _pefCtrl.dispose();
    _susCtrl.dispose();
    _insuranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final name = _nameCtrl.text.trim();
      final height = double.tryParse(_heightCtrl.text.trim()) ?? 105.0;
      final weight = double.tryParse(_weightCtrl.text.trim()) ?? 18.0;
      final pef = int.tryParse(_pefCtrl.text.trim()) ?? 200;

      final newProfile = await _storageService.createNewChildProfile(
        name: name,
        birthDate: _birthDate,
        gender: _gender,
        heightCm: height,
        weightKg: weight,
        personalBestPef: pef,
        susCardNumber: _susCtrl.text.trim(),
        healthInsurance: _insuranceCtrl.text.trim(),
        avatarId: _gender == 'Feminino' ? 'girl_1' : 'boy_1',
      );

      widget.onChildCreated(newProfile);
      if (mounted) {
        Navigator.pop(context, newProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar filho: $e'), backgroundColor: HCColors.redMain),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: HCRadii.radiusLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add, color: AppTheme.primaryTeal, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cadastrar Filho', style: HCTypography.heading),
                          Text(
                            'Adicione mais um filho para monitoramento',
                            style: HCTypography.bodySmall.copyWith(color: HCColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: HCColors.neutral400),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: HCColors.neutral200),
                const SizedBox(height: 12),

                // Nome Completo
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo da Criança *',
                    hintText: 'Ex: Sofia Saccomani',
                    prefixIcon: Icon(Icons.badge_outlined, size: 20),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome da criança' : null,
                ),
                const SizedBox(height: 12),

                // Sexo e Data de Nascimento
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(
                          labelText: 'Sexo',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                          DropdownMenuItem(value: 'Feminino', child: Text('Feminino')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _gender = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        onTap: _pickBirthDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Nascimento',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            suffixIcon: Icon(Icons.calendar_today, size: 16),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_birthDate),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Altura e Peso
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _heightCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Altura (cm)',
                          suffixText: 'cm',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Peso (kg)',
                          suffixText: 'kg',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Melhor PFE Pessoal
                TextFormField(
                  controller: _pefCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Melhor Sopro Pessoal (PFE Recorde)',
                    hintText: 'Ex: 200',
                    suffixText: 'L/min',
                    helperText: 'Usado para calcular as Zonas Verde/Amarela/Vermelha',
                  ),
                ),
                const SizedBox(height: 12),

                // Cartão SUS / Convênio
                TextFormField(
                  controller: _susCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Cartão Nacional do SUS (opcional)',
                    hintText: '898 0000 0000 0000',
                  ),
                ),
                const SizedBox(height: 20),

                // Botões de Ação
                Row(
                  children: [
                    Expanded(
                      child: HCSecondaryButton(
                        label: 'Cancelar',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: HCPrimaryButton(
                        label: _isSaving ? 'Salvando...' : 'Cadastrar',
                        icon: Icons.check,
                        isLoading: _isSaving,
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
