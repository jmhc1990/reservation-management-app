import 'package:flutter_test/flutter_test.dart';
import 'package:style_sync/models/services.dart';

void main() {
  // ─── Helper para crear servicios de prueba fácilmente ───────────────────
  ModeloServicio servicioBase({
    String id = 'servicio_1',
    String name = 'Corte de pelo',
    double price = 15.0,
    int duration = 30,
    String description = 'Corte clásico',
    String? imageUrl,
  }) {
    return ModeloServicio(
      id: id,
      name: name,
      price: price,
      duration: duration,
      description: description,
      imageUrl: imageUrl,
    );
  }

  // ─── fromMap ────────────────────────────────────────────────────────────

  group('ModeloServicio.fromMap()', () {
    test('deserializa correctamente todos los campos', () {
      final map = {
        'id': 'servicio_1',
        'name': 'Corte de pelo',
        'price': 15.0,
        'duration': 30,
        'description': 'Corte clásico',
        'image_url': 'https://ejemplo.com/imagen.jpg',
      };

      final servicio = ModeloServicio.fromMap(map);

      expect(servicio.id, 'servicio_1');
      expect(servicio.name, 'Corte de pelo');
      expect(servicio.price, 15.0);
      expect(servicio.duration, 30);
      expect(servicio.description, 'Corte clásico');
      expect(servicio.imageUrl, 'https://ejemplo.com/imagen.jpg');
    });

    test('acepta price como String y lo convierte a double', () {
      final map = {
        'id': 'servicio_1',
        'name': 'Barba',
        'price': '12.50', // viene como String desde Firestore
        'duration': 20,
        'description': 'Arreglo de barba',
      };

      final servicio = ModeloServicio.fromMap(map);
      expect(servicio.price, 12.50);
    });

    test('acepta duration como String y lo convierte a int', () {
      final map = {
        'id': 'servicio_1',
        'name': 'Barba',
        'price': 12.0,
        'duration': '20', // viene como String desde Firestore
        'description': 'Arreglo de barba',
      };

      final servicio = ModeloServicio.fromMap(map);
      expect(servicio.duration, 20);
    });

    test('imageUrl es null si no viene en el mapa', () {
      final map = {
        'id': 'servicio_1',
        'name': 'Corte',
        'price': 15.0,
        'duration': 30,
        'description': 'Corte clásico',
        // sin image_url
      };

      final servicio = ModeloServicio.fromMap(map);
      expect(servicio.imageUrl, isNull);
    });

    test('usa valores por defecto si los campos son null', () {
      final map = {
        'id': null,
        'name': null,
        'price': null,
        'duration': null,
        'description': null,
      };

      final servicio = ModeloServicio.fromMap(map);
      expect(servicio.id, '');
      expect(servicio.name, '');
      expect(servicio.price, 0.0);
      expect(servicio.duration, 0);
      expect(servicio.description, '');
    });

    test('price inválido como String usa 0 por defecto', () {
      final map = {
        'id': 'servicio_1',
        'name': 'Corte',
        'price': 'precio_invalido',
        'duration': 30,
        'description': 'Corte clásico',
      };

      final servicio = ModeloServicio.fromMap(map);
      expect(servicio.price, 0.0);
    });
  });

  // ─── toMap ──────────────────────────────────────────────────────────────

  group('ModeloServicio.toMap()', () {
    test('serializa correctamente todos los campos', () {
      final servicio = servicioBase(imageUrl: 'https://ejemplo.com/img.jpg');
      final map = servicio.toMap();

      expect(map['name'], 'Corte de pelo');
      expect(map['price'], 15.0);
      expect(map['duration'], 30);
      expect(map['description'], 'Corte clásico');
      expect(map['image_url'], 'https://ejemplo.com/img.jpg');
    });

    test('toMap no incluye el id (lo gestiona Firestore)', () {
      final servicio = servicioBase(id: 'servicio_123');
      expect(servicio.toMap().containsKey('id'), isFalse);
    });

    test('toMap no incluye image_url si es null', () {
      final servicio = servicioBase(imageUrl: null);
      expect(servicio.toMap().containsKey('image_url'), isFalse);
    });

    test('toMap incluye image_url si tiene valor', () {
      final servicio = servicioBase(imageUrl: 'https://ejemplo.com/img.jpg');
      expect(servicio.toMap().containsKey('image_url'), isTrue);
    });
  });

  // ─── copyWith ───────────────────────────────────────────────────────────

  group('ModeloServicio.copyWith()', () {
    test('sin argumentos devuelve una copia idéntica', () {
      final original = servicioBase();
      final copia = original.copyWith();

      expect(copia.id, original.id);
      expect(copia.name, original.name);
      expect(copia.price, original.price);
      expect(copia.duration, original.duration);
      expect(copia.description, original.description);
      expect(copia.imageUrl, original.imageUrl);
    });

    test('cambia solo el precio', () {
      final original = servicioBase(price: 15.0);
      final modificado = original.copyWith(price: 20.0);

      expect(modificado.price, 20.0);
      expect(modificado.name, original.name);
      expect(modificado.duration, original.duration);
    });

    test('cambia solo la duración', () {
      final original = servicioBase(duration: 30);
      final modificado = original.copyWith(duration: 45);

      expect(modificado.duration, 45);
      expect(modificado.price, original.price);
    });

    test('cambia solo el nombre', () {
      final original = servicioBase(name: 'Corte de pelo');
      final modificado = original.copyWith(name: 'Corte + Barba');

      expect(modificado.name, 'Corte + Barba');
      expect(modificado.price, original.price);
      expect(modificado.id, original.id);
    });

    test('añade imageUrl a un servicio que no la tenía', () {
      final original = servicioBase(imageUrl: null);
      final modificado = original.copyWith(
        imageUrl: 'https://ejemplo.com/img.jpg',
      );

      expect(modificado.imageUrl, 'https://ejemplo.com/img.jpg');
      expect(modificado.name, original.name);
    });
  });
}
