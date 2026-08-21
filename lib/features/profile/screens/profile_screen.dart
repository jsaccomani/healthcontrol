import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/storage/health_storage_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../prescription/screens/prescription_scan_screen.dart';

/// Tela de Perfil Clínico Vivo (Prontuário Pessoal Pediátrico Moderno).
/// Substitui o formulário monolítico por uma visão de resumo escaneável com edições focadas por intenção.
class ProfileScreen extends StatefulWidget {
  final String? patientId;
  const ProfileScreen({super.key, this.patientId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final HealthStorageService _storageService = HealthStorageService();

  List<PatientProfile> _allProfiles = [];
  PatientProfile? _activeProfile;
  List<PrescriptionRecord> _prescriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData(targetId: widget.patientId);
  }

  Future<void> _loadProfileData({String? targetId}) async {
    setState(() => _isLoading = true);
    final profiles = await _storageService.getAllProfiles();
    final currentId = targetId ?? await _storageService.getSelectedProfileId();

    PatientProfile? active;
    List<PrescriptionRecord> presc = [];

    if (profiles.isNotEmpty) {
      active = profiles.firstWhere(
        (p) => p.id == currentId,
        orElse: () => profiles.first,
      );
      presc = await _storageService.getPrescriptions(active.id);
    }

    if (!mounted) return;
    setState(() {
      _allProfiles = profiles;
      _activeProfile = active;
      _prescriptions = presc;
      _isLoading = false;
    });
  }

  Future<void> _saveUpdatedProfile(PatientProfile updated) async {
    await _storageService.savePatientProfile(updated);
    if (!mounted) return;
    setState(() {
      _activeProfile = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ficha clínica atualizada com sucesso!'),
        backgroundColor: HCColors.greenMain,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _switchChild(PatientProfile profile) async {
    await _storageService.setSelectedProfileId(profile.id);
    _loadProfileData(targetId: profile.id);
  }

  void _showAddChildDialog() async {
    final created = await HCAddChildDialog.show(
      context: context,
      onChildCreated: (c) {},
    );
    if (created != null) {
      await _storageService.setSelectedProfileId(created.id);
      _loadProfileData(targetId: created.id);
    }
  }

  // ===========================================================================
  // MODAIS DE EDIÇÃO FOCADA (Progressive Disclosure)
  // ===========================================================================

  // 1. Edição de Identidade & Antropometria
  void _editIdentityModal() {
    final p = _activeProfile!;
    final nameCtrl = TextEditingController(text: p.name);
    final weightCtrl = TextEditingController(text: p.weightKg > 0 ? p.weightKg.toString() : '');
    final heightCtrl = TextEditingController(text: p.heightCm > 0 ? p.heightCm.toString() : '');
    final pefCtrl = TextEditingController(text: p.personalBestPef > 0 ? p.personalBestPef.toString() : '');
    final susCtrl = TextEditingController(text: p.susCardNumber);
    final insuranceCtrl = TextEditingController(text: p.healthInsurance);
    final cardCtrl = TextEditingController(text: p.insuranceCardNumber);
    String bloodType = p.bloodType;

    final theme = context.hcTheme;

    HCBottomSheet.show(
      context: context,
      title: 'Editar Identidade da Criança',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: nameCtrl,
              labelText: 'Nome Completo da Criança',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: HCTextField(
                    controller: weightCtrl,
                    labelText: 'Peso Atual',
                    suffixUnit: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HCTextField(
                    controller: heightCtrl,
                    labelText: 'Altura',
                    suffixUnit: 'cm',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: HCTextField(
                    controller: pefCtrl,
                    labelText: 'Melhor PFE Base',
                    suffixUnit: 'L/min',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatefulBuilder(
                    builder: (ctx, setLocal) => DropdownButtonFormField<String>(
                      initialValue: bloodType,
                      decoration: InputDecoration(
                        labelText: 'Tipo Sanguíneo',
                        filled: true,
                        fillColor: theme.elevatedSurface,
                        border: OutlineInputBorder(borderRadius: HCRadii.radiusMd),
                      ),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'Não informado']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (val) => setLocal(() => bloodType = val ?? 'Não informado'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: susCtrl,
              labelText: 'Cartão Nacional de Saúde (SUS)',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: HCTextField(
                    controller: insuranceCtrl,
                    labelText: 'Convênio / Plano de Saúde',
                    prefixIcon: Icons.health_and_safety_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: HCTextField(
                    controller: cardCtrl,
                    labelText: 'Matrícula / Carteirinha',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Identidade',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final updated = p.copyWith(
                  name: nameCtrl.text.trim(),
                  weightKg: double.tryParse(weightCtrl.text.replaceAll(',', '.')) ?? p.weightKg,
                  heightCm: double.tryParse(heightCtrl.text.replaceAll(',', '.')) ?? p.heightCm,
                  personalBestPef: int.tryParse(pefCtrl.text) ?? p.personalBestPef,
                  bloodType: bloodType,
                  susCardNumber: susCtrl.text.trim(),
                  healthInsurance: insuranceCtrl.text.trim(),
                  insuranceCardNumber: cardCtrl.text.trim(),
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. Edição de Rede de Cuidado (Responsáveis Legais, Cuidadores, Contatos de Emergência)
  void _editCareNetworkModal() {
    final p = _activeProfile!;
    final theme = context.hcTheme;

    HCBottomSheet.show(
      context: context,
      title: 'Gerenciar Rede de Cuidado',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O Health Control permite múltiplos responsáveis legais, cuidadores do dia a dia e contatos de emergência.',
              style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 16),

            // A. Responsáveis Legais
            Text(
              'RESPONSÁVEIS LEGAIS (PODER FAMILIAR / TUTELA)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: theme.primary),
            ),
            const SizedBox(height: 8),
            if (p.legalGuardians.isEmpty)
              Text('Nenhum responsável cadastrado', style: HCTypography.caption.copyWith(color: theme.textTertiary))
            else
              ...p.legalGuardians.map((g) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.elevatedSurface,
                      borderRadius: HCRadii.radiusMd,
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_outlined, color: theme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
                              Text('${g.displayRelationship} • ${g.phone}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.critical, size: 18),
                          onPressed: () {
                            final list = List<LegalGuardian>.from(p.legalGuardians)..remove(g);
                            Navigator.pop(context);
                            _saveUpdatedProfile(p.copyWith(legalGuardians: list));
                          },
                        ),
                      ],
                    ),
                  )),
            OutlinedButton.icon(
              onPressed: () => _showAddGuardianDialog(p),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar Responsável Legal'),
            ),

            const SizedBox(height: 20),

            // B. Cuidadores
            Text(
              'CUIDADORES (FAMILIARES, BABÁS, ESCOLA)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: theme.primary),
            ),
            const SizedBox(height: 8),
            if (p.caregivers.isEmpty)
              Text('Nenhum cuidador cadastrado', style: HCTypography.caption.copyWith(color: theme.textTertiary))
            else
              ...p.caregivers.map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.elevatedSurface,
                      borderRadius: HCRadii.radiusMd,
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.people_outline, color: theme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.fullName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.textPrimary)),
                              Text('${c.displayRelationship} • ${c.accessLevel.displayName}', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.critical, size: 18),
                          onPressed: () {
                            final list = List<Caregiver>.from(p.caregivers)..remove(c);
                            Navigator.pop(context);
                            _saveUpdatedProfile(p.copyWith(caregivers: list));
                          },
                        ),
                      ],
                    ),
                  )),
            OutlinedButton.icon(
              onPressed: () => _showAddCaregiverDialog(p),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Adicionar Cuidador'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGuardianDialog(PatientProfile p) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    LegalGuardianRelationshipType rel = LegalGuardianRelationshipType.mother;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Novo Responsável Legal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome Completo')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp')),
              const SizedBox(height: 8),
              DropdownButtonFormField<LegalGuardianRelationshipType>(
                initialValue: rel,
                decoration: const InputDecoration(labelText: 'Vínculo / Parentesco'),
                items: LegalGuardianRelationshipType.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
                    .toList(),
                onChanged: (val) => setLocal(() => rel = val ?? LegalGuardianRelationshipType.mother),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newG = LegalGuardian(
                  id: 'guardian_${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameCtrl.text.trim(),
                  relationshipType: rel,
                  phone: phoneCtrl.text.trim(),
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
                _saveUpdatedProfile(p.copyWith(legalGuardians: [...p.legalGuardians, newG]));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCaregiverDialog(PatientProfile p) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    CaregiverRelationshipType rel = CaregiverRelationshipType.babysitter;
    CaregiverAccessLevel access = CaregiverAccessLevel.caregiverFull;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Novo Cuidador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome Completo')),
              const SizedBox(height: 8),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefone')),
              const SizedBox(height: 8),
              DropdownButtonFormField<CaregiverRelationshipType>(
                initialValue: rel,
                decoration: const InputDecoration(labelText: 'Relação'),
                items: CaregiverRelationshipType.values
                    .map((r) => DropdownMenuItem(value: r, child: Text(r.displayName)))
                    .toList(),
                onChanged: (val) => setLocal(() => rel = val ?? CaregiverRelationshipType.babysitter),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CaregiverAccessLevel>(
                initialValue: access,
                decoration: const InputDecoration(labelText: 'Permissão'),
                items: CaregiverAccessLevel.values
                    .map((a) => DropdownMenuItem(value: a, child: Text(a.displayName)))
                    .toList(),
                onChanged: (val) => setLocal(() => access = val ?? CaregiverAccessLevel.caregiverFull),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final newC = Caregiver(
                  id: 'caregiver_${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameCtrl.text.trim(),
                  relationshipType: rel,
                  phone: phoneCtrl.text.trim(),
                  accessLevel: access,
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
                _saveUpdatedProfile(p.copyWith(caregivers: [...p.caregivers, newC]));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Edição de Alergias (Medicamentosas, Alimentares, Ambientais)
  void _editAllergiesModal() {
    final p = _activeProfile!;
    final drugCtrl = TextEditingController(text: p.drugAllergies.join(', '));
    final foodCtrl = TextEditingController(text: p.foodAllergies.join(', '));
    final envCtrl = TextEditingController(text: p.environmentalAllergies.join(', '));

    HCBottomSheet.show(
      context: context,
      title: 'Editar Alergias da Criança',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: drugCtrl,
              labelText: 'Alergias a Medicamentos',
              hintText: 'Ex: Amoxicilina (Grave), Dipirona (Moderada)',
              prefixIcon: Icons.medication_outlined,
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: foodCtrl,
              labelText: 'Alergias Alimentares',
              hintText: 'Ex: Leite (APLV), Ovo, Castanhas',
              prefixIcon: Icons.restaurant_outlined,
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: envCtrl,
              labelText: 'Alergias Ambientais & Respiratórias',
              hintText: 'Ex: Ácaros, Poeira doméstica, Mofo, Pelo de gato',
              prefixIcon: Icons.air_outlined,
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Alergias',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final updated = p.copyWith(
                  drugAllergies: drugCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  foodAllergies: foodCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  environmentalAllergies: envCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 4. Edição de Profissionais de Saúde (Múltiplos Médicos, Fisioterapeutas, Especialidades)
  void _editHealthcareProfessionalsModal() {
    final p = _activeProfile!;
    final theme = context.hcTheme;

    HCBottomSheet.show(
      context: context,
      title: 'Profissionais de Saúde & Médicos',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cadastre os médicos assistentes, pneumopediatras e fisioterapeutas que acompanham a criança.',
              style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: 16),
            if (p.healthcareProfessionals.isEmpty)
              Text('Nenhum profissional cadastrado', style: HCTypography.caption.copyWith(color: theme.textTertiary))
            else
              ...p.healthcareProfessionals.map((doc) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.elevatedSurface,
                      borderRadius: HCRadii.radiusMd,
                      border: Border.all(color: theme.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.primarySubtle,
                          child: Icon(Icons.local_hospital_outlined, color: theme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textPrimary)),
                              Text('${doc.displaySpecialty}${doc.licenseNumber != null ? " • ${doc.licenseNumber}" : ""}', style: TextStyle(fontSize: 12, color: theme.textSecondary)),
                              if (doc.clinicOrHospital != null && doc.clinicOrHospital!.isNotEmpty)
                                Text(doc.clinicOrHospital!, style: TextStyle(fontSize: 11, color: theme.textTertiary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: theme.critical, size: 18),
                          onPressed: () {
                            final list = List<HealthcareProfessional>.from(p.healthcareProfessionals)..remove(doc);
                            Navigator.pop(context);
                            _saveUpdatedProfile(p.copyWith(healthcareProfessionals: list));
                          },
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 12),
            HCPrimaryButton(
              label: 'Adicionar Profissional de Saúde',
              icon: Icons.person_add_alt,
              width: double.infinity,
              onPressed: () => _showAddDoctorDialog(p),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDoctorDialog(PatientProfile p) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final crmCtrl = TextEditingController();
    final rqeCtrl = TextEditingController();
    final clinicCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    HealthcareSpecialty specialty = HealthcareSpecialty.pediatricPulmonologist;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Cadastrar Profissional'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nome Completo (ex: Dr. João) *')),
                const SizedBox(height: 8),
                DropdownButtonFormField<HealthcareSpecialty>(
                  initialValue: specialty,
                  decoration: const InputDecoration(labelText: 'Especialidade *'),
                  items: HealthcareSpecialty.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                      .toList(),
                  onChanged: (val) => setLocal(() => specialty = val ?? HealthcareSpecialty.pediatricPulmonologist),
                ),
                const SizedBox(height: 8),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Telefone / WhatsApp *')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: TextField(controller: crmCtrl, decoration: const InputDecoration(labelText: 'CRM / Registro'))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: rqeCtrl, decoration: const InputDecoration(labelText: 'RQE'))),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(controller: clinicCtrl, decoration: const InputDecoration(labelText: 'Clínica / Hospital')),
                const SizedBox(height: 8),
                TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'E-mail de Contato')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final doc = HealthcareProfessional(
                  id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameCtrl.text.trim(),
                  specialty: specialty,
                  primaryPhone: phoneCtrl.text.trim(),
                  licenseNumber: crmCtrl.text.trim().isNotEmpty ? crmCtrl.text.trim() : null,
                  rqeNumber: rqeCtrl.text.trim().isNotEmpty ? rqeCtrl.text.trim() : null,
                  clinicOrHospital: clinicCtrl.text.trim().isNotEmpty ? clinicCtrl.text.trim() : null,
                  email: emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                );
                Navigator.pop(ctx);
                Navigator.pop(context);
                _saveUpdatedProfile(p.copyWith(healthcareProfessionals: [...p.healthcareProfessionals, doc]));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Edição de Condições Especiais & Acessibilidade
  void _editSpecialConditionsModal() {
    final p = _activeProfile!;
    final condCtrl = TextEditingController(text: p.specialConditions.map((c) => c.name).join(', '));
    final limitCtrl = TextEditingController(
        text: p.functionalLimitations.map((l) => l.description.isNotEmpty ? l.description : l.type.displayName).join(', '));

    HCBottomSheet.show(
      context: context,
      title: 'Condições Especiais & Acessibilidade',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: condCtrl,
              labelText: 'Diagnósticos e Condições Especiais',
              hintText: 'Ex: Asma Grave, Rinite, TEA',
              prefixIcon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: limitCtrl,
              labelText: 'Acessibilidade & Interação no Atendimento',
              hintText: 'Ex: Comunicação não-verbal, Hipersensibilidade a ruídos',
              prefixIcon: Icons.accessibility_new_outlined,
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Condições',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final condNames = condCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                final conditions = condNames.map((name) => SpecialCondition(
                      id: 'cond_${name.hashCode}',
                      name: name,
                      category: ConditionCategory.respiratory,
                      isConfirmed: true,
                    )).toList();

                final limitDescs = limitCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                final limitations = limitDescs.map((desc) => FunctionalLimitation(
                      id: 'lim_${desc.hashCode}',
                      type: desc.toLowerCase().contains('não') ? LimitationType.nonVerbal : LimitationType.sensorySensitivity,
                      description: desc,
                    )).toList();

                final updated = p.copyWith(
                  specialConditions: conditions,
                  functionalLimitations: limitations,
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 6. Edição de Histórico & Anamnese Respiratória
  void _editClinicalHistoryModal() {
    final p = _activeProfile!;
    final ageCtrl = TextEditingController(text: p.symptomsStartAge);
    final triggersCtrl = TextEditingController(text: p.crisisTriggers.join(', '));
    final familyCtrl = TextEditingController(text: p.familyAsthmaHistory.join(', '));
    bool hadIcu = p.hadIcuAdmission;
    bool intubated = p.intubatedPast;

    HCBottomSheet.show(
      context: context,
      title: 'Editar Histórico Clínico',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: ageCtrl,
              labelText: 'Idade de Início dos Sintomas',
              hintText: 'Ex: Aos 8 meses de vida',
              prefixIcon: Icons.history_edu_outlined,
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: triggersCtrl,
              labelText: 'Gatilhos Principais de Crise',
              hintText: 'Ex: Gripe, Frio, Poeira, Fumaça, Exercício',
              prefixIcon: Icons.warning_amber_outlined,
            ),
            const SizedBox(height: 12),
            HCTextField(
              controller: familyCtrl,
              labelText: 'Histórico Familiar de Asma / Atopia',
              hintText: 'Ex: Mãe (Rinite/Asma), Pai (Bronquite)',
              prefixIcon: Icons.family_restroom_outlined,
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (ctx, setLocal) => Column(
                children: [
                  SwitchListTile(
                    title: const Text('Já precisou de internação em UTI?'),
                    value: hadIcu,
                    onChanged: (val) => setLocal(() => hadIcu = val),
                  ),
                  SwitchListTile(
                    title: const Text('Já precisou de intubação prévia?'),
                    value: intubated,
                    onChanged: (val) => setLocal(() => intubated = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Histórico',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final updated = p.copyWith(
                  symptomsStartAge: ageCtrl.text.trim(),
                  crisisTriggers: triggersCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  familyAsthmaHistory: familyCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                  hadIcuAdmission: hadIcu,
                  intubatedPast: intubated,
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 7. Edição de Tratamento & Medicamentos Contínuos
  void _editTreatmentModal() {
    final p = _activeProfile!;
    final medsCtrl = TextEditingController(text: p.continuousMedications.join(', '));

    HCBottomSheet.show(
      context: context,
      title: 'Editar Tratamento Contínuo',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: medsCtrl,
              labelText: 'Medicamentos de Uso Diário / Manutenção',
              hintText: 'Ex: Clenil HFA 250mcg (1 jato 12/12h com espaçador), Singulair Baby',
              prefixIcon: Icons.medication_liquid_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrescriptionScanScreen(
                      patientId: p.id,
                      patientName: p.name,
                    ),
                  ),
                ).then((_) => _loadProfileData());
              },
              icon: const Icon(Icons.document_scanner_outlined, size: 18),
              label: const Text('Digitalizar Nova Receita Médica'),
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Tratamento',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final updated = p.copyWith(
                  continuousMedications: medsCtrl.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 8. Edição de Hospital & Emergência
  void _editEmergencyHospitalModal() {
    final p = _activeProfile!;
    final hospCtrl = TextEditingController(text: p.preferredHospital);

    HCBottomSheet.show(
      context: context,
      title: 'Hospital de Referência & Emergência',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HCTextField(
              controller: hospCtrl,
              labelText: 'Pronto-Socorro ou Hospital de Referência',
              hintText: 'Ex: Hospital Infantil Sabará / Samaritano',
              prefixIcon: Icons.local_hospital_outlined,
            ),
            const SizedBox(height: 20),
            HCPrimaryButton(
              label: 'Salvar Hospital',
              icon: Icons.check,
              width: double.infinity,
              onPressed: () {
                final updated = p.copyWith(
                  preferredHospital: hospCtrl.text.trim(),
                );
                Navigator.pop(context);
                _saveUpdatedProfile(updated);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // CONSTRUÇÃO VISUAL DO "PERFIL CLÍNICO VIVO"
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: const Text('Ficha Médica')),
        body: const Center(child: HCLoadingState(message: 'Carregando ficha clínica...')),
      );
    }

    if (_activeProfile == null) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          title: Text(
            'Perfil Clínico do Paciente',
            style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1_outlined, size: 64, color: theme.primary),
                const SizedBox(height: 16),
                Text(
                  'Nenhum perfil cadastrado',
                  style: HCTypography.heading.copyWith(color: theme.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cadastre o perfil da primeira criança para gerenciar o plano de ação e prontuário clínico.',
                  textAlign: TextAlign.center,
                  style: HCTypography.body.copyWith(color: theme.textSecondary),
                ),
                const SizedBox(height: 24),
                HCPrimaryButton(
                  label: 'Cadastrar Criança',
                  icon: Icons.add,
                  onPressed: _showAddChildDialog,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final p = _activeProfile!;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Perfil Clínico do Paciente',
          style: HCTypography.heading.copyWith(fontSize: 16, color: theme.textPrimary),
        ),
        actions: [
          HCChildContextBadge(
            profile: p,
            isCompact: true,
            onSwitchTap: _openChildSelectorSheet,
          ),
          IconButton(
            icon: Icon(Icons.person_add_alt_1, color: theme.textSecondary),
            tooltip: 'Adicionar Outra Criança',
            onPressed: _showAddChildDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: HCResponsiveContainer(
          maxWidth: 720,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER DO PERFIL CLÍNICO VIVO
              _buildClinicalHeader(p, theme),

              const SizedBox(height: 20),

              // 2. SEÇÕES VISUALMENTE INDEPENDENTES (RESUMOS COM CTA DE EDIÇÃO FOCADA)

              // SEÇÃO 1: Identidade & Antropometria
              _buildSectionCard(
                theme: theme,
                title: 'Identidade & Antropometria',
                icon: Icons.person_outline,
                onEdit: _editIdentityModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDataGrid([
                      {'label': 'Data de Nascimento', 'value': DateFormat('dd/MM/yyyy').format(p.birthDate)},
                      {'label': 'Tipo Sanguíneo', 'value': p.bloodType},
                      {'label': 'Peso / Altura', 'value': '${p.weightKg.toString().replaceAll('.', ',')} kg • ${p.heightCm.toString().replaceAll('.', ',')} cm'},
                      {'label': 'Melhor PFE Base', 'value': '${p.personalBestPef} L/min'},
                      {'label': 'Convênio', 'value': p.healthInsurance.isNotEmpty ? p.healthInsurance : 'SUS'},
                      {'label': 'Cartão SUS', 'value': p.susCardNumber.isNotEmpty ? p.susCardNumber : 'Não informado'},
                    ]),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 2: Rede de Cuidado & Responsáveis (Múltiplos)
              _buildSectionCard(
                theme: theme,
                title: 'Rede de Cuidado & Responsáveis',
                icon: Icons.family_restroom_outlined,
                onEdit: _editCareNetworkModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.legalGuardians.isNotEmpty) ...[
                      Text('Responsáveis Legais:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                      const SizedBox(height: 4),
                      ...p.legalGuardians.map((g) => Text('• ${g.fullName} (${g.displayRelationship}) — ${g.phone}', style: HCTypography.bodySmall)),
                      const SizedBox(height: 8),
                    ],
                    if (p.caregivers.isNotEmpty) ...[
                      Text('Cuidadores Autorizados:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.textSecondary)),
                      const SizedBox(height: 4),
                      ...p.caregivers.map((c) => Text('• ${c.fullName} (${c.displayRelationship}) — ${c.accessLevel.displayName.split("(").first.trim()}', style: HCTypography.bodySmall)),
                    ],
                    if (p.legalGuardians.isEmpty && p.caregivers.isEmpty)
                      Text('Toque em gerenciar para cadastrar responsáveis e cuidadores.', style: HCTypography.caption.copyWith(color: theme.textTertiary)),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 3: Histórico Clínico & Anamnese Respiratória
              _buildSectionCard(
                theme: theme,
                title: 'Histórico Clínico & Anamnese',
                icon: Icons.history_edu_outlined,
                onEdit: _editClinicalHistoryModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineField('Início dos Sintomas', p.symptomsStartAge.isNotEmpty ? p.symptomsStartAge : 'Não informado'),
                    _buildInlineField('Gatilhos de Crise', p.crisisTriggers.isNotEmpty ? p.crisisTriggers.join(', ') : 'Não informado'),
                    _buildInlineField('Histórico Familiar', p.familyAsthmaHistory.isNotEmpty ? p.familyAsthmaHistory.join(', ') : 'Não informado'),
                    _buildInlineField('Antecedentes Graves', '${p.hadIcuAdmission ? "Internação em UTI (${p.icuAdmissionsCount}x)" : "Sem internação em UTI"}${p.intubatedPast ? " • Intubação prévia" : ""}'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 4: Alergias (Medicamentosas, Alimentares, Ambientais)
              _buildSectionCard(
                theme: theme,
                title: 'Alergias',
                icon: Icons.medical_services_outlined,
                onEdit: _editAllergiesModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineField('Medicamentos', p.drugAllergies.isNotEmpty ? p.drugAllergies.join(', ') : 'Nenhuma conhecida'),
                    _buildInlineField('Alimentares', p.foodAllergies.isNotEmpty ? p.foodAllergies.join(', ') : 'Nenhuma conhecida'),
                    _buildInlineField('Ambientais', p.environmentalAllergies.isNotEmpty ? p.environmentalAllergies.join(', ') : 'Nenhuma conhecida'),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 5: Condições Especiais & Acessibilidade
              _buildSectionCard(
                theme: theme,
                title: 'Condições Especiais & Acessibilidade',
                icon: Icons.accessibility_new_outlined,
                onEdit: _editSpecialConditionsModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineField('Diagnósticos', p.specialConditions.isNotEmpty ? p.specialConditions.map((c) => c.name).join(', ') : 'Asma Pediátrica'),
                    if (p.functionalLimitations.isNotEmpty)
                      _buildInlineField('Acessibilidade / Interação', p.functionalLimitations.map((l) => l.description.isNotEmpty ? l.description : l.type.displayName).join(', ')),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 6: Tratamento & Uso Contínuo
              _buildSectionCard(
                theme: theme,
                title: 'Tratamento & Uso Contínuo',
                icon: Icons.medication_liquid_outlined,
                onEdit: _editTreatmentModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineField('Medicamentos Diários', p.continuousMedications.isNotEmpty ? p.continuousMedications.join(' • ') : 'Conforme prescrição'),
                    _buildInlineField('Receitas Cadastradas', '${_prescriptions.length} prescrição(ões)'),
                    if (_prescriptions.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ..._prescriptions.map((presc) => Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.elevatedSurface,
                              borderRadius: HCRadii.radiusMd,
                              border: Border.all(color: theme.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      presc.verificationStatus == PrescriptionVerificationStatus.verified
                                          ? Icons.verified
                                          : Icons.description_outlined,
                                      size: 14,
                                      color: presc.verificationStatus == PrescriptionVerificationStatus.verified
                                          ? theme.success
                                          : theme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        '${presc.doctorName.isNotEmpty ? presc.doctorName : "Prescrição Médica"}${presc.doctorCrm.isNotEmpty ? " (${presc.doctorCrm})" : ""}',
                                        style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                HCPrescriptionVerificationBadge(prescription: presc),
                                if (presc.medications.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    presc.medications.map((m) => '${m.commercialName} (${m.dosage})').join(' • '),
                                    style: HCTypography.caption.copyWith(color: theme.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 7: Profissionais de Saúde & Médicos
              _buildSectionCard(
                theme: theme,
                title: 'Profissionais de Saúde',
                icon: Icons.local_hospital_outlined,
                onEdit: _editHealthcareProfessionalsModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (p.healthcareProfessionals.isEmpty)
                      Text('Nenhum médico cadastrado. Toque para adicionar.', style: HCTypography.caption.copyWith(color: theme.textTertiary))
                    else
                      ...p.healthcareProfessionals.map((doc) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.verified, size: 14, color: theme.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${doc.fullName} (${doc.displaySpecialty})${doc.licenseNumber != null ? " • ${doc.licenseNumber}" : ""}',
                                    style: HCTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SEÇÃO 8: Emergência & Hospital de Referência
              _buildSectionCard(
                theme: theme,
                title: 'Hospital de Referência & Emergência',
                icon: Icons.emergency_outlined,
                onEdit: _editEmergencyHospitalModal,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInlineField('Hospital Preferencial', p.preferredHospital.isNotEmpty ? p.preferredHospital : 'Pronto-Socorro Infantil mais próximo'),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicalHeader(PatientProfile p, HCSemanticTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.primarySubtle,
            child: Text(
              p.name.isNotEmpty ? p.name[0].toUpperCase() : 'C',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: theme.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: HCTypography.heading.copyWith(fontSize: 18, color: theme.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  '${p.ageDisplay} • ${p.weightKg.toString().replaceAll('.', ',')} kg • ${p.heightCm.toString().replaceAll('.', ',')} cm',
                  style: HCTypography.bodySmall.copyWith(color: theme.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.successBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.successBorder, width: 0.8),
                      ),
                      child: Text(
                        'Asma Pediátrica • Plano Ativo',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.successText),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required HCSemanticTheme theme,
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: HCRadii.radiusLg,
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: theme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: HCTypography.title.copyWith(fontSize: 14, color: theme.textPrimary),
                  ),
                ],
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: theme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(height: 1, color: theme.borderSubtle),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildDataGrid(List<Map<String, String>> items) {
    final theme = context.hcTheme;
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: items.map((item) {
        return SizedBox(
          width: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['label'] ?? '', style: TextStyle(fontSize: 11, color: theme.textSecondary)),
              const SizedBox(height: 2),
              Text(item['value'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineField(String label, String value) {
    final theme = context.hcTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: theme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.textPrimary)),
          ),
        ],
      ),
    );
  }

  void _openChildSelectorSheet() {
    final theme = context.hcTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Alternar Paciente', style: HCTypography.heading.copyWith(fontSize: 16)),
                const SizedBox(height: 12),
                ..._allProfiles.map((p) => ListTile(
                      leading: CircleAvatar(child: Text(p.name.isNotEmpty ? p.name[0] : 'C')),
                      title: Text(p.name, style: TextStyle(fontWeight: p.id == _activeProfile?.id ? FontWeight.bold : FontWeight.normal)),
                      trailing: p.id == _activeProfile?.id ? Icon(Icons.check, color: theme.primary) : null,
                      onTap: () {
                        Navigator.pop(ctx);
                        _switchChild(p);
                      },
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
