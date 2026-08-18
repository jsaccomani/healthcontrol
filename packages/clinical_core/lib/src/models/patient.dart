/// Modelo do Paciente Pediátrico / Perfil Clínico.
class PatientProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender;
  final double heightCm;
  final double weightKg;
  final int personalBestPef;
  final String susCardNumber;
  final String healthInsurance;
  final String insuranceCardNumber;
  final double igeLevel;
  final int eosinophilsCount;
  final List<String> comorbidities;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.personalBestPef,
    required this.susCardNumber,
    required this.healthInsurance,
    required this.insuranceCardNumber,
    required this.igeLevel,
    required this.eosinophilsCount,
    required this.comorbidities,
  });

  int get ageYears {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'personal_best_pef': personalBestPef,
      'sus_card_number': susCardNumber,
      'health_insurance': healthInsurance,
      'insurance_card_number': insuranceCardNumber,
      'ige_level': igeLevel,
      'eosinophils_count': eosinophilsCount,
      'comorbidities': comorbidities,
    };
  }

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? json['full_name'] as String? ?? 'Filho',
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: json['gender'] as String? ?? 'Masculino',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 110.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 19.5,
      personalBestPef: (json['personal_best_pef'] as int?) ?? (json['best_pef_personal'] as int?) ?? 220,
      susCardNumber: json['sus_card_number'] as String? ?? '',
      healthInsurance: json['health_insurance'] as String? ?? '',
      insuranceCardNumber: json['insurance_card_number'] as String? ?? '',
      igeLevel: (json['ige_level'] as num?)?.toDouble() ?? 450.0,
      eosinophilsCount: json['eosinophils_count'] as int? ?? 550,
      comorbidities: List<String>.from(json['comorbidities'] as List? ?? []),
    );
  }
}

/// Alias para retrocompatibilidade
typedef Patient = PatientProfile;
