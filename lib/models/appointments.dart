import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoCita { pendiente, confirmada, completada, cancelada }

class ModeloCita {
  final String id;
  final String idCliente;
  final String idServicio;
  final String idBarbero;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final EstadoCita estado;
  final double precioTotal;

  ModeloCita({
    required this.id,
    required this.idCliente,
    required this.idServicio,
    required this.idBarbero,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.estado = EstadoCita.pendiente,
    required this.precioTotal,
  });

  factory ModeloCita.fromMap(Map<String, dynamic> map) {
    return ModeloCita(
      id: map['id'] ?? '',
      idCliente: map['idCliente'] ?? '',
      idServicio: map['idServicio'] ?? '',
      idBarbero: map['idBarbero'] ?? '',
      fecha: map['fecha'] != null
          ? (map['fecha'] as Timestamp).toDate()
          : DateTime.now(),
      horaInicio: map['horaInicio'] ?? '',
      horaFin: map['horaFin'] ?? '',
      estado: EstadoCita.values.firstWhere(
        (e) => e.name == map['estado'],
        orElse: () => EstadoCita.pendiente,
      ),
      precioTotal: (map['precioTotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCliente': idCliente,
      'idServicio': idServicio,
      'idBarbero': idBarbero,
      'fecha': Timestamp.fromDate(fecha),
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'estado': estado.name,
      'precioTotal': precioTotal,
    };
  }

  ModeloCita copyWith({
    String? id,
    String? idCliente,
    String? idServicio,
    String? idBarbero,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    EstadoCita? estado,
    double? precioTotal,
  }) {
    return ModeloCita(
      id: id ?? this.id,
      idCliente: idCliente ?? this.idCliente,
      idServicio: idServicio ?? this.idServicio,
      idBarbero: idBarbero ?? this.idBarbero,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      estado: estado ?? this.estado,
      precioTotal: precioTotal ?? this.precioTotal,
    );
  }
}