import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff.dart';

enum RolUsuario { client, staff, admin }

// Modelo de usuario
class ModeloUsuario {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final RolUsuario role;
  final Specialization? specialization; // Solo para staff
  final DateTime createdAt;

  ModeloUsuario({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.role = RolUsuario.client, // Valor por defecto al crear un nuevo usuario
    this.specialization, // Solo para staff
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
      specialization: map['specialization'] != null
          ? Specialization.values.cast<Specialization?>().firstWhere(
              (e) => e?.name == map['specialization'],
              orElse: () => null, // Si no se encuentra la especialización, asignamos null
            )
          : null, // Solo para staff
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
      'specialization': specialization?.name, // Solo para staff
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
    Specialization? specialization, // Solo para staff
    DateTime? createdAt,
  }) {
    return ModeloUsuario(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      specialization: specialization ?? this.specialization, // Solo para staff
      createdAt: createdAt ?? this.createdAt,
    );
  }
}