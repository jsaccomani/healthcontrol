/// Modelo de Contato de Emergência (Acionamento Prioritário em Crise)
class EmergencyContact {
  final String id;
  final String fullName;
  final String relationship; // Ex: 'Mãe', 'Pai', 'Avó', 'Vizinha do 402', 'Tio'
  final String phone;
  final int priority; // 1 = Primeiro a ligar, 2 = Segundo, etc.
  final String? notes;

  const EmergencyContact({
    required this.id,
    required this.fullName,
    required this.relationship,
    required this.phone,
    this.priority = 1,
    this.notes,
  });

  EmergencyContact copyWith({
    String? id,
    String? fullName,
    String? relationship,
    String? phone,
    int? priority,
    String? notes,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'relationship': relationship,
      'phone': phone,
      'priority': priority,
      'notes': notes,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmergencyContact &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          relationship == other.relationship &&
          phone == other.phone &&
          priority == other.priority;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      relationship.hashCode ^
      phone.hashCode ^
      priority.hashCode;

  @override
  String toString() => 'EmergencyContact(id: $id, name: $fullName, rel: $relationship, phone: $phone, prio: $priority)';
}
