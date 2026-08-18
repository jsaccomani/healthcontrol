/// Modelo do Paciente Pediátrico (Coleção /patients/{id}).
class Patient {
  final String id;
  final String fullName;
  final DateTime birthDate;
  final String gender;
  final String susCardNumber;
  final String? healthInsurance;
  final String? insuranceCardNumber;
  final double weightKg;
  final double heightCm;
  final int bestPefPersonal;
  final List<String> comorbidities;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.birthDate,
    required this.gender,
    required this.susCardNumber,
    this.healthInsurance,
    this.insuranceCardNumber,
    required this.weightKg,
    required this.heightCm,
    required this.bestPefPersonal,
    required this.comorbidities,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender,
      'sus_card_number': susCardNumber,
      'health_insurance': healthInsurance,
      'insurance_card_number': insuranceCardNumber,
      'weight_kg': weightKg,
      'height_cm': heightCm,
      'best_pef_personal': bestPefPersonal,
      'comorbidities': comorbidities,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      gender: json['gender'] as String,
      susCardNumber: json['sus_card_number'] as String,
      healthInsurance: json['health_insurance'] as String?,
      insuranceCardNumber: json['insurance_card_number'] as String?,
      weightKg: (json['weight_kg'] as num).toDouble(),
      heightCm: (json['height_cm'] as num).toDouble(),
      bestPefPersonal: json['best_pef_personal'] as int,
      comorbidities: List<String>.from(json['comorbidities'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
