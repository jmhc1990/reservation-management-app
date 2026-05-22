import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoCita { pending, confirmed, cancelled, completed, noShow }

class ModeloCita {
  final String id;
  final String clientId;
  final String staffId;
  final String serviceId;
  final DateTime startTime;
  final int duration;
  final EstadoCita status;

  ModeloCita({
    required this.id,
    required this.clientId,
    required this.staffId,
    required this.serviceId,
    required this.startTime,
    required this.duration,
    required this.status,
  });

  factory ModeloCita.fromMap(Map<String, dynamic> map) {
    return ModeloCita(
      id: map['id'] ?? '',
      clientId: map['client_id'] ?? '',
      staffId: map['staff_id'] ?? '',
      serviceId: map['service_id'] ?? '',
      startTime: map['start_time'] != null
          ? (map['start_time'] as Timestamp).toDate()
          : DateTime.now(),
      duration: map['duration'] ?? 0,
      status: EstadoCita.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => EstadoCita.confirmed,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'staff_id': staffId,
      'service_id': serviceId,
      'start_time': Timestamp.fromDate(startTime),
      'duration': duration,
      'status': status.name,
    };
  }

  ModeloCita copyWith({
    String? id,
    String? clientId,
    String? staffId,
    String? serviceId,
    DateTime? startTime,
    int? duration,
    EstadoCita? status,
  }) {
    return ModeloCita(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      staffId: staffId ?? this.staffId,
      serviceId: serviceId ?? this.serviceId,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }
}