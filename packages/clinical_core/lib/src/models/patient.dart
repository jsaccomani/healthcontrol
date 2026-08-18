/// Modelo Completo do Paciente Pediátrico, Pais, Anamnese Respiratória Avançada e Histórico Familiar.
class PatientProfile {
  final String id;
  final String name;
  final String? photoBase64; // Foto de registro da criança (Base64 ou URL)
  final String avatarId; // Identificador do avatar ilustrado caso não use foto
  final DateTime birthDate;
  final String gender;
  final String bloodType; // A+, A-, B+, B-, AB+, AB-, O+, O-
  final double heightCm;
  final double weightKg;
  final int personalBestPef;
  final String susCardNumber;
  final String healthInsurance;
  final String insuranceCardNumber;

  // Dados dos Pais / Responsáveis
  final String motherName;
  final String motherPhone;
  final String motherEmail;
  final String fatherName;
  final String fatherPhone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String addressCityState;

  // 1. Histórico Perinatal & Nascimento
  final int gestationalAgeWeeks; // Semanas de gestação (ex: 38 semanas)
  final int birthWeightGrams; // Peso ao nascer em gramas (ex: 3250g)
  final bool neonatalIcuOrOxygen; // Precisou de oxigênio ou UTI neonatal ao nascer?

  // 2. Anamnese Respiratória & Triagem Médica de Risco
  final String symptomsStartAge; // Idade de início dos sintomas (ex: "Aos 6 meses")
  final bool hadIcuAdmission; // Já teve internação em UTI por crise?
  final int icuAdmissionsCount; // Quantas internações em UTI
  final bool intubatedPast; // Já precisou de intubação endotraqueal?
  final int erVisitsLast12Months; // Idas ao Pronto-Socorro nos últimos 12 meses
  final int oralSteroidCoursesLastYear; // Ciclos de corticoide oral (Prednisolona) no último ano
  final int hospitalizationsCount; // Total de internações hospitalares
  final String lastHospitalizationInfo; // Data ou relato da última internação
  
  // 3. Padrão de Sintomas & Rotina
  final int nightAwakeningsPerMonth; // Quantas vezes acorda à noite tossindo/chiando por mês
  final String activityLimitation; // Limitação nas brincadeiras/escola (Nenhuma, Leve, Moderada, Severa)
  final List<String> crisisTriggers; // O que costuma desencadear as crises (Gripe, Frio, Riso, Exercício, etc.)

  // 4. Vacinação & Ambiente da Casa
  final bool fluVaccineUpToDate; // Vacina da gripe anual em dia?
  final bool pneumococcalVaccine; // Vacina de Pneumococo em dia?
  final bool householdSmokers; // Há fumantes no ambiente domiciliar?
  final String householdPets; // Animais de estimação com pelo em casa

  // 5. Alergias, Comorbidades e Histórico Familiar
  final List<String> familyAsthmaHistory; // Histórico familiar de atopia (Mãe, Pai, Irmãos, etc.)
  final List<String> drugAllergies; // Alergias a medicamentos (Dipirona, Ibuprofeno, Amoxicilina, etc.)
  final List<String> foodAllergies; // Alergias alimentares (Leite/APLV, Ovo, etc.)
  final List<String> environmentalAllergies; // Alergias ambientais (Ácaros, Poeira, Mofo, etc.)
  final List<String> comorbidities; // Rinite, Refluxo, Dermatite, etc.
  final List<String> continuousMedications; // Medicações de uso contínuo
  final double igeLevel; // Biomarcador IgE total (UI/mL)
  final int eosinophilsCount; // Biomarcador Eosinófilos (cél/µL)
  final String doctorName; // Nome do Pneumopediatra / Pediatra
  final String doctorPhone; // Telefone do Médico
  final String preferredHospital; // Hospital de preferência para emergência

  // 6. Histórico Livre Contado pelos Pais (Espaço Amplo com Auto-Save)
  final String familyNotesAndHistory;

