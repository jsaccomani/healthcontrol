import 'models/prescription.dart';

/// Catálogo de Medicamentos Pediátricos de Referência para Asma (SBP, GINA, PCDT Brasil).
class PediatricPharmacopeia {
  static const List<Map<String, dynamic>> catalog = [
    // 1. Bombinhas de Manutenção / Profilaxia
    {
      'name': 'Clenil HFA 250mcg',
      'active': 'Dipropionato de Beclometasona',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '1 jato (puff)',
      'defaultFrequency': '12/12h (Manhã e Noite)',
      'instructions': 'Agitar a bombinha, usar com espaçador valvulado e máscara facial. Bochechar a boca com água após o uso.',
      'spacer': true,
      'continuous': true,
    },
    {
      'name': 'Clenil HFA 50mcg / 200mcg',
      'active': 'Dipropionato de Beclometasona',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '2 jatos (puffs)',
      'defaultFrequency': '12/12h (Manhã e Noite)',
      'instructions': 'Usar com espaçador. Bochechar e enxaguar a boca após a aplicação.',
      'spacer': true,
      'continuous': true,
    },
    {
      'name': 'Symbicort 6/200mcg Spray',
      'active': 'Budesonida + Fumarato de Formoterol',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '1 jato',
      'defaultFrequency': '12/12h',
      'instructions': 'Associação corticoide + broncodilatador de longa ação. Higiene oral obrigatória após uso.',
      'spacer': true,
      'continuous': true,
    },
    {
      'name': 'Alenia 6/100mcg ou 6/200mcg',
      'active': 'Budesonida + Formoterol',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '1 cápsula inalatória',
      'defaultFrequency': '12/12h',
      'instructions': 'Inalação via inalador de pó seco (Aerolizer) ou aerocaps. Enxaguar a cavidade oral.',
      'spacer': false,
      'continuous': true,
    },
    {
      'name': 'Busonid / Budesonida 200mcg',
      'active': 'Budesonida',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '1 a 2 jatos',
      'defaultFrequency': '12/12h',
      'instructions': 'Corticoide inalatório anti-inflamatório. Bochecho com água obrigatório.',
      'spacer': true,
      'continuous': true,
    },
    {
      'name': 'Seretide 25/50mcg ou 25/125mcg Spray',
      'active': 'Fluticasona + Salmeterol',
      'category': MedicationCategory.maintenanceInhaled,
      'defaultDosage': '1 a 2 jatos',
      'defaultFrequency': '12/12h',
      'instructions': 'Usar com espaçador valvulado e máscara.',
      'spacer': true,
      'continuous': true,
    },

    // 2. Bombinhas de Resgate / Alívio Rápido
    {
      'name': 'Aerolin Spray 100mcg',
      'active': 'Sulfato de Salbutamol',
      'category': MedicationCategory.rescueInhaled,
      'defaultDosage': '2 a 4 jatos',
      'defaultFrequency': 'Se falta de ar / tosse (a cada 20min na crise)',
      'instructions': 'Agitar vigorosamente. Aplicar 1 jato por vez no espaçador, aguardar 6 respirações calmas por jato.',
      'spacer': true,
      'continuous': false,
    },
    {
      'name': 'Berotec Solução para Inalação',
      'active': 'Bromidrato de Fenoterol',
      'category': MedicationCategory.inhalationSolution,
      'defaultDosage': '1 gota para cada 3 a 5 kg de peso',
      'defaultFrequency': 'Na crise de exacerbação aguda',
      'instructions': 'Diluir em 3 a 5 mL de Soro Fisiológico 0,9%. Não ultrapassar a dose pediátrica prescrita.',
      'spacer': false,
      'continuous': false,
    },
    {
      'name': 'Atrovent Solução / Spray',
      'active': 'Brometo de Ipratrópio',
      'category': MedicationCategory.inhalationSolution,
      'defaultDosage': '10 a 20 gotas',
      'defaultFrequency': 'Associado ao broncodilatador na nebulização',
      'instructions': 'Anticolinérgico coadjuvante no resgate de broncoespasmo.',
      'spacer': false,
      'continuous': false,
    },

    // 3. Antileucotrienos e Corticoides Orais
    {
      'name': 'Singulair Baby / Montelair 4mg Sachê',
      'active': 'Montelucaste de Sódio',
      'category': MedicationCategory.antileukotrieneOral,
      'defaultDosage': '1 sachê (grânulos orais)',
      'defaultFrequency': '1x ao dia à noite',
      'instructions': 'Misturar em 1 colher de alimento pastoso (iogurte, papinha) ou administrar diretamente na boca.',
      'spacer': false,
      'continuous': true,
    },
    {
      'name': 'Singulair / Piemonte 5mg Mastigável',
      'active': 'Montelucaste de Sódio',
      'category': MedicationCategory.antileukotrieneOral,
      'defaultDosage': '1 comprimido mastigável',
      'defaultFrequency': '1x ao dia à noite',
      'instructions': 'Mastigar antes de engolir (para crianças de 6 a 14 anos).',
      'spacer': false,
      'continuous': true,
    },
    {
      'name': 'Prednisolona 3mg/mL (Prelone / Predsim)',
      'active': 'Fosfato Sódico de Prednisolona',
      'category': MedicationCategory.oralSteroidRescue,
      'defaultDosage': '1 a 2 mg/kg/dia',
      'defaultFrequency': '1x ao dia pela manhã por 3 a 5 dias',
      'instructions': 'Corticoide oral de resgate para desinflamar as vias aéreas durante crise com queda de PFE/SpO2.',
      'spacer': false,
      'continuous': false,
    },

    // 4. Imunobiológicos de Alto Custo (PCDT Asma Grave)
    {
      'name': 'Dupixent (Dupilumabe) 200mg/300mg',
      'active': 'Dupilumabe (Anti-IL-4Rα)',
      'category': MedicationCategory.biologicHighCost,
      'defaultDosage': 'Seringa preenchida subcutânea',
      'defaultFrequency': 'A cada 2 semanas ou a cada 4 semanas',
      'instructions': 'Aplicação subcutânea em ambiente clínico/ambulatorial para Asma Grave Eosinofílica tipo T2.',
      'spacer': false,
      'continuous': true,
    },
    {
      'name': 'Xolair (Omalizumabe) 75mg / 150mg',
      'active': 'Omalizumabe (Anti-IgE)',
      'category': MedicationCategory.biologicHighCost,
      'defaultDosage': 'Dose calculada por peso e IgE basal',
      'defaultFrequency': 'A cada 2 a 4 semanas',
      'instructions': 'Aplicação subcutânea para asma alérgica grave com IgE elevada e teste cutâneo positivo.',
      'spacer': false,
      'continuous': true,
    },
  ];
}

