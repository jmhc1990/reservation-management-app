import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/services.dart';

class CatalogService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'services';

  // Método para obtener la lista de servicios desde Firestore
  Future<List<ModeloServicio>> getServices() async {
    try {
      final snapshot = await _db.collection(_collection).get();
      return snapshot.docs.map((doc) {
        return ModeloServicio.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al cargar servicios: ${e.message}');
    }
  }

  // Stream de servicios para actualizar en tiempo real
  Stream<List<ModeloServicio>> streamServices() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModeloServicio.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Método para crear un nuevo servicio
  Future<void> createService(ModeloServicio servicio) async {
    try {
      await _db.collection(_collection).add(servicio.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al crear servicio: ${e.message}');
    }
  }

  // Método para actualizar un servicio existente
  Future<void> updateService(ModeloServicio servicio) async {
    try {
      await _db.collection(_collection).doc(servicio.id).update(servicio.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar el servicio: ${e.message}');
    }
  }

  // Método para eliminar un servicio
  Future<void> deleteService(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw Exception('Error al eliminar el servicio: ${e.message}');
    }
  }
}