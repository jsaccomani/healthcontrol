import 'package:flutter/material.dart';
import 'package:clinical_core/clinical_core.dart';
import '../../../core/design_system/design_system.dart';

/// Resumo Clínico Estruturado para Atendimento de Emergência (Nível 2 — Expansível).
/// Inclui Alergias, Condições Especiais, Limitações Funcionais, Médicos e Contatos.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.profile;
    final doc = p.primaryDoctor;
    final docPhone = doc?.primaryPhone ?? p.doctorPhone;
    final emergency = p.primaryEmergencyContact;
    final emPhone = emergency?.phone ?? p.emergencyContactPhone;

    return Material(
      color: isDark ? HCColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: HCRadii.radiusLg,
        side: BorderSide(
          color: isDark ? HCColors.darkBorder : HCColors.neutral200,
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
            color: isDark ? Colors.white10 : HCColors.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medical_information_outlined,
            color: isDark ? HCColors.primary300 : HCColors.neutral800,
            size: 20,
          ),
        ),
        title: Text(
          'Resumo Clínico para o Plantonista',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? HCColors.darkText : HCColors.neutral900,
          ),
        ),
        subtitle: Text(
          _isExpanded
              ? 'Toque para recolher'
              : 'Alergias, UTI, Limitações e Contatos Médicos',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 16),

                // 1. Alergias Medicamentosas
                _buildSummaryRow(
                  label: 'Alergias:',
                  value: p.drugAllergies.isNotEmpty ? p.drugAllergies.join(', ') : 'Nenhuma relatada',
                  isDark: isDark,
                  isWarning: p.drugAllergies.isNotEmpty,
                ),

                // 2. Condições Especiais Estruturadas
                if (p.specialConditions.isNotEmpty) ...[
                  _buildSummaryRow(
                    label: 'Condições Especiais:',
                    value: p.specialConditions.map((c) => c.name).join(', '),
                    isDark: isDark,
                  ),
                ],

                // 3. Limitações Funcionais / Comunicação
                if (p.functionalLimitations.isNotEmpty) ...[
                  _buildSummaryRow(
                    label: 'Acessibilidade / Comunicação:',
                    value: p.functionalLimitations
                        .map((l) => l.description.isNotEmpty ? l.description : l.type.displayName)
                        .join(', '),
                    isDark: isDark,
                    isWarning: true,
                  ),
                ],

                // 4. Antecedentes Graves (UTI / Intubação)
                _buildSummaryRow(
                  label: 'Histórico de UTI:',
                  value: p.hadIcuAdmission ? 'SIM (${p.icuAdmissionsCount}x)' : 'Não',
                  isDark: isDark,
                  isWarning: p.hadIcuAdmission,
                ),
                _buildSummaryRow(
                  label: 'Intubação Prévia:',
                  value: p.intubatedPast ? 'SIM (Alto Risco)' : 'Não',
                  isDark: isDark,
                  isWarning: p.intubatedPast,
                ),

                // 5. Dados de Identificação Hospitalar
                _buildSummaryRow(
                  label: 'Tipo Sanguíneo:',
                  value: p.bloodType,
                  isDark: isDark,
                ),
                _buildSummaryRow(
                  label: 'Convênio / Cartão SUS:',
                  value: '${p.healthInsurance} ${p.susCardNumber.isNotEmpty ? "• SUS: ${p.susCardNumber}" : ""}',
                  isDark: isDark,
                ),
                _buildSummaryRow(
                  label: 'Hospital Preferencial:',
                  value: p.preferredHospital,
                  isDark: isDark,
                ),

                const SizedBox(height: 8),
                const Divider(height: 16),

                // 6. Contatos Diretos
                Text(
                  'CONTATOS DE URGÊNCIA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: isDark ? HCColors.darkTextMuted : HCColors.neutral700,
                  ),
                ),
                const SizedBox(height: 6),

                if (docPhone.isNotEmpty) ...[
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: HCColors.primary50,
                      radius: 16,
                      child: Icon(Icons.local_hospital, color: HCColors.primary600, size: 16),
                    ),
                    title: Text(
                      doc?.fullName ?? p.doctorName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : HCColors.neutral900,
                      ),
                    ),
                    subtitle: Text(
                      '${doc?.displaySpecialty ?? "Médico Assistente"} • $docPhone',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: HCColors.primary500),
                      onPressed: () => widget.onCallPhone(docPhone),
                    ),
                  ),
                ],

                if (emPhone.isNotEmpty) ...[
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFEF2F2),
                      radius: 16,
                      child: Icon(Icons.contact_phone, color: HCColors.redMain, size: 16),
                    ),
                    title: Text(
                      emergency?.fullName ?? p.emergencyContactName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : HCColors.neutral900,
                      ),
                    ),
                    subtitle: Text(
                      '${emergency?.relationship ?? "Responsável"} • $emPhone',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? HCColors.darkTextMuted : HCColors.neutral600,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.phone, color: HCColors.redMain),
                      onPressed: () => widget.onCallPhone(emPhone),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required bool isDark,
    bool isWarning = false,
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
                fontWeight: isWarning ? FontWeight.bold : FontWeight.w500,
                color: isWarning
                    ? HCColors.redMain
                    : (isDark ? HCColors.darkTextMuted : HCColors.neutral600),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.w600,
                color: isWarning
                    ? HCColors.redMain
                    : (isDark ? Colors.white : HCColors.neutral900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
