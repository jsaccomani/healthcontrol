/// Categoria da Medicação Pediátrica para Asma
enum MedicationCategory {
  maintenanceInhaled, // Bombinhas de Manutenção / Profilaxia (Corticoides Inalatórios e Combinações LABA)
  rescueInhaled, // Bombinhas de Resgate / Alívio Rápido (SABA - Salbutamol/Fenoterol)
  antileukotrieneOral, // Antileucotrienos Orais (Montelucaste)
  oralSteroidRescue, // Corticoide Oral para Crise (Prednisolona/Prelone)
  biologicHighCost, // Imunobiológicos de Alto Custo (Dupixent, Xolair, Nucala)
  inhalationSolution, // Soluções para Nebulização (Berotec, Atrovent, Soro)
  other,
}

/// Extensão com nomes amigáveis em Português
extension MedicationCategoryExt on MedicationCategory {
  String get displayName {
    switch (this) {
      case MedicationCategory.maintenanceInhaled:
        return 'Controle / Manutenção Inalatória';
      case MedicationCategory.rescueInhaled:
        return 'Resgate / Alívio Rápido (Bombinha)';
      case MedicationCategory.antileukotrieneOral:
        return 'Antileucotrieno Oral (Controle)';
      case MedicationCategory.oralSteroidRescue:
        return 'Corticoide Oral (Crise Aguda)';
      case MedicationCategory.biologicHighCost:
        return 'Imunobiológico (Alto Custo SUS)';
      case MedicationCategory.inhalationSolution:
        return 'Solução para Nebulização';
      case MedicationCategory.other:
        return 'Outro';
    }
  }

  String get iconEmoji {
    switch (this) {
      case MedicationCategory.maintenanceInhaled:
        return '🫁';
      case MedicationCategory.rescueInhaled:
        return '⚡';
      case MedicationCategory.antileukotrieneOral:
        return '💊';
      case MedicationCategory.oralSteroidRescue:
        return '🚨';
      case MedicationCategory.biologicHighCost:
        return '🧬';
      case MedicationCategory.inhalationSolution:
        return '💨';
      case MedicationCategory.other:
        return '🩺';
    }
  }
}

/// Item de Medicação Prescrita na Receita
class PrescribedMedication {
  final String id;
  final String commercialName; // ex: Clenil HFA 250mcg, Aerolin 100mcg, Singulair 4mg
  final String activeIngredient; // ex: Dipropionato de Beclometasona
  final MedicationCategory category;
  final String dosage; // ex: 1 jato (puff), 5mL, 1 sachê
  final String frequency; // ex: 12/12 horas (8h e 20h)
  final String instructions; // ex: Com espaçador e máscara, lavar a boca após uso
  final bool spacerRequired; // Necessita de espaçador valvulado?
  final bool isContinuous; // É de uso contínuo diário?

  const PrescribedMedication({
    required this.id,
    required this.commercialName,
    required this.activeIngredient,
    required this.category,
    required this.dosage,
    required this.frequency,
    this.instructions = 'Usar com espaçador valvulado e máscara facial.',
    this.spacerRequired = true,
    this.isContinuous = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commercial_name': commercialName,
      'active_ingredient': activeIngredient,
      'category': category.name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'spacer_required': spacerRequired,
      'is_continuous': isContinuous,
    };
  }

  factory PrescribedMedication.fromJson(Map<String, dynamic> json) {
    return PrescribedMedication(
      id: json['id'] as String,
      commercialName: json['commercial_name'] as String,
      activeIngredient: json['active_ingredient'] as String? ?? '',
      category: MedicationCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => MedicationCategory.maintenanceInhaled,
      ),
      dosage: json['dosage'] as String? ?? '1 jato',
      frequency: json['frequency'] as String? ?? '12/12h',
      instructions: json['instructions'] as String? ?? '',
      spacerRequired: json['spacer_required'] as bool? ?? true,
      isContinuous: json['is_continuous'] as bool? ?? true,
    );
  }
}

/// Status do ciclo de vida da verificação de autenticidade da receita médica.
enum PrescriptionVerificationStatus {
  unknown, // default — cadastrado pelo cuidador, nunca verificado
  pending, // enviado para verificação, aguardando resposta
  verified, // confirmado por autoridade real (CFM, sistema do Health Control Pro, etc.)
  invalid, // autoridade confirmou que NÃO é uma receita válida
  expired, // a VERIFICAÇÃO em si expirou (não confundir com isExpired, que já existe e é sobre a validade de uso da receita por data — são conceitos independentes)
  revoked, // médico ou autoridade revogou depois de verificada
}

/// Extensão com nomes amigáveis para status de verificação
extension PrescriptionVerificationStatusExt on PrescriptionVerificationStatus {
  String get displayName {
    switch (this) {
      case PrescriptionVerificationStatus.unknown:
        return 'Autenticidade não verificada';
      case PrescriptionVerificationStatus.pending:
        return 'Verificação pendente';
      case PrescriptionVerificationStatus.verified:
        return 'Verificada por autoridade';
      case PrescriptionVerificationStatus.invalid:
        return 'Receita inválida';
      case PrescriptionVerificationStatus.expired:
        return 'Verificação expirada';
      case PrescriptionVerificationStatus.revoked:
        return 'Receita revogada';
    }
  }
}