  const PatientProfile({
    required this.id,
    required this.name,
    this.photoBase64,
    this.avatarId = 'boy_1',
    required this.birthDate,
    required this.gender,
    this.bloodType = 'Não informado',
    required this.heightCm,
    required this.weightKg,
    required this.personalBestPef,
    required this.susCardNumber,
    required this.healthInsurance,
    required this.insuranceCardNumber,
    this.motherName = '',
    this.motherPhone = '',
    this.motherEmail = '',
    this.fatherName = '',
    this.fatherPhone = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.addressCityState = '',
    this.gestationalAgeWeeks = 39,
    this.birthWeightGrams = 3200,
    this.neonatalIcuOrOxygen = false,
    this.symptomsStartAge = 'Desde o 1º ano de vida',
    this.hadIcuAdmission = false,
    this.icuAdmissionsCount = 0,
    this.intubatedPast = false,
    this.erVisitsLast12Months = 1,
    this.oralSteroidCoursesLastYear = 2,
    this.hospitalizationsCount = 0,
    this.lastHospitalizationInfo = '',
    this.nightAwakeningsPerMonth = 1,
    this.activityLimitation = 'Normal - sem limitações para brincar',
    this.crisisTriggers = const ['Resfriados / Gripes', 'Mudança brusca de temperatura', 'Tempo seco e poeira'],
    this.fluVaccineUpToDate = true,
    this.pneumococcalVaccine = true,
    this.householdSmokers = false,
    this.householdPets = 'Nenhum',
    this.familyAsthmaHistory = const ['Mãe (Rinite/Asma)'],
    this.drugAllergies = const [],
    this.foodAllergies = const [],
    this.environmentalAllergies = const ['Ácaros da poeira', 'Poeira', 'Tempo frio'],
    this.comorbidities = const ['Rinite Alérgica Perene', 'Hiper-reatividade Brônquica'],
    this.continuousMedications = const ['Clenil HFA 250mcg'],
    this.igeLevel = 450.0,
    this.eosinophilsCount = 550,
    this.doctorName = 'Dr. Marco Aurélio Valente',
    this.doctorPhone = '(11) 98888-7777',
    this.preferredHospital = 'Hospital Infantil Sabará / Samaritano',
    this.familyNotesAndHistory = '',
  });

