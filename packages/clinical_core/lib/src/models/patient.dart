import 'legal_guardian.dart';
import 'caregiver.dart';
import 'emergency_contact.dart';
import 'healthcare_professional.dart';
import 'special_condition.dart';
import 'functional_limitation.dart';
import 'care_requirement.dart';

/// Modelo Completo do Paciente Pediátrico, Rede de Cuidado, Anamnese Respiratória e Condições Especiais.
class PatientProfile {
  final String id;
  final int schemaVersion;
  final String name;
  final String? photoBase64; // Foto de registro da criança (Base64 ou URL)
  final String avatarId; // Identificador do avatar ilustrado caso não use foto
  final DateTime birthDate;
  final String gender;
  final String bloodType; // A+, A-, B+, B-, AB+, AB-, O+, O-, Não informado
  final double heightCm;
  final double weightKg;
  final int personalBestPef;
  final String susCardNumber;
  final String healthInsurance;
  final String insuranceCardNumber;

  // ---------------------------------------------------------------------------
  // Nova Estrutura Canônica de Rede de Cuidado & Acessibilidade (Schema v2)
  // ---------------------------------------------------------------------------
  final List<LegalGuardian> legalGuardians;
  final List<Caregiver> caregivers;
  final List<EmergencyContact> emergencyContacts;
  final List<HealthcareProfessional> healthcareProfessionals;
  final List<SpecialCondition> specialConditions;
  final List<FunctionalLimitation> functionalLimitations;
  final List<CareRequirement> careRequirements;

  // ---------------------------------------------------------------------------
  // Campos Legados Preservados (Garantia de Compatibilidade com Versões Anteriores)
  // ---------------------------------------------------------------------------
  final String motherName;
  final String motherPhone;
  final String motherEmail;
  final String fatherName;
  final String fatherPhone;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String addressCityState;

  // 1. Histórico Perinatal & Nascimento
  final int? gestationalAgeWeeks; // Semanas de gestação (ex: 39 semanas)
  final int? birthWeightGrams; // Peso ao nascer em gramas (ex: 3200g)
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
    this.schemaVersion = 2,
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
    this.legalGuardians = const [],
    this.caregivers = const [],
    this.emergencyContacts = const [],
    this.healthcareProfessionals = const [],
    this.specialConditions = const [],
    this.functionalLimitations = const [],
    this.careRequirements = const [],
    this.motherName = '',
    this.motherPhone = '',
    this.motherEmail = '',
    this.fatherName = '',
    this.fatherPhone = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.addressCityState = '',
    this.gestationalAgeWeeks,
    this.birthWeightGrams,
    this.neonatalIcuOrOxygen = false,
    this.symptomsStartAge = '',
    this.hadIcuAdmission = false,
    this.icuAdmissionsCount = 0,
    this.intubatedPast = false,
    this.erVisitsLast12Months = 0,
    this.oralSteroidCoursesLastYear = 0,
    this.hospitalizationsCount = 0,
    this.lastHospitalizationInfo = '',
    this.nightAwakeningsPerMonth = 0,
    this.activityLimitation = 'Não informado',
    this.crisisTriggers = const [],
    this.fluVaccineUpToDate = false,
    this.pneumococcalVaccine = false,
    this.householdSmokers = false,
    this.householdPets = 'Não informado',
    this.familyAsthmaHistory = const [],
    this.drugAllergies = const [],
    this.foodAllergies = const [],
    this.environmentalAllergies = const [],
    this.comorbidities = const [],
    this.continuousMedications = const [],
    this.igeLevel = 0,
    this.eosinophilsCount = 0,
    this.doctorName = '',
    this.doctorPhone = '',
    this.preferredHospital = '',
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

  /// Retorna o médico assistente primário estruturado ou fallback
  HealthcareProfessional? get primaryDoctor {
    if (healthcareProfessionals.isNotEmpty) {
      final found = healthcareProfessionals.where((p) => p.isPrimaryAttending);
      if (found.isNotEmpty) return found.first;
      return healthcareProfessionals.first;
    }
    return null;
  }

  /// Retorna o contato de emergência com maior prioridade
  EmergencyContact? get primaryEmergencyContact {
    if (emergencyContacts.isNotEmpty) {
      final sorted = List<EmergencyContact>.from(emergencyContacts)
        ..sort((a, b) => a.priority.compareTo(b.priority));
      return sorted.first;
    }
    return null;
  }

  /// Indica se a criança possui plano de cuidado ou acompanhamento cadastrado
  bool get hasCarePlan =>
      specialConditions.isNotEmpty ||
      healthcareProfessionals.isNotEmpty ||
      continuousMedications.isNotEmpty;