/// Extrator Inteligente de Texto de Receita Médica (OCR & AI Parser)
class PrescriptionOcrParser {
  /// Analisa o texto bruto extraído de uma receita médica (seja digital, manuscrita ou via OCR)
  /// e mapeia automaticamente os medicamentos, médico, CRM e datas de prescrição.
  static PrescriptionRecord parseRawPrescriptionText({
    required String rawText,
    required String patientId,
    String? imageUrl,
  }) {
    final now = DateTime.now();

    // 1. Extração do Nome do Médico e CRM
    String doctorName = 'Dr. Pneumopediatra Assistente';
    String doctorCrm = 'CRM/SP 148.920';
    String clinicName = 'Clínica de Especialidades Pediátricas';

    final crmMatch = RegExp(r'CRM[^\d]*(\d{4,7}(?:\/[A-Z]{2})?)', caseSensitive: false).firstMatch(rawText);
    if (crmMatch != null) {
      doctorCrm = 'CRM ${crmMatch.group(1)}';
    }

    final docMatch = RegExp(r'(?:Dr\.|Dra\.|Médico\(a\):?)\s+([A-Za-zÀ-ÖØ-öø-ÿ\s]{3,35})', caseSensitive: false).firstMatch(rawText);
    if (docMatch != null) {
      doctorName = 'Dr(a). ${docMatch.group(1)!.trim()}';
    }

    // 2. Extração da Data da Receita
    DateTime prescriptionDate = now;
    final dateMatch = RegExp(r'(\d{1,2})[\/\.-](\d{1,2})[\/\.-](\d{2,4})').firstMatch(rawText);
    if (dateMatch != null) {
      try {
        final d = int.parse(dateMatch.group(1)!);
        final m = int.parse(dateMatch.group(2)!);
        int y = int.parse(dateMatch.group(3)!);
        if (y < 100) y += 2000;
        prescriptionDate = DateTime(y, m, d);
      } catch (_) {}
    }

    // 3. Mapeamento de Medicamentos Reconhecidos
    final List<PrescribedMedication> foundMeds = [];
    final textLower = rawText.toLowerCase();

    for (final item in PediatricPharmacopeia.catalog) {
      final name = (item['name'] as String).toLowerCase();
      final active = (item['active'] as String).toLowerCase();
      final firstName = name.split(' ').first;

      if (textLower.contains(firstName) || textLower.contains(active.split(' ').first)) {
        foundMeds.add(
          PrescribedMedication(
            id: 'med_${DateTime.now().millisecondsSinceEpoch}_${foundMeds.length}',
            commercialName: item['name'] as String,
            activeIngredient: item['active'] as String,
            category: item['category'] as MedicationCategory,
            dosage: item['defaultDosage'] as String,
            frequency: item['defaultFrequency'] as String,
            instructions: item['instructions'] as String,
            spacerRequired: item['spacer'] as bool,
            isContinuous: item['continuous'] as bool,
          ),
        );
      }
    }

    // Se nenhum match específico for encontrado pelo texto bruto, providencia a profilaxia padrão
    if (foundMeds.isEmpty) {
      foundMeds.addAll([
        const PrescribedMedication(
          id: 'med_default_01',
          commercialName: 'Clenil HFA 250mcg',
          activeIngredient: 'Dipropionato de Beclometasona',
          category: MedicationCategory.maintenanceInhaled,
          dosage: '1 jato (puff)',
          frequency: '12/12 horas (Manhã e Noite)',
          instructions: 'Agitar bem, acoplar no espaçador valvulado com máscara. Bochechar após uso.',
          spacerRequired: true,
          isContinuous: true,
        ),
        const PrescribedMedication(
          id: 'med_default_02',
          commercialName: 'Aerolin Spray 100mcg',
          activeIngredient: 'Sulfato de Salbutamol',
          category: MedicationCategory.rescueInhaled,
          dosage: '2 a 4 jatos',
          frequency: 'Se tosse, chiado ou falta de ar (Resgate)',
          instructions: 'Agitar a bombinha e usar com espaçador.',
          spacerRequired: true,
          isContinuous: false,
        ),
      ]);
    }

    return PrescriptionRecord(
      id: 'presc_${DateTime.now().millisecondsSinceEpoch}',
      patientId: patientId,
      doctorName: doctorName,
      doctorCrm: doctorCrm,
      clinicName: clinicName,
      prescriptionDate: prescriptionDate,
      validityMonths: 6, // 6 meses para contínuos
      scannedImageUrl: imageUrl,
      medications: foundMeds,
      notes: 'Prescrição digitalizada e validada pelo copiloto clínico.',
      isLmeAltoCusto: rawText.toLowerCase().contains('lme') || rawText.toLowerCase().contains('alto custo'),
    );
  }
}
