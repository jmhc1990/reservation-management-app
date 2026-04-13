import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { cliente, admin }

// Modelo de usuario
class ModeloUsuario {
  final String uid;
  final String email;
  final String nombre;
  final String telefono;
  final RolUsuario rol;
  final DateTime fechaCreacion;

  ModeloUsuario({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.telefono,
    this.rol = RolUsuario.cliente, // Valor por defecto al crear un nuevo usuario
    required this.fechaCreacion,
  });

  // Crear un ModeloUsuario a partir de un Map<String, dynamic> obtenido de Firestore
  factory ModeloUsuario.fromMap(Map<String, dynamic> map) {
    return ModeloUsuario(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: RolUsuario.values.firstWhere(
        (e) => e.name == map['rol'],
        orElse: () => RolUsuario.cliente, // Si no se encuentra el rol, asignamos cliente por defecto
      ),
      fechaCreacion: map['fechaCreacion'] != null
          ? (map['fechaCreacion'] as Timestamp).toDate()
          : DateTime.now(), // Si no se encuentra la fecha, asignamos la fecha actual por defecto
    );
  }

  // Convertir un ModeloUsuario en un Map<String, dynamic> para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'rol': rol.name, // Guardamos el nombre del enum para facilitar la lectura en Firestore
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Para actualizar campos sin perder la información existente
  ModeloUsuario copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? telefono,
    RolUsuario? rol,
    DateTime? fechaCreacion,
  }) {
    return ModeloUsuario(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}