  /// Idade calculada em anos
  int get ageYears {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Texto amigável de idade (ex: "5 anos" ou "1 ano e 3 meses")
  String get ageDisplay {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months--;
    if (months < 24) {
      final y = months ~/ 12;
      final m = months % 12;
      if (y == 0) return '$m meses';
      return '$y ano${y > 1 ? 's' : ''} e $m m${m > 1 ? 'eses' : 'ês'}';
    }
    return '$ageYears anos';
  }

  /// Cálculo do Índice de Massa Corporal Pediátrico (IMC)
  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_base64': photoBase64,
      'avatar_id': avatarId,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'blood_type': bloodType,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'personal_best_pef': personalBestPef,
      'sus_card_number': susCardNumber,
      'health_insurance': healthInsurance,
      'insurance_card_number': insuranceCardNumber,
      'mother_name': motherName,
      'mother_phone': motherPhone,
      'mother_email': motherEmail,
      'father_name': fatherName,
      'father_phone': fatherPhone,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'address_city_state': addressCityState,
      'gestational_age_weeks': gestationalAgeWeeks,
      'birth_weight_grams': birthWeightGrams,
      'neonatal_icu_or_oxygen': neonatalIcuOrOxygen,
      'symptoms_start_age': symptomsStartAge,
      'had_icu_admission': hadIcuAdmission,
      'icu_admissions_count': icuAdmissionsCount,
      'intubated_past': intubatedPast,
      'er_visits_last_12_months': erVisitsLast12Months,
      'oral_steroid_courses_last_year': oralSteroidCoursesLastYear,
      'hospitalizations_count': hospitalizationsCount,
      'last_hospitalization_info': lastHospitalizationInfo,
      'night_awakenings_per_month': nightAwakeningsPerMonth,
      'activity_limitation': activityLimitation,
      'crisis_triggers': crisisTriggers,
      'flu_vaccine_up_to_date': fluVaccineUpToDate,
      'pneumococcal_vaccine': pneumococcalVaccine,
      'household_smokers': householdSmokers,
      'household_pets': householdPets,
      'family_asthma_history': familyAsthmaHistory,
      'drug_allergies': drugAllergies,
      'food_allergies': foodAllergies,
      'environmental_allergies': environmentalAllergies,
      'comorbidities': comorbidities,
      'continuous_medications': continuousMedications,
      'ige_level': igeLevel,
      'eosinophils_count': eosinophilsCount,
      'doctor_name': doctorName,
      'doctor_phone': doctorPhone,
      'preferred_hospital': preferredHospital,
      'family_notes_and_history': familyNotesAndHistory,
    };
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? 'child_default',
      name: json['name'] as String? ?? 'Arthur Saccomani',
      photoBase64: json['photo_base64'] as String?,
      avatarId: json['avatar_id'] as String? ?? 'boy_1',
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : DateTime(2021, 5, 15),
      gender: json['gender'] as String? ?? 'Masculino',
      bloodType: json['blood_type'] as String? ?? 'A+',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 110.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 19.5,
      personalBestPef: (json['personal_best_pef'] as num?)?.toInt() ?? 220,
      susCardNumber: json['sus_card_number'] as String? ?? '',
      healthInsurance: json['health_insurance'] as String? ?? 'Bradesco Saúde Top Nacional',
      insuranceCardNumber: json['insurance_card_number'] as String? ?? '',
      motherName: json['mother_name'] as String? ?? 'Juliana Saccomani',
      motherPhone: json['mother_phone'] as String? ?? '(11) 98765-4321',
      motherEmail: json['mother_email'] as String? ?? 'juliana@email.com',
      fatherName: json['father_name'] as String? ?? 'Pai',
      fatherPhone: json['father_phone'] as String? ?? '(11) 91234-5678',
      emergencyContactName: json['emergency_contact_name'] as String? ?? 'Juliana Saccomani (Mãe)',
      emergencyContactPhone: json['emergency_contact_phone'] as String? ?? '(11) 98765-4321',
      addressCityState: json['address_city_state'] as String? ?? 'São Paulo - SP',
      gestationalAgeWeeks: (json['gestational_age_weeks'] as num?)?.toInt() ?? 39,
      birthWeightGrams: (json['birth_weight_grams'] as num?)?.toInt() ?? 3200,
      neonatalIcuOrOxygen: json['neonatal_icu_or_oxygen'] as bool? ?? false,
      symptomsStartAge: json['symptoms_start_age'] as String? ?? 'Desde o 1º ano de vida',
      hadIcuAdmission: json['had_icu_admission'] as bool? ?? false,
      icuAdmissionsCount: (json['icu_admissions_count'] as num?)?.toInt() ?? 0,
      intubatedPast: json['intubated_past'] as bool? ?? false,
      erVisitsLast12Months: (json['er_visits_last_12_months'] as num?)?.toInt() ?? 1,
      oralSteroidCoursesLastYear: (json['oral_steroid_courses_last_year'] as num?)?.toInt() ?? 2,
      hospitalizationsCount: (json['hospitalizations_count'] as num?)?.toInt() ?? 0,
      lastHospitalizationInfo: json['last_hospitalization_info'] as String? ?? '',
      nightAwakeningsPerMonth: (json['night_awakenings_per_month'] as num?)?.toInt() ?? 1,
      activityLimitation: json['activity_limitation'] as String? ?? 'Normal - sem limitações para brincar',
      crisisTriggers: (json['crisis_triggers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Resfriados / Gripes', 'Mudança brusca de temperatura', 'Tempo seco e poeira'],
      fluVaccineUpToDate: json['flu_vaccine_up_to_date'] as bool? ?? true,
      pneumococcalVaccine: json['pneumococcal_vaccine'] as bool? ?? true,
      householdSmokers: json['household_smokers'] as bool? ?? false,
      householdPets: json['household_pets'] as String? ?? 'Nenhum',
      familyAsthmaHistory: (json['family_asthma_history'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Mãe (Rinite/Asma)'],
      drugAllergies: (json['drug_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      foodAllergies: (json['food_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      environmentalAllergies: (json['environmental_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Ácaros da poeira', 'Poeira', 'Tempo frio'],
      comorbidities: (json['comorbidities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Rinite Alérgica Perene', 'Hiper-reatividade Brônquica'],
      continuousMedications: (json['continuous_medications'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const ['Clenil HFA 250mcg'],
      igeLevel: (json['ige_level'] as num?)?.toDouble() ?? 450.0,
      eosinophilsCount: (json['eosinophils_count'] as num?)?.toInt() ?? 550,
      doctorName: json['doctor_name'] as String? ?? 'Dr. Marco Aurélio Valente',
      doctorPhone: json['doctor_phone'] as String? ?? '(11) 98888-7777',
      preferredHospital: json['preferred_hospital'] as String? ?? 'Hospital Infantil Sabará / Samaritano',
      familyNotesAndHistory: json['family_notes_and_history'] as String? ?? '',
    );
  }
}