/// Registro Completo de Receita Médica Escaneada / Digitalizada
class PrescriptionRecord {
  final String id;
  final String patientId;
  final String doctorName;
  final String doctorCrm;
  final String clinicName;
  final DateTime prescriptionDate;
  final int validityMonths; // Validade da prescrição (padrão: 6 meses para contínuos / 30 dias para antibióticos)
  final String? scannedImageUrl;
  final List<PrescribedMedication> medications;
  final String notes;
  final bool isLmeAltoCusto; // Laudo de Medicamento Especializado (SUS)

  // Ciclo de vida e verificação de autenticidade (HC-009)
  final PrescriptionVerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final String verificationProvider;
  final String verificationReference;
  final String? documentHash;

  const PrescriptionRecord({
    required this.id,
    required this.patientId,
    required this.doctorName,
    this.doctorCrm = '',
    this.clinicName = '',
    required this.prescriptionDate,
    this.validityMonths = 6,
    this.scannedImageUrl,
    required this.medications,
    this.notes = '',
    this.isLmeAltoCusto = false,
    this.verificationStatus = PrescriptionVerificationStatus.unknown,
    this.verifiedAt,
    this.verificationProvider = '',
    this.verificationReference = '',
    this.documentHash,
  });

  /// Data calculada de vencimento da receita
  DateTime get expirationDate {
    return DateTime(
      prescriptionDate.year,
      prescriptionDate.month + validityMonths,
      prescriptionDate.day,
    );
  }

  /// Indica se a receita já está vencida
  bool get isExpired => DateTime.now().isAfter(expirationDate);

  /// Quantidade de dias restantes até o vencimento
  int get daysUntilExpiration {
    return expirationDate.difference(DateTime.now()).inDays;
  }

  /// Nível de alerta da validade da receita
  String get validityStatusText {
    if (isExpired) {
      final daysPast = DateTime.now().difference(expirationDate).inDays;
      return 'Vencida há $daysPast dias (Renovar com o Pediatra)';
    }
    if (daysUntilExpiration <= 15) {
      return 'Vence em $daysUntilExpiration dias (Alerta de Renovação)';
    }
    return 'Válida por mais $daysUntilExpiration dias';
  }

  PrescriptionRecord copyWith({
    String? id,
    String? patientId,
    String? doctorName,
    String? doctorCrm,
    String? clinicName,
    DateTime? prescriptionDate,
    int? validityMonths,
    String? scannedImageUrl,
    List<PrescribedMedication>? medications,
    String? notes,
    bool? isLmeAltoCusto,
    PrescriptionVerificationStatus? verificationStatus,
    DateTime? verifiedAt,
    String? verificationProvider,
    String? verificationReference,
    String? documentHash,
  }) {
    return PrescriptionRecord(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorName: doctorName ?? this.doctorName,
      doctorCrm: doctorCrm ?? this.doctorCrm,
      clinicName: clinicName ?? this.clinicName,
      prescriptionDate: prescriptionDate ?? this.prescriptionDate,
      validityMonths: validityMonths ?? this.validityMonths,
      scannedImageUrl: scannedImageUrl ?? this.scannedImageUrl,
      medications: medications ?? this.medications,
      notes: notes ?? this.notes,
      isLmeAltoCusto: isLmeAltoCusto ?? this.isLmeAltoCusto,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verificationProvider: verificationProvider ?? this.verificationProvider,
      verificationReference: verificationReference ?? this.verificationReference,
      documentHash: documentHash ?? this.documentHash,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'doctor_name': doctorName,
      'doctor_crm': doctorCrm,
      'clinic_name': clinicName,
      'prescription_date': prescriptionDate.toIso8601String(),
      'validity_months': validityMonths,
      'scanned_image_url': scannedImageUrl,
      'medications': medications.map((m) => m.toJson()).toList(),
      'notes': notes,
      'is_lme_alto_custo': isLmeAltoCusto,
      'verification_status': verificationStatus.name,
      'verified_at': verifiedAt?.toIso8601String(),
      'verification_provider': verificationProvider,
      'verification_reference': verificationReference,
      'document_hash': documentHash,
    };
  }

  factory PrescriptionRecord.fromJson(Map<String, dynamic> json) {
    return PrescriptionRecord(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      doctorName: json['doctor_name'] as String? ?? '',
      doctorCrm: json['doctor_crm'] as String? ?? '',
      clinicName: json['clinic_name'] as String? ?? '',
      prescriptionDate: DateTime.parse(json['prescription_date'] as String),
      validityMonths: json['validity_months'] as int? ?? 6,
      scannedImageUrl: json['scanned_image_url'] as String?,
      medications: (json['medications'] as List<dynamic>?)
              ?.map((m) => PrescribedMedication.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String? ?? '',
      isLmeAltoCusto: json['is_lme_alto_custo'] as bool? ?? false,
      verificationStatus: PrescriptionVerificationStatus.values.firstWhere(
        (s) => s.name == json['verification_status'],
        orElse: () => PrescriptionVerificationStatus.unknown,
      ),
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      verificationProvider: json['verification_provider'] as String? ?? '',
      verificationReference: json['verification_reference'] as String? ?? '',
      documentHash: json['document_hash'] as String?,
    );
  }
}
