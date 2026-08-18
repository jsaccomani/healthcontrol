/// Modelo Completo do Paciente Pediátrico, Pais e Anamnese Respiratória Avançada.
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

  // Anamnese Respiratória & Histórico Clínico
  final String symptomsStartAge; // Idade de início dos sintomas
  final bool hadIcuAdmission; // Já teve internação em UTI por crise?
  final int icuAdmissionsCount; // Quantas internações em UTI
  final String lastHospitalizationInfo; // Data ou relato da última internação
  final List<String> familyAsthmaHistory; // Histórico familiar de atopia (Mãe, Pai, etc.)
  final List<String> drugAllergies; // Alergias a medicamentos (AINEs, Dipirona, etc.)
  final List<String> foodAllergies; // Alergias alimentares (Leite, Ovo, etc.)
  final List<String> environmentalAllergies; // Alergias ambientais (Ácaro, Gato, etc.)
  final List<String> comorbidities; // Rinite, Refluxo, Dermatite, etc.
  final List<String> continuousMedications; // Medicações de uso contínuo
  final double igeLevel; // Biomarcador IgE total (UI/mL)
  final int eosinophilsCount; // Biomarcador Eosinófilos (cél/µL)
  final String doctorName; // Nome do Pneumopediatra / Pediatra
  final String doctorPhone; // Telefone do Médico

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
    this.symptomsStartAge = 'Desde o 1º ano de vida',
    this.hadIcuAdmission = false,
    this.icuAdmissionsCount = 0,
    this.lastHospitalizationInfo = '',
    this.familyAsthmaHistory = const ['Mãe'],
    this.drugAllergies = const [],
    this.foodAllergies = const [],
    this.environmentalAllergies = const ['Ácaros', 'Poeira'],
    this.comorbidities = const ['Rinite Alérgica'],
    this.continuousMedications = const ['Clenil HFA 250mcg'],
    this.igeLevel = 450.0,
    this.eosinophilsCount = 550,
    this.doctorName = '',
    this.doctorPhone = '',
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
      'symptoms_start_age': symptomsStartAge,
      'had_icu_admission': hadIcuAdmission,
      'icu_admissions_count': icuAdmissionsCount,
      'last_hospitalization_info': lastHospitalizationInfo,
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
    };
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String? ?? 'paciente-001',
      name: json['name'] as String? ?? json['full_name'] as String? ?? 'Filho',
      photoBase64: json['photo_base64'] as String?,
      avatarId: json['avatar_id'] as String? ?? 'boy_1',
      birthDate: DateTime.parse(json['birth_date'] as String? ?? '2021-05-15'),
      gender: json['gender'] as String? ?? 'Masculino',
      bloodType: json['blood_type'] as String? ?? 'Não informado',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 110.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 19.5,
      personalBestPef: (json['personal_best_pef'] as int?) ?? (json['best_pef_personal'] as int?) ?? 220,
      susCardNumber: json['sus_card_number'] as String? ?? '',
      healthInsurance: json['health_insurance'] as String? ?? '',
      insuranceCardNumber: json['insurance_card_number'] as String? ?? '',
      motherName: json['mother_name'] as String? ?? '',
      motherPhone: json['mother_phone'] as String? ?? '',
      motherEmail: json['mother_email'] as String? ?? '',
      fatherName: json['father_name'] as String? ?? '',
      fatherPhone: json['father_phone'] as String? ?? '',
      emergencyContactName: json['emergency_contact_name'] as String? ?? '',
      emergencyContactPhone: json['emergency_contact_phone'] as String? ?? '',
      addressCityState: json['address_city_state'] as String? ?? '',
      symptomsStartAge: json['symptoms_start_age'] as String? ?? 'Desde o 1º ano de vida',
      hadIcuAdmission: json['had_icu_admission'] as bool? ?? false,
      icuAdmissionsCount: json['icu_admissions_count'] as int? ?? 0,
      lastHospitalizationInfo: json['last_hospitalization_info'] as String? ?? '',
      familyAsthmaHistory: List<String>.from(json['family_asthma_history'] as List? ?? ['Mãe']),
      drugAllergies: List<String>.from(json['drug_allergies'] as List? ?? []),
      foodAllergies: List<String>.from(json['food_allergies'] as List? ?? []),
      environmentalAllergies: List<String>.from(json['environmental_allergies'] as List? ?? ['Ácaros', 'Poeira']),
      comorbidities: List<String>.from(json['comorbidities'] as List? ?? ['Rinite Alérgica']),
      continuousMedications: List<String>.from(json['continuous_medications'] as List? ?? ['Clenil HFA 250mcg']),
      igeLevel: (json['ige_level'] as num?)?.toDouble() ?? 450.0,
      eosinophilsCount: json['eosinophils_count'] as int? ?? 550,
      doctorName: json['doctor_name'] as String? ?? '',
      doctorPhone: json['doctor_phone'] as String? ?? '',
    );
  }
}

/// Alias para retrocompatibilidade
typedef Patient = PatientProfile;
