import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoAusencia { vacation, sick, dayOff, training }

extension TipoAusenciaExtension on TipoAusencia {
  // Convierte el enum a un string para Firestore
  String toFirestore() {
    switch (this) {
      case TipoAusencia.dayOff:
        return 'day_off';
      default: 
        return name; // Usa el nombre del enum para los demás casos
    }
  }
  // Convierte string de Firestore al enum
  static TipoAusencia fromFirestore(String value) {
    switch (value) {
      case 'day_off':
        return TipoAusencia.dayOff;
      default:
        return TipoAusencia.values.firstWhere(
          (e) => e.name == value,
          orElse: () => TipoAusencia.dayOff, // Valor por defecto
        );
    }
  }
}

class ModeloStaffOffDay {
  final String id;
  final String staffId;
  final DateTime startDate;
  final DateTime endDate;
  final TipoAusencia reason;

  ModeloStaffOffDay({
    required this.id,
    required this.staffId,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  factory ModeloStaffOffDay.fromMap(Map<String, dynamic> map) {
    return ModeloStaffOffDay(
      id: map['id'] ?? '',
      staffId: map['staff_id'] ?? '',
      startDate: (map['start_date'] as Timestamp).toDate(),
      endDate: (map['end_date'] as Timestamp).toDate(),
      reason: TipoAusenciaExtension.fromFirestore(map['reason'] ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'staff_id': staffId,
      'start_date': Timestamp.fromDate(startDate),
      'end_date': Timestamp.fromDate(endDate),
      'reason': reason.toFirestore(),
    };
  }

  ModeloStaffOffDay copyWith({
    String? id,
    String? staffId,
    DateTime? startDate,
    DateTime? endDate,
    TipoAusencia? reason,
  }) {
    return ModeloStaffOffDay(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reason: reason ?? this.reason,
    );
  }
}