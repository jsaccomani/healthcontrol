import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Resumo Clínico Estruturado para Atendimento de Emergência (Accordion).
/// Título: "Informações importantes para atendimento"
///
/// Apresenta:
/// - Alergias Medicamentosas
/// - Condições Especiais / Diagnósticos
/// - Medicamentos Contínuos
/// - Médico Assistente
/// - Responsável / Contato de Urgência
/// - Hospital de Referência e SUS/Convênio
class CrisisClinicalSummary extends StatefulWidget {
  final PatientProfile profile;
  final void Function(String phone) onCallPhone;

  const CrisisClinicalSummary({
    super.key,
    required this.profile,
    required this.onCallPhone,
  });

  @override
  State<CrisisClinicalSummary> createState() => _CrisisClinicalSummaryState();
}

class _CrisisClinicalSummaryState extends State<CrisisClinicalSummary> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.hcTheme;
    final p = widget.profile;
    final doc = p.primaryDoctor;
    final docPhone = doc?.primaryPhone ?? p.doctorPhone;
    final emergency = p.primaryEmergencyContact;
    final emPhone = emergency?.phone ?? p.emergencyContactPhone;

    // Identifica condições que afetam a interação (comunicação, sensorial, TEA, etc.)
    final interactionConditions = p.functionalLimitations.where((l) =>
        l.type == LimitationType.nonVerbal ||
        l.type == LimitationType.sensorySensitivity ||
        l.type == LimitationType.cognitiveDifficulty ||
        l.type == LimitationType.communicationDifficulty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destaque Contextual para Condições Especiais de Interação (Não Alarmista)
        if (interactionConditions.isNotEmpty) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.infoBg,
              borderRadius: HCRadii.radiusMd,
              border: Border.all(color: theme.infoBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informação importante para atendimento',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        interactionConditions
                            .map((c) => c.description.isNotEmpty ? '${c.type.displayName}: ${c.description}' : c.type.displayName)
                            .join(' • '),
                        style: HCTypography.caption.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Accordion: Informações importantes para atendimento
        Material(
          color: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: HCRadii.radiusLg,
            side: BorderSide(
              color: theme.border,
            ),
          ),
          child: ExpansionTile(
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (exp) => setState(() => _isExpanded = exp),
            shape: const Border(),
            collapsedShape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.medical_information_outlined,
                color: theme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'Informações importantes para atendimento',
              style: HCTypography.title.copyWith(
                fontSize: 14,
                color: theme.textPrimary,
              ),
            ),
            subtitle: Text(
              _isExpanded
                  ? 'Toque para recolher'
                  : 'Alergias, medicações de uso contínuo e contatos',
              style: HCTypography.caption.copyWith(
                color: theme.textSecondary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(height: 16, color: theme.border),

                    // 1. Alergias Medicamentosas
                    _buildSummaryRow(
                      theme: theme,
                      label: 'Alergias:',
                      value: p.drugAllergies.isNotEmpty ? p.drugAllergies.join(', ') : 'Nenhuma relatada',
                      isCritical: p.drugAllergies.isNotEmpty,
                    ),

                    // 2. Condições Especiais & Diagnósticos
                    if (p.specialConditions.isNotEmpty) ...[
                      _buildSummaryRow(
                        theme: theme,
                        label: 'Condições / Diagnósticos:',
                        value: p.specialConditions.map((c) => c.name).join(', '),
                      ),
                    ],

                    // 3. Medicamentos de Uso Contínuo
                    _buildSummaryRow(
                      theme: theme,
                      label: 'Uso Contínuo:',
                      value: p.continuousMedications.isNotEmpty
                          ? p.continuousMedications.join(', ')
                          : 'Conforme receituário',
                    ),

                    // 4. Antecedentes Graves (UTI / Intubação)
                    if (p.hadIcuAdmission || p.intubatedPast) ...[
                      _buildSummaryRow(
                        theme: theme,
                        label: 'Histórico Grave:',
                        value: '${p.hadIcuAdmission ? "Internação em UTI (${p.icuAdmissionsCount}x)" : ""}${p.intubatedPast ? " • Intubação Prévia" : ""}',
                        isCritical: true,
                      ),
                    ],

                    // 5. Hospital Preferencial / SUS / Convênio
                    _buildSummaryRow(
                      theme: theme,
                      label: 'Hospital de Referência:',
                      value: p.preferredHospital.isNotEmpty ? p.preferredHospital : 'Pronto-Socorro Infantil mais próximo',
                    ),
                    if (p.healthInsurance.isNotEmpty || p.susCardNumber.isNotEmpty) ...[
                      _buildSummaryRow(
                        theme: theme,
                        label: 'Convênio / SUS:',
                        value: '${p.healthInsurance} ${p.susCardNumber.isNotEmpty ? "• CNS: ${p.susCardNumber}" : ""}',
                      ),
                    ],

                    const SizedBox(height: 8),
                    Divider(height: 16, color: theme.border),

                    // 6. Médico Assistente & Responsável
                    Text(
                      'CONTATOS MÉDICO E FAMILIAR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: theme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (docPhone.isNotEmpty) ...[
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.primarySubtle,
                          radius: 16,
                          child: Icon(Icons.local_hospital, color: theme.primary, size: 16),
                        ),
                        title: Text(
                          doc?.fullName ?? p.doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${doc?.displaySpecialty ?? "Médico Assistente"} • $docPhone',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.phone, color: theme.primary),
                          onPressed: () => widget.onCallPhone(docPhone),
                        ),
                      ),
                    ],

                    if (emPhone.isNotEmpty) ...[
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: theme.criticalBg,
                          radius: 16,
                          child: Icon(Icons.contact_phone, color: theme.critical, size: 16),
                        ),
                        title: Text(
                          emergency?.fullName ?? p.emergencyContactName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: theme.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${emergency?.relationship ?? "Responsável"} • $emPhone',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.phone, color: theme.critical),
                          onPressed: () => widget.onCallPhone(emPhone),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required HCSemanticTheme theme,
    required String label,
    required String value,
    bool isCritical = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCritical ? FontWeight.bold : FontWeight.w500,
                color: isCritical ? theme.criticalText : theme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isCritical ? FontWeight.bold : FontWeight.w600,
                color: isCritical ? theme.criticalText : theme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
