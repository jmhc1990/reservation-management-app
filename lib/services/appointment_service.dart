import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointments.dart';

class AppointmentService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'appointments';

  // Crea una nueva cita
  Future<void> createAppointment(ModeloCita cita) async {
    try {
      await _db.collection(_collection).add(cita.toMap());
    } on FirebaseException catch (e) {
      throw Exception('Error al crear la cita: ${e.message}');
    }
  }

  // Consulta las citas de un trabajador en una fecha concreta
  Future<List<ModeloCita>> getAppointmentsByStaffAndDate({
    required String staffId,
    required DateTime date,
  }) async {
    try {
      // Rango del día completo
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _db
          .collection(_collection)
          .where('staff_id', isEqualTo: staffId)
          .where('status', isEqualTo: EstadoCita.confirmed.name)
          .where('start_time', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('start_time', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('start_time')
          .get();

      return snapshot.docs.map((doc) {
        return ModeloCita.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } on FirebaseException catch (e) {
      throw Exception('Error al obtener citas: ${e.message}');
    }
  }

  // Stream de citas de un cliente concreto
  Stream<List<ModeloCita>> streamClientAppointments(String clientId) {
    return _db
        .collection(_collection)
        .where('client_id', isEqualTo: clientId)
        .orderBy('start_time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ModeloCita.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    });
  }

  // Actualiza el estado de una cita
  Future<void> updateStatus({
    required String appointmentId,
    required EstadoCita newStatus,
  }) async {
    try {
      await _db.collection(_collection).doc(appointmentId).update({
        'status': newStatus.name,
      });
    } on FirebaseException catch (e) {
      throw Exception('Error al actualizar el estado: ${e.message}');
    }
  }
}