  PatientProfile copyWith({
    String? id,
    int? schemaVersion,
    String? name,
    String? photoBase64,
    String? avatarId,
    DateTime? birthDate,
    String? gender,
    String? bloodType,
    double? heightCm,
    double? weightKg,
    int? personalBestPef,
    String? susCardNumber,
    String? healthInsurance,
    String? insuranceCardNumber,
    List<LegalGuardian>? legalGuardians,
    List<Caregiver>? caregivers,
    List<EmergencyContact>? emergencyContacts,
    List<HealthcareProfessional>? healthcareProfessionals,
    List<SpecialCondition>? specialConditions,
    List<FunctionalLimitation>? functionalLimitations,
    List<CareRequirement>? careRequirements,
    String? motherName,
    String? motherPhone,
    String? motherEmail,
    String? fatherName,
    String? fatherPhone,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? addressCityState,
    int? gestationalAgeWeeks,
    int? birthWeightGrams,
    bool? neonatalIcuOrOxygen,
    String? symptomsStartAge,
    bool? hadIcuAdmission,
    int? icuAdmissionsCount,
    bool? intubatedPast,
    int? erVisitsLast12Months,
    int? oralSteroidCoursesLastYear,
    int? hospitalizationsCount,
    String? lastHospitalizationInfo,
    int? nightAwakeningsPerMonth,
    String? activityLimitation,
    List<String>? crisisTriggers,
    bool? fluVaccineUpToDate,
    bool? pneumococcalVaccine,
    bool? householdSmokers,
    String? householdPets,
    List<String>? familyAsthmaHistory,
    List<String>? drugAllergies,
    List<String>? foodAllergies,
    List<String>? environmentalAllergies,
    List<String>? comorbidities,
    List<String>? continuousMedications,
    double? igeLevel,
    int? eosinophilsCount,
    String? doctorName,
    String? doctorPhone,
    String? preferredHospital,
    String? familyNotesAndHistory,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      name: name ?? this.name,
      photoBase64: photoBase64 ?? this.photoBase64,
      avatarId: avatarId ?? this.avatarId,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      personalBestPef: personalBestPef ?? this.personalBestPef,
      susCardNumber: susCardNumber ?? this.susCardNumber,
      healthInsurance: healthInsurance ?? this.healthInsurance,
      insuranceCardNumber: insuranceCardNumber ?? this.insuranceCardNumber,
      legalGuardians: legalGuardians ?? this.legalGuardians,
      caregivers: caregivers ?? this.caregivers,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      healthcareProfessionals: healthcareProfessionals ?? this.healthcareProfessionals,
      specialConditions: specialConditions ?? this.specialConditions,
      functionalLimitations: functionalLimitations ?? this.functionalLimitations,
      careRequirements: careRequirements ?? this.careRequirements,
      motherName: motherName ?? this.motherName,
      motherPhone: motherPhone ?? this.motherPhone,
      motherEmail: motherEmail ?? this.motherEmail,
      fatherName: fatherName ?? this.fatherName,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      addressCityState: addressCityState ?? this.addressCityState,
      gestationalAgeWeeks: gestationalAgeWeeks ?? this.gestationalAgeWeeks,
      birthWeightGrams: birthWeightGrams ?? this.birthWeightGrams,
      neonatalIcuOrOxygen: neonatalIcuOrOxygen ?? this.neonatalIcuOrOxygen,
      symptomsStartAge: symptomsStartAge ?? this.symptomsStartAge,
      hadIcuAdmission: hadIcuAdmission ?? this.hadIcuAdmission,
      icuAdmissionsCount: icuAdmissionsCount ?? this.icuAdmissionsCount,
      intubatedPast: intubatedPast ?? this.intubatedPast,
      erVisitsLast12Months: erVisitsLast12Months ?? this.erVisitsLast12Months,
      oralSteroidCoursesLastYear: oralSteroidCoursesLastYear ?? this.oralSteroidCoursesLastYear,
      hospitalizationsCount: hospitalizationsCount ?? this.hospitalizationsCount,
      lastHospitalizationInfo: lastHospitalizationInfo ?? this.lastHospitalizationInfo,
      nightAwakeningsPerMonth: nightAwakeningsPerMonth ?? this.nightAwakeningsPerMonth,
      activityLimitation: activityLimitation ?? this.activityLimitation,
      crisisTriggers: crisisTriggers ?? this.crisisTriggers,
      fluVaccineUpToDate: fluVaccineUpToDate ?? this.fluVaccineUpToDate,
      pneumococcalVaccine: pneumococcalVaccine ?? this.pneumococcalVaccine,
      householdSmokers: householdSmokers ?? this.householdSmokers,
      householdPets: householdPets ?? this.householdPets,
      familyAsthmaHistory: familyAsthmaHistory ?? this.familyAsthmaHistory,
      drugAllergies: drugAllergies ?? this.drugAllergies,
      foodAllergies: foodAllergies ?? this.foodAllergies,
      environmentalAllergies: environmentalAllergies ?? this.environmentalAllergies,
      comorbidities: comorbidities ?? this.comorbidities,
      continuousMedications: continuousMedications ?? this.continuousMedications,
      igeLevel: igeLevel ?? this.igeLevel,
      eosinophilsCount: eosinophilsCount ?? this.eosinophilsCount,
      doctorName: doctorName ?? this.doctorName,
      doctorPhone: doctorPhone ?? this.doctorPhone,
      preferredHospital: preferredHospital ?? this.preferredHospital,
      familyNotesAndHistory: familyNotesAndHistory ?? this.familyNotesAndHistory,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schema_version': schemaVersion,
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

      // Coleções Estruturadas (Schema v2)
      'legal_guardians': legalGuardians.map((g) => g.toJson()).toList(),
      'caregivers': caregivers.map((c) => c.toJson()).toList(),
      'emergency_contacts': emergencyContacts.map((e) => e.toJson()).toList(),
      'healthcare_professionals': healthcareProfessionals.map((p) => p.toJson()).toList(),
      'special_conditions': specialConditions.map((s) => s.toJson()).toList(),
      'functional_limitations': functionalLimitations.map((l) => l.toJson()).toList(),
      'care_requirements': careRequirements.map((r) => r.toJson()).toList(),

      // Campos Legados
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
    final id = json['id'] as String? ?? 'child_default';
    final schemaVer = (json['schema_version'] as num?)?.toInt() ?? 1;

    // 1. Parsing das Coleções Estruturadas (se existirem no JSON)
    List<LegalGuardian> guardians = [];
    if (json['legal_guardians'] is List) {
      guardians = (json['legal_guardians'] as List<dynamic>)
          .map((g) => LegalGuardian.fromJson(g as Map<String, dynamic>))
          .toList();
    }

    List<Caregiver> caregivers = [];
    if (json['caregivers'] is List) {
      caregivers = (json['caregivers'] as List<dynamic>)
          .map((c) => Caregiver.fromJson(c as Map<String, dynamic>))
          .toList();
    }

    List<EmergencyContact> emergencyContacts = [];
    if (json['emergency_contacts'] is List) {
      emergencyContacts = (json['emergency_contacts'] as List<dynamic>)
          .map((e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<HealthcareProfessional> professionals = [];
    if (json['healthcare_professionals'] is List) {
      professionals = (json['healthcare_professionals'] as List<dynamic>)
          .map((p) => HealthcareProfessional.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    List<SpecialCondition> conditions = [];
    if (json['special_conditions'] is List) {
      conditions = (json['special_conditions'] as List<dynamic>)
          .map((s) => SpecialCondition.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    List<FunctionalLimitation> limitations = [];
    if (json['functional_limitations'] is List) {
      limitations = (json['functional_limitations'] as List<dynamic>)
          .map((l) => FunctionalLimitation.fromJson(l as Map<String, dynamic>))
          .toList();
    }

    List<CareRequirement> careRequirements = [];
    if (json['care_requirements'] is List) {
      careRequirements = (json['care_requirements'] as List<dynamic>)
          .map((r) => CareRequirement.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    // 2. Extração dos Campos Legados
    final legacyMotherName = json['mother_name'] as String? ?? '';
    final legacyMotherPhone = json['mother_phone'] as String? ?? '';
    final legacyMotherEmail = json['mother_email'] as String? ?? '';
    final legacyFatherName = json['father_name'] as String? ?? '';
    final legacyFatherPhone = json['father_phone'] as String? ?? '';
    final legacyEmergencyName = json['emergency_contact_name'] as String? ?? '';
    final legacyEmergencyPhone = json['emergency_contact_phone'] as String? ?? '';
    final legacyDoctorName = json['doctor_name'] as String? ?? '';
    final legacyDoctorPhone = json['doctor_phone'] as String? ?? '';
    final legacyPreferredHospital = json['preferred_hospital'] as String? ?? '';
    final rawComorbidities = (json['comorbidities'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [];

    // 3. Migração Determinística e Idempotente de Dados Legados (Schema v1 -> v2)
    // 3.1 Responsáveis Legais
    if (guardians.isEmpty) {
      if (legacyMotherName.trim().isNotEmpty) {
        guardians.add(LegalGuardian(
          id: 'guardian_mother_$id',
          fullName: legacyMotherName.trim(),
          relationshipType: LegalGuardianRelationshipType.mother,
          phone: legacyMotherPhone.trim(),
          email: legacyMotherEmail.trim().isNotEmpty ? legacyMotherEmail.trim() : null,
          hasLegalCustody: true,
          isPrimaryContact: true,
        ));
      }
      if (legacyFatherName.trim().isNotEmpty) {
        guardians.add(LegalGuardian(
          id: 'guardian_father_$id',
          fullName: legacyFatherName.trim(),
          relationshipType: LegalGuardianRelationshipType.father,
          phone: legacyFatherPhone.trim(),
          hasLegalCustody: true,
          isPrimaryContact: guardians.isEmpty,
        ));
      }
    }

    // 3.2 Cuidadores Ativos
    if (caregivers.isEmpty) {
      for (final g in guardians) {
        final CaregiverRelationshipType rel;
        switch (g.relationshipType) {
          case LegalGuardianRelationshipType.mother:
            rel = CaregiverRelationshipType.mother;
            break;
          case LegalGuardianRelationshipType.father:
            rel = CaregiverRelationshipType.father;
            break;
          case LegalGuardianRelationshipType.grandmother:
            rel = CaregiverRelationshipType.grandmother;
            break;
          case LegalGuardianRelationshipType.grandfather:
            rel = CaregiverRelationshipType.grandfather;
            break;
          case LegalGuardianRelationshipType.aunt:
            rel = CaregiverRelationshipType.aunt;
            break;
          case LegalGuardianRelationshipType.uncle:
            rel = CaregiverRelationshipType.uncle;
            break;
          default:
            rel = CaregiverRelationshipType.other;
        }

        caregivers.add(Caregiver(
          id: 'caregiver_${g.id}',
          fullName: g.fullName,
          relationshipType: rel,
          phone: g.phone,
          email: g.email,
          accessLevel: g.isPrimaryContact
              ? CaregiverAccessLevel.primaryGuardian
              : CaregiverAccessLevel.guardian,
          isPrimary: g.isPrimaryContact,
        ));
      }
    }

    // 3.3 Contatos de Emergência
    if (emergencyContacts.isEmpty) {
      if (legacyEmergencyName.trim().isNotEmpty) {
        emergencyContacts.add(EmergencyContact(
          id: 'em_contact_primary_$id',
          fullName: legacyEmergencyName.trim(),
          relationship: 'Principal',
          phone: legacyEmergencyPhone.trim().isNotEmpty
              ? legacyEmergencyPhone.trim()
              : (legacyMotherPhone.trim().isNotEmpty ? legacyMotherPhone.trim() : legacyFatherPhone.trim()),
          priority: 1,
        ));
      } else if (guardians.isNotEmpty) {
        final primary = guardians.firstWhere(
          (g) => g.isPrimaryContact,
          orElse: () => guardians.first,
        );
        emergencyContacts.add(EmergencyContact(
          id: 'em_contact_${primary.id}',
          fullName: primary.fullName,
          relationship: primary.displayRelationship,
          phone: primary.phone,
          priority: 1,
        ));
      }
    }

    // 3.4 Profissionais de Saúde
    if (professionals.isEmpty && legacyDoctorName.trim().isNotEmpty) {
      professionals.add(HealthcareProfessional(
        id: 'doc_primary_$id',
        fullName: legacyDoctorName.trim(),
        specialty: HealthcareSpecialty.pediatricPulmonologist,
        primaryPhone: legacyDoctorPhone.trim(),
        clinicOrHospital: legacyPreferredHospital.trim().isNotEmpty ? legacyPreferredHospital.trim() : null,
        isPrimaryAttending: true,
        isActiveRelationship: true,
      ));
    }

    // 3.5 Condições Especiais estruturadas a partir de comorbidades
    if (conditions.isEmpty && rawComorbidities.isNotEmpty) {
      for (int i = 0; i < rawComorbidities.length; i++) {
        final cName = rawComorbidities[i];
        conditions.add(SpecialCondition(
          id: 'cond_${id}_$i',
          name: cName,
          category: ConditionCategory.respiratory,
          isConfirmed: true,
        ));
      }
    }

    return PatientProfile(
      id: id,
      schemaVersion: schemaVer < 2 ? 2 : schemaVer,
      name: json['name'] as String? ?? 'Criança (nome não disponível)',
      photoBase64: json['photo_base64'] as String?,
      avatarId: json['avatar_id'] as String? ?? 'boy_1',
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date'] as String) : DateTime(2000, 1, 1),
      gender: json['gender'] as String? ?? 'Não informado',
      bloodType: json['blood_type'] as String? ?? 'Não informado',
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      personalBestPef: (json['personal_best_pef'] as num?)?.toInt() ?? 0,
      susCardNumber: json['sus_card_number'] as String? ?? '',
      healthInsurance: json['health_insurance'] as String? ?? '',
      insuranceCardNumber: json['insurance_card_number'] as String? ?? '',

      // Listas Estruturadas
      legalGuardians: guardians,
      caregivers: caregivers,
      emergencyContacts: emergencyContacts,
      healthcareProfessionals: professionals,
      specialConditions: conditions,
      functionalLimitations: limitations,
      careRequirements: careRequirements,

      // Campos Legados
      motherName: legacyMotherName.isNotEmpty ? legacyMotherName : (guardians.isNotEmpty ? guardians.first.fullName : ''),
      motherPhone: legacyMotherPhone.isNotEmpty ? legacyMotherPhone : (guardians.isNotEmpty ? guardians.first.phone : ''),
      motherEmail: legacyMotherEmail,
      fatherName: legacyFatherName,
      fatherPhone: legacyFatherPhone,
      emergencyContactName: legacyEmergencyName.isNotEmpty ? legacyEmergencyName : (emergencyContacts.isNotEmpty ? emergencyContacts.first.fullName : ''),
      emergencyContactPhone: legacyEmergencyPhone.isNotEmpty ? legacyEmergencyPhone : (emergencyContacts.isNotEmpty ? emergencyContacts.first.phone : ''),
      addressCityState: json['address_city_state'] as String? ?? '',
      gestationalAgeWeeks: (json['gestational_age_weeks'] as num?)?.toInt(),
      birthWeightGrams: (json['birth_weight_grams'] as num?)?.toInt(),
      neonatalIcuOrOxygen: json['neonatal_icu_or_oxygen'] as bool? ?? false,
      symptomsStartAge: json['symptoms_start_age'] as String? ?? '',
      hadIcuAdmission: json['had_icu_admission'] as bool? ?? false,
      icuAdmissionsCount: (json['icu_admissions_count'] as num?)?.toInt() ?? 0,
      intubatedPast: json['intubated_past'] as bool? ?? false,
      erVisitsLast12Months: (json['er_visits_last_12_months'] as num?)?.toInt() ?? 0,
      oralSteroidCoursesLastYear: (json['oral_steroid_courses_last_year'] as num?)?.toInt() ?? 0,
      hospitalizationsCount: (json['hospitalizations_count'] as num?)?.toInt() ?? 0,
      lastHospitalizationInfo: json['last_hospitalization_info'] as String? ?? '',
      nightAwakeningsPerMonth: (json['night_awakenings_per_month'] as num?)?.toInt() ?? 0,
      activityLimitation: json['activity_limitation'] as String? ?? 'Não informado',
      crisisTriggers: (json['crisis_triggers'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      fluVaccineUpToDate: json['flu_vaccine_up_to_date'] as bool? ?? false,
      pneumococcalVaccine: json['pneumococcal_vaccine'] as bool? ?? false,
      householdSmokers: json['household_smokers'] as bool? ?? false,
      householdPets: json['household_pets'] as String? ?? 'Não informado',
      familyAsthmaHistory: (json['family_asthma_history'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      drugAllergies: (json['drug_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      foodAllergies: (json['food_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      environmentalAllergies: (json['environmental_allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      comorbidities: rawComorbidities.isNotEmpty ? rawComorbidities : const [],
      continuousMedications: (json['continuous_medications'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      igeLevel: (json['ige_level'] as num?)?.toDouble() ?? 0,
      eosinophilsCount: (json['eosinophils_count'] as num?)?.toInt() ?? 0,
      doctorName: legacyDoctorName.isNotEmpty ? legacyDoctorName : (professionals.isNotEmpty ? professionals.first.fullName : ''),
      doctorPhone: legacyDoctorPhone.isNotEmpty ? legacyDoctorPhone : (professionals.isNotEmpty ? professionals.first.primaryPhone : ''),
      preferredHospital: legacyPreferredHospital.isNotEmpty ? legacyPreferredHospital : (professionals.isNotEmpty && professionals.first.clinicOrHospital != null ? professionals.first.clinicOrHospital! : ''),
      familyNotesAndHistory: json['family_notes_and_history'] as String? ?? '',
    );
  }
}
