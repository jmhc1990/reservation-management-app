import 'package:flutter_test/flutter_test.dart';
import 'package:style_sync/models/staff.dart'; // ← cambia TU_PROYECTO

void main() {
  // ─── Helpers ────────────────────────────────────────────────────────────

  // Crea un tramo horario de prueba
  TramoHorario tramo(String start, String end) =>
      TramoHorario(startHour: start, endHour: end);

  // Horario estándar de lunes a viernes: 9:00 - 18:00
  Map<String, List<TramoHorario>?> horarioEstandar() => {
    'mon': [tramo('09:00', '18:00')],
    'tue': [tramo('09:00', '18:00')],
    'wed': [tramo('09:00', '18:00')],
    'thu': [tramo('09:00', '18:00')],
    'fri': [tramo('09:00', '18:00')],
    'sat': null, // día libre
    'sun': null, // día libre
  };

  // Barbero activo con horario estándar
  ModeloStaff barberoBase({
    String id = 'staff_1',
    String name = 'Paco el Barbero',
    bool isActive = true,
    Map<String, List<TramoHorario>?>? workingHours,
  }) {
    return ModeloStaff(
      id: id,
      name: name,
      bio: 'Barbero con 10 años de experiencia',
      specialization: Specialization.barber,
      isActive: isActive,
      workingHours: workingHours ?? horarioEstandar(),
    );
  }

  // Fechas de referencia con día de semana conocido
  // Enero 2025: lunes=6, martes=7, miércoles=8, sábado=11, domingo=12
  final lunesA10h = DateTime(2025, 1, 6, 10, 0); // lunes     10:00
  final lunesA08h = DateTime(2025, 1, 6, 8, 59); // lunes     08:59
  final lunesA18h = DateTime(2025, 1, 6, 18, 0); // lunes     18:00 (límite)
  final lunesA17h59 = DateTime(2025, 1, 6, 17, 59); // lunes     17:59
  final lunesA09h = DateTime(2025, 1, 6, 9, 0); // lunes     09:00 (apertura)
  final sabadoA10h = DateTime(2025, 1, 11, 10, 0); // sábado    10:00
  final domingoA10h = DateTime(2025, 1, 12, 10, 0); // domingo   10:00

  // ─── TramoHorario ────────────────────────────────────────────────────────

  group('TramoHorario.fromMap()', () {
    test('deserializa correctamente start y end', () {
      final t = TramoHorario.fromMap({
        'start_hour': '09:00',
        'end_hour': '14:00',
      });
      expect(t.startHour, '09:00');
      expect(t.endHour, '14:00');
    });

    test('usa string vacío si los campos son null', () {
      final t = TramoHorario.fromMap({'start_hour': null, 'end_hour': null});
      expect(t.startHour, '');
      expect(t.endHour, '');
    });
  });

  group('TramoHorario.toMap()', () {
    test('serializa correctamente', () {
      final map = tramo('09:00', '14:00').toMap();
      expect(map['start_hour'], '09:00');
      expect(map['end_hour'], '14:00');
    });
  });

  // ─── ModeloStaff.fromMap() ───────────────────────────────────────────────

  group('ModeloStaff.fromMap()', () {
    test('deserializa correctamente todos los campos básicos', () {
      final map = {
        'id': 'staff_1',
        'name': 'Paco',
        'bio': 'Barbero experto',
        'specialization': 'barber',
        'is_active': true,
        'specialties': ['fade', 'navaja'],
        'service_ids': ['srv_1', 'srv_2'],
        'working_hours': <String, dynamic>{},
      };

      final staff = ModeloStaff.fromMap(map);
      expect(staff.id, 'staff_1');
      expect(staff.name, 'Paco');
      expect(staff.bio, 'Barbero experto');
      expect(staff.specialization, Specialization.barber);
      expect(staff.isActive, isTrue);
      expect(staff.specialties, ['fade', 'navaja']);
      expect(staff.serviceIds, ['srv_1', 'srv_2']);
    });

    test('specialization stylist se deserializa correctamente', () {
      final map = {
        'id': 'staff_2',
        'name': 'Ana',
        'bio': 'Estilista',
        'specialization': 'stylist',
        'is_active': true,
        'working_hours': <String, dynamic>{},
      };
      final staff = ModeloStaff.fromMap(map);
      expect(staff.specialization, Specialization.stylist);
    });

    test('specialization desconocida usa barber por defecto', () {
      final map = {
        'id': 'staff_1',
        'name': 'Paco',
        'bio': '',
        'specialization': 'chef',
        'is_active': true,
        'working_hours': <String, dynamic>{},
      };
      final staff = ModeloStaff.fromMap(map);
      expect(staff.specialization, Specialization.barber);
    });

    test('deserializa working_hours con tramos correctamente', () {
      final map = {
        'id': 'staff_1',
        'name': 'Paco',
        'bio': '',
        'specialization': 'barber',
        'is_active': true,
        'working_hours': {
          'mon': [
            {'start_hour': '09:00', 'end_hour': '14:00'},
            {'start_hour': '16:00', 'end_hour': '20:00'},
          ],
          'sat': null,
        },
      };

      final staff = ModeloStaff.fromMap(map);
      expect(staff.workingHours['mon']?.length, 2);
      expect(staff.workingHours['mon']![0].startHour, '09:00');
      expect(staff.workingHours['sat'], isNull);
    });

    test('listas vacías por defecto si faltan specialties y serviceIds', () {
      final map = {
        'id': 'staff_1',
        'name': 'Paco',
        'bio': '',
        'specialization': 'barber',
        'is_active': true,
        'working_hours': <String, dynamic>{},
      };
      final staff = ModeloStaff.fromMap(map);
      expect(staff.specialties, isEmpty);
      expect(staff.serviceIds, isEmpty);
    });
  });

  // ─── ModeloStaff.toMap() ─────────────────────────────────────────────────

  group('ModeloStaff.toMap()', () {
    test('serializa correctamente los campos básicos', () {
      final staff = barberoBase();
      final map = staff.toMap();

      expect(map['name'], 'Paco el Barbero');
      expect(map['bio'], 'Barbero con 10 años de experiencia');
      expect(map['specialization'], 'barber');
      expect(map['is_active'], isTrue);
    });

    test('toMap no incluye el id (lo gestiona Firestore)', () {
      final staff = barberoBase(id: 'staff_123');
      expect(staff.toMap().containsKey('id'), isFalse);
    });

    test('serializa working_hours con null para días libres', () {
      final staff = barberoBase();
      final map = staff.toMap();
      final hours = map['working_hours'] as Map<String, dynamic>;

      expect(hours['sat'], isNull);
      expect(hours['sun'], isNull);
      expect(hours['mon'], isA<List>());
    });
  });

  // ─── ModeloStaff.copyWith() ──────────────────────────────────────────────

  group('ModeloStaff.copyWith()', () {
    test('sin argumentos devuelve una copia idéntica', () {
      final original = barberoBase();
      final copia = original.copyWith();

      expect(copia.id, original.id);
      expect(copia.name, original.name);
      expect(copia.isActive, original.isActive);
      expect(copia.specialization, original.specialization);
    });

    test('desactiva el staff correctamente', () {
      final activo = barberoBase(isActive: true);
      final inactivo = activo.copyWith(isActive: false);

      expect(inactivo.isActive, isFalse);
      expect(inactivo.name, activo.name);
    });

    test('cambia solo el nombre', () {
      final original = barberoBase(name: 'Paco');
      final modificado = original.copyWith(name: 'Manolo');

      expect(modificado.name, 'Manolo');
      expect(modificado.id, original.id);
      expect(modificado.isActive, original.isActive);
    });

    test('cambia la especialización de barber a stylist', () {
      final original = barberoBase();
      final modificado = original.copyWith(
        specialization: Specialization.stylist,
      );

      expect(modificado.specialization, Specialization.stylist);
      expect(modificado.name, original.name);
    });
  });

  // ─── ModeloStaff.isAvailable() ───────────────────────────────────────────
  // Esta es la lógica más importante: determina si un barbero puede
  // recibir una cita en un momento dado.

  group('isAvailable() — staff inactivo', () {
    test('siempre devuelve false si isActive es false', () {
      final inactivo = barberoBase(isActive: false);
      expect(inactivo.isAvailable(lunesA10h), isFalse);
    });
  });

  group('isAvailable() — días libres', () {
    test('no disponible el sábado (día libre)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(sabadoA10h), isFalse);
    });

    test('no disponible el domingo (día libre)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(domingoA10h), isFalse);
    });

    test('no disponible si el día no está en workingHours', () {
      final staff = ModeloStaff(
        id: 'staff_1',
        name: 'Paco',
        bio: '',
        specialization: Specialization.barber,
        workingHours: {}, // sin ningún día configurado
      );
      expect(staff.isAvailable(lunesA10h), isFalse);
    });
  });

  group('isAvailable() — dentro del horario', () {
    test('disponible a las 10:00 en un lunes laborable', () {
      final staff = barberoBase();
      expect(staff.isAvailable(lunesA10h), isTrue);
    });

    test('disponible justo al abrir (09:00)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(lunesA09h), isTrue);
    });

    test('disponible al último minuto antes de cerrar (17:59)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(lunesA17h59), isTrue);
    });
  });

  group('isAvailable() — fuera del horario', () {
    test('no disponible antes de abrir (08:59)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(lunesA08h), isFalse);
    });

    test('no disponible justo al cerrar (18:00 es límite exclusivo)', () {
      final staff = barberoBase();
      expect(staff.isAvailable(lunesA18h), isFalse);
    });
  });

  group('isAvailable() — horario partido (mañana y tarde)', () {
    test('disponible en el tramo de mañana', () {
      final staff = ModeloStaff(
        id: 'staff_1',
        name: 'Paco',
        bio: '',
        specialization: Specialization.barber,
        workingHours: {
          'mon': [tramo('09:00', '14:00'), tramo('16:00', '20:00')],
        },
      );
      final lunesA11h = DateTime(2025, 1, 6, 11, 0);
      expect(staff.isAvailable(lunesA11h), isTrue);
    });

    test('disponible en el tramo de tarde', () {
      final staff = ModeloStaff(
        id: 'staff_1',
        name: 'Paco',
        bio: '',
        specialization: Specialization.barber,
        workingHours: {
          'mon': [tramo('09:00', '14:00'), tramo('16:00', '20:00')],
        },
      );
      final lunesA17h = DateTime(2025, 1, 6, 17, 0);
      expect(staff.isAvailable(lunesA17h), isTrue);
    });

    test('no disponible en el descanso entre tramos (14:00 - 16:00)', () {
      final staff = ModeloStaff(
        id: 'staff_1',
        name: 'Paco',
        bio: '',
        specialization: Specialization.barber,
        workingHours: {
          'mon': [tramo('09:00', '14:00'), tramo('16:00', '20:00')],
        },
      );
      final lunesA15h = DateTime(2025, 1, 6, 15, 0);
      expect(staff.isAvailable(lunesA15h), isFalse);
    });
  });

  // ─── Enum Specialization ─────────────────────────────────────────────────

  group('Specialization', () {
    test('tiene exactamente 2 valores', () {
      expect(Specialization.values.length, 2);
    });

    test('los nombres coinciden con los strings de Firestore', () {
      expect(Specialization.barber.name, 'barber');
      expect(Specialization.stylist.name, 'stylist');
    });
  });
}
