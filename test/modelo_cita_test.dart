import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:style_sync/models/appointments.dart';

void main() {
  // ─── Helper para crear citas de prueba fácilmente ───────────────────────
  ModeloCita citaBase({
    String id = 'cita_1',
    String clientId = 'cliente_1',
    String staffId = 'barbero_1',
    String serviceId = 'servicio_1',
    DateTime? startTime,
    int duration = 30,
    EstadoCita status = EstadoCita.confirmed,
  }) {
    return ModeloCita(
      id: id,
      clientId: clientId,
      staffId: staffId,
      serviceId: serviceId,
      startTime: startTime ?? DateTime(2025, 6, 1, 10, 0),
      duration: duration,
      status: status,
    );
  }

  // ─── fromMap ────────────────────────────────────────────────────────────

  group('ModeloCita.fromMap()', () {
    test('deserializa correctamente todos los campos', () {
      final map = {
        'id': 'cita_1',
        'client_id': 'cliente_1',
        'staff_id': 'barbero_1',
        'service_id': 'servicio_1',
        'start_time': Timestamp.fromDate(DateTime(2025, 6, 1, 10, 0)),
        'duration': 30,
        'status': 'confirmed',
      };

      final cita = ModeloCita.fromMap(map);

      expect(cita.id, 'cita_1');
      expect(cita.clientId, 'cliente_1');
      expect(cita.staffId, 'barbero_1');
      expect(cita.serviceId, 'servicio_1');
      expect(cita.duration, 30);
      expect(cita.status, EstadoCita.confirmed);
      expect(cita.startTime, DateTime(2025, 6, 1, 10, 0));
    });

    test('usa confirmed por defecto si el status no es válido', () {
      final map = {
        'id': 'cita_1',
        'client_id': 'cliente_1',
        'staff_id': 'barbero_1',
        'service_id': 'servicio_1',
        'start_time': Timestamp.fromDate(DateTime(2025, 6, 1, 10, 0)),
        'duration': 30,
        'status': 'estado_que_no_existe',
      };

      final cita = ModeloCita.fromMap(map);
      expect(cita.status, EstadoCita.confirmed);
    });

    test('usa valores vacíos/0 si los campos son null', () {
      final map = {
        'id': null,
        'client_id': null,
        'staff_id': null,
        'service_id': null,
        'start_time': null,
        'duration': null,
        'status': 'confirmed',
      };

      final cita = ModeloCita.fromMap(map);
      expect(cita.id, '');
      expect(cita.clientId, '');
      expect(cita.staffId, '');
      expect(cita.serviceId, '');
      expect(cita.duration, 0);
    });
  });

  // ─── toMap ──────────────────────────────────────────────────────────────

  group('ModeloCita.toMap()', () {
    test('serializa correctamente todos los campos', () {
      final cita = citaBase();
      final map = cita.toMap();

      expect(map['client_id'], 'cliente_1');
      expect(map['staff_id'], 'barbero_1');
      expect(map['service_id'], 'servicio_1');
      expect(map['duration'], 30);
      expect(map['status'], 'confirmed');
      expect(map['start_time'], isA<Timestamp>());
    });

    test('el status cancelled se serializa como string', () {
      final cita = citaBase(status: EstadoCita.cancelled);
      expect(cita.toMap()['status'], 'cancelled');
    });

    test('toMap no incluye el id (lo gestiona Firestore)', () {
      final cita = citaBase(id: 'cita_123');
      expect(cita.toMap().containsKey('id'), isFalse);
    });
  });

  // ─── copyWith ───────────────────────────────────────────────────────────

  group('ModeloCita.copyWith()', () {
    test('sin argumentos devuelve una copia idéntica', () {
      final original = citaBase();
      final copia = original.copyWith();

      expect(copia.id, original.id);
      expect(copia.status, original.status);
      expect(copia.startTime, original.startTime);
      expect(copia.duration, original.duration);
    });

    test('cambia solo el status', () {
      final original = citaBase(status: EstadoCita.confirmed);
      final cancelada = original.copyWith(status: EstadoCita.cancelled);

      expect(cancelada.status, EstadoCita.cancelled);
      expect(cancelada.id, original.id);
      expect(cancelada.clientId, original.clientId);
    });

    test('cambia solo la duración', () {
      final original = citaBase(duration: 30);
      final modificada = original.copyWith(duration: 60);

      expect(modificada.duration, 60);
      expect(modificada.staffId, original.staffId);
    });

    test('cambia el staffId sin afectar al resto', () {
      final original = citaBase(staffId: 'barbero_1');
      final reasignada = original.copyWith(staffId: 'barbero_2');

      expect(reasignada.staffId, 'barbero_2');
      expect(reasignada.clientId, original.clientId);
      expect(reasignada.status, original.status);
    });
  });

  // ─── EstadoCita ─────────────────────────────────────────────────────────

  group('EstadoCita', () {
    test('tiene exactamente 4 estados', () {
      expect(EstadoCita.values.length, 4);
    });

    test('contiene todos los estados esperados', () {
      expect(
        EstadoCita.values,
        containsAll([
          EstadoCita.confirmed,
          EstadoCita.cancelled,
          EstadoCita.completed,
          EstadoCita.noShow,
        ]),
      );
    });

    test('los nombres coinciden con los strings de Firestore', () {
      expect(EstadoCita.confirmed.name, 'confirmed');
      expect(EstadoCita.cancelled.name, 'cancelled');
      expect(EstadoCita.completed.name, 'completed');
      expect(EstadoCita.noShow.name, 'noShow');
    });
  });

  // ─── Lógica de conflictos ────────────────────────────────────────────────

  group('Detección de conflictos entre citas', () {
    // La misma lógica que hay en AppointmentService.createAppointment()
    bool hasConflict(ModeloCita nueva, List<ModeloCita> existing) {
      return existing.any(
        (a) =>
            nueva.startTime.isBefore(
              a.startTime.add(Duration(minutes: a.duration)),
            ) &&
            a.startTime.isBefore(
              nueva.startTime.add(Duration(minutes: nueva.duration)),
            ),
      );
    }

    test('Sin conflicto: nueva cita empieza cuando termina la existente', () {
      // Existente: 10:00 - 10:30 | Nueva: 10:30 - 11:00
      final existente = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 30,
      );
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 30),
        duration: 30,
      );
      expect(hasConflict(nueva, [existente]), isFalse);
    });

    test(
      'Sin conflicto: nueva cita termina antes de que empiece la existente',
      () {
        // Existente: 11:00 - 11:30 | Nueva: 10:00 - 10:30
        final existente = citaBase(
          startTime: DateTime(2025, 6, 1, 11, 0),
          duration: 30,
        );
        final nueva = citaBase(
          startTime: DateTime(2025, 6, 1, 10, 0),
          duration: 30,
        );
        expect(hasConflict(nueva, [existente]), isFalse);
      },
    );

    test('Sin conflicto: agenda vacía', () {
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 30,
      );
      expect(hasConflict(nueva, []), isFalse);
    });

    test('Conflicto: solapamiento parcial', () {
      // Existente: 10:00 - 11:00 | Nueva: 10:30 - 11:00
      final existente = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 60,
      );
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 30),
        duration: 30,
      );
      expect(hasConflict(nueva, [existente]), isTrue);
    });

    test('Conflicto: nueva cita completamente dentro de la existente', () {
      // Existente: 10:00 - 11:00 | Nueva: 10:15 - 10:30
      final existente = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 60,
      );
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 15),
        duration: 15,
      );
      expect(hasConflict(nueva, [existente]), isTrue);
    });

    test('Conflicto: misma hora de inicio', () {
      final existente = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 30,
      );
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 0),
        duration: 30,
      );
      expect(hasConflict(nueva, [existente]), isTrue);
    });

    test('Sin conflicto: nueva cita encaja en el hueco entre dos citas', () {
      // Hueco: 10:30 - 11:00 libre
      final existentes = [
        citaBase(startTime: DateTime(2025, 6, 1, 10, 0), duration: 30),
        citaBase(startTime: DateTime(2025, 6, 1, 11, 0), duration: 30),
      ];
      final nueva = citaBase(
        startTime: DateTime(2025, 6, 1, 10, 30),
        duration: 30,
      );
      expect(hasConflict(nueva, existentes), isFalse);
    });
  });

  // ─── Lógica de cancelación ───────────────────────────────────────────────

  group('Validación de cancelación de citas', () {
    // La misma lógica que hay en AppointmentService.cancelAppointment()
    bool puedeCancelar(DateTime startTime, {int minHours = 2}) {
      return !DateTime.now().isAfter(
        startTime.subtract(Duration(hours: minHours)),
      );
    }

    test('Se puede cancelar si faltan más de 2 horas', () {
      final cita = DateTime.now().add(const Duration(hours: 3));
      expect(puedeCancelar(cita), isTrue);
    });

    test('No se puede cancelar si falta menos de 2 horas', () {
      final cita = DateTime.now().add(const Duration(hours: 1));
      expect(puedeCancelar(cita), isFalse);
    });

    test('No se puede cancelar una cita que ya ha pasado', () {
      final cita = DateTime.now().subtract(const Duration(hours: 1));
      expect(puedeCancelar(cita), isFalse);
    });

    test('Se puede cancelar si faltan 24 horas', () {
      final cita = DateTime.now().add(const Duration(hours: 24));
      expect(puedeCancelar(cita), isTrue);
    });
  });
}
