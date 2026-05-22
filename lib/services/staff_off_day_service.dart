import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff_off_day.dart';

class StaffOffDayService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'staff_off_days';

  // Stream de ausencias de un trabajador concreto
  Stream<List<ModeloStaffOffDay>> streamOffDays(String staffId) {
    return _db
        .collection(_collection)
        .where('staff_id', isEqualTo: staffId)
        .orderBy('start_date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModeloStaffOffDay.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Crea una nueva ausencia
  Future<void> addOffDay(ModeloStaffOffDay offDay) async {
    try {
      await _db.collection(_collection).add(offDay.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al añadir ausencia: ${e.message}');
    }
  }

  // Elimina una ausencia
  Future<void> deleteOffDay(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Error al eliminar ausencia: ${e.message}');
    }
  }

  // Edita una ausencia existente
  Future<void> updateOffDay(ModeloStaffOffDay offDay) async {
    try {
      await _db.collection(_collection).doc(offDay.id).update(offDay.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar ausencia: ${e.message}');
    }
  }
}