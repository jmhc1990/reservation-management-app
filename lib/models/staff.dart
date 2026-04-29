class TramoHorario {
  final String startHour;
  final String endHour;

  TramoHorario({
    required this.startHour,
    required this.endHour,
  });

  factory TramoHorario.fromMap(Map<String, dynamic> map) {
    return TramoHorario(
      startHour: map['start_hour'] ?? '',
      endHour: map['end_hour'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_hour': startHour,
      'end_hour': endHour,
    };
  }
}

class ModeloStaff {
  final String id;
  final String name;
  final String? photoUrl;
  final String bio;
  final List<String> specialties;
  final List<String> serviceIds;
  final Map<String, List<TramoHorario>?> workingHours; // null si es dia libre
  final bool isActive;

  ModeloStaff({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.bio,
    this.specialties = const [],
    this.serviceIds = const [],
    this.workingHours = const {},
    this.isActive = true,
  });

  // Comprueba si el staff está disponible en un día y hora específicos
  bool isAvailable(DateTime dateTime){
    if(!isActive) return false; // Si el staff no está activo, no está disponible

    // Dia de la semana en formato 'mon', 'tue', etc.
    const dias = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dia = dias[dateTime.weekday - 1];

    // Si el día no tiene horarios o es null, el staff no está disponible
    if(!workingHours.containsKey(dia) || workingHours[dia] == null) {
      return false;
    }

    final tramos = workingHours[dia]!;
    final horaActual = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return tramos.any((tramo) => 
      horaActual.compareTo(tramo.startHour) >= 0 && 
      horaActual.compareTo(tramo.endHour) < 0);
  }

  factory ModeloStaff.fromMap(Map<String, dynamic> map) {
    final rawHours = map['working_hours'] as Map<String, dynamic>? ?? {};
    final workingHours = rawHours.map((dia, value) {
      if (value == null) return MapEntry(dia, null);
      final tramos = (value as List<dynamic>)
        .map((t) => TramoHorario.fromMap(t as Map<String, dynamic>)).toList();
      return MapEntry(dia, tramos);
    });
    return ModeloStaff(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photo_url'],
      bio: map['bio'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      serviceIds: List<String>.from(map['service_ids'] ?? []),
      workingHours: workingHours,
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    final rawHours = workingHours.map((dia, tramos) {
      if (tramos == null) return MapEntry(dia, null);
      return MapEntry(dia, tramos.map((t) => t.toMap()).toList());
    });

    return {
      'name': name,
      'photo_url': photoUrl,
      'bio': bio,
      'specialties': specialties,
      'service_ids': serviceIds,
      'working_hours': rawHours,
      'is_active': isActive,
    };
  }

  ModeloStaff copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? bio,
    List<String>? specialties,
    List<String>? serviceIds,
    Map<String, List<TramoHorario>?>? workingHours,
    bool? isActive,
  }) {
    return ModeloStaff(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      serviceIds: serviceIds ?? this.serviceIds,
      workingHours: workingHours ?? this.workingHours,
      isActive: isActive ?? this.isActive,
    );
  }
}