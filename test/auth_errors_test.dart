import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Replicamos _parseFirebaseError aquí para testearla de forma aislada.
// Es la misma lógica que está en AuthService.
String parseFirebaseError(FirebaseAuthException e) {
  switch (e.code) {
    case 'email-already-in-use':
      return 'Este correo ya está en uso. Prueba con otro.';
    case 'invalid-email':
      return 'El formato del correo no es válido.';
    case 'weak-password':
      return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
    case 'operation-not-allowed':
      return 'Registro con email/contraseña no habilitado.';
    case 'user-not-found':
      return 'No existe ninguna cuenta con ese correo.';
    case 'wrong-password':
      return 'Contraseña incorrecta.';
    case 'user-disabled':
      return 'Esta cuenta ha sido deshabilitada.';
    case 'too-many-requests':
      return 'Demasiados intentos fallidos. Espera un momento e inténtalo de nuevo.';
    case 'invalid-credential':
      return 'Credenciales incorrectas. Revisa tu email y contraseña.';
    case 'network-request-failed':
      return 'Sin conexión a internet. Verifica tu red.';
    default:
      return e.message ?? 'Ha ocurrido un error desconocido.';
  }
}

// Helper para crear excepciones de Firebase fácilmente en los tests
FirebaseAuthException firebaseError(String code, {String? message}) {
  return FirebaseAuthException(code: code, message: message);
}

void main() {
  group('Mensajes de error de autenticación en español', () {
    // Errores de registro
    group('Errores de registro', () {
      test('email-already-in-use devuelve mensaje correcto', () {
        final result = parseFirebaseError(
          firebaseError('email-already-in-use'),
        );
        expect(result, 'Este correo ya está en uso. Prueba con otro.');
      });

      test('invalid-email devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('invalid-email'));
        expect(result, 'El formato del correo no es válido.');
      });

      test('weak-password devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('weak-password'));
        expect(
          result,
          'La contraseña es demasiado débil (mínimo 6 caracteres).',
        );
      });
    });

    // Errores de login
    group('Errores de login', () {
      test('user-not-found devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('user-not-found'));
        expect(result, 'No existe ninguna cuenta con ese correo.');
      });

      test('wrong-password devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('wrong-password'));
        expect(result, 'Contraseña incorrecta.');
      });

      test('too-many-requests devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('too-many-requests'));
        expect(
          result,
          'Demasiados intentos fallidos. Espera un momento e inténtalo de nuevo.',
        );
      });

      test('invalid-credential devuelve mensaje correcto', () {
        final result = parseFirebaseError(firebaseError('invalid-credential'));
        expect(
          result,
          'Credenciales incorrectas. Revisa tu email y contraseña.',
        );
      });
    });

    // Errores genéricos
    group('Errores genéricos', () {
      test('network-request-failed devuelve mensaje correcto', () {
        final result = parseFirebaseError(
          firebaseError('network-request-failed'),
        );
        expect(result, 'Sin conexión a internet. Verifica tu red.');
      });

      test('código desconocido usa el mensaje de Firebase si existe', () {
        final result = parseFirebaseError(
          firebaseError('unknown-code', message: 'Algo fue mal'),
        );
        expect(result, 'Algo fue mal');
      });

      test('código desconocido sin mensaje usa mensaje genérico', () {
        final result = parseFirebaseError(firebaseError('unknown-code'));
        expect(result, 'Ha ocurrido un error desconocido.');
      });
    });
  });
}
