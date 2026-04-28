import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // lee el documento del usuario y devuelve su rol
  Future<RolUsuario> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists || doc.data() == null) return RolUsuario.client;

      return RolUsuario.values.firstWhere(
        (e) => e.name == doc.data()!['role'],
        orElse: () => RolUsuario.client,
      );
    } on FirebaseException catch (e) {
        throw Exception('Error al obtener el rol: ${e.message}');
    }
  }
}
