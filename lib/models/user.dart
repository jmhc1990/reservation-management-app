import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String telefono;
  final String rol;
  final DateTime fechaCreacion;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.telefono,
    this.rol = 'cliente', // Valor por defecto al crear un nuevo usuario
    required this.fechaCreacion,
  });

  // Crear un UserModel a partir de un Map<String, dynamic> obtenido de Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'] ?? '',
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  // Convertir un UserModel en un Map<String, dynamic> para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'rol': rol,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Para actualizar campos sin perder la información existente
  UserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? telefono,
    String? rol,
    DateTime? fechaCreacion,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}