import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'users';

  // Obtiene todos los usuarios
  Future<List<ModeloUsuario>> getUsers() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs.map((doc) {
        return ModeloUsuario.fromMap({...doc.data(), 'uid': doc.id});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener usuarios: ${e.message}');
    }
  }

  // Stream de usuarios para actualización en tiempo real
  Stream<List<ModeloUsuario>> streamUsers() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModeloUsuario.fromMap({...doc.data(), 'uid': doc.id});
      }).toList();
    });
  }

  // Actualiza el rol y especialización de un usuario
  Future<void> updateRole({
    required String uid,
    required RolUsuario newRole,
    Specialization? specialization,
  }) async {
    try {
      await _db.collection(_collection).doc(uid).update({
        'role': newRole.name,
        // Si el nuevo rol no es staff, specialization se pone a null
        'specialization': newRole == RolUsuario.staff
            ? specialization?.name
            : null,
      });
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar el rol: ${e.message}');
    }
  }
}