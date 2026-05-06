import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/staff.dart';

class StaffService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'staff';

  // Stream para obtener la lista de staff en tiempo real
  Stream<List<ModeloStaff>> streamStaff() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModeloStaff.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Stream para obtener un staff a partir de un ID en tiempo real
  Stream<ModeloStaff?> streamStaffById(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((doc){
      if (!doc.exists) return null;
      return ModeloStaff.fromMap({...doc.data()!, 'id': doc.id});
    });
  }

  // Obtiene todos los staff
  Future<List<ModeloStaff>> getStaff() async {
    try{
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs.map((doc) {
        return ModeloStaff.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener trabajadores: ${e.message}');
    }
  }

  // Agrega un nuevo staff
  Future<void> addStaff(ModeloStaff staff) async {
    try{
      await _db.collection(_collection).add(staff.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al agregar trabajador: ${e.message}');
    }
  }

  // Actualiza un staff existente
  Future<void> updateStaff(ModeloStaff staff) async {
    try{
      await _db.collection(_collection).doc(staff.id).update(staff.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar trabajador: ${e.message}');
    }
  }

  // Elimina un staff
  Future<void> deleteStaff(String id) async {
    try{
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Error al eliminar trabajador: ${e.message}');
    }
  }

  // Activa o desactiva un staff
  Future<void> setStaffActive(String id, bool isActive) async {
    try{
      await _db.collection(_collection).doc(id).update({
        'is_active': isActive
      });
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar estado del trabajador: ${e.message}');
    }
  }
}