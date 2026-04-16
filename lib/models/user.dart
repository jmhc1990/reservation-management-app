import 'package:cloud_firestore/cloud_firestore.dart';

enum RolUsuario { client, staff, admin }

// Modelo de usuario
class ModeloUsuario {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final RolUsuario role;
  final DateTime createdAt;

  ModeloUsuario({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role = RolUsuario.client, // Valor por defecto al crear un nuevo usuario
    required this.createdAt,
  });

  // Crear un ModeloUsuario a partir de un Map<String, dynamic> obtenido de Firestore
  factory ModeloUsuario.fromMap(Map<String, dynamic> map) {
    return ModeloUsuario(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: RolUsuario.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => RolUsuario.client, // Si no se encuentra el rol, asignamos cliente por defecto
      ),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Si no se encuentra la fecha, asignamos la fecha actual por defecto
    );
  }

  // Convertir un ModeloUsuario en un Map<String, dynamic> para guardarlo en Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name, // Guardamos el nombre del enum para facilitar la lectura en Firestore
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Para actualizar campos sin perder la información existente
  ModeloUsuario copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    RolUsuario? role,
    DateTime? createdAt,
  }) {
    return ModeloUsuario(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}