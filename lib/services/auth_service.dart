import 'package:firebase_auth/firebase_auth.dart';
 
// resultado de una operación de autenticación.
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;
 
  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}
 
// servicio que encapsula toda la lógica de Firebase Authentication.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
 
  // emite el user actual cada vez que cambia el estado de sesión.
  Stream<User?> get authStateChanges => _auth.authStateChanges();
 
  // devuelve el usuario actualmente autenticado (o null).
  User? get currentUser => _auth.currentUser;
 
  // crea una cuenta nueva con email y contraseña.
  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
 
      // actualiza el nombre de usuario si se proporcionó
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
        await credential.user?.reload();
      }
 
      return AuthResult(success: true, user: _auth.currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _parseFirebaseError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Error inesperado. Inténtalo de nuevo.',
      );
    }
  }
 
  // inicia sesión con email y contraseña.
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult(success: true, user: credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _parseFirebaseError(e));
    } catch (e) {
      return AuthResult(
        success: false,
        errorMessage: 'Error inesperado. Inténtalo de nuevo.',
      );
    }
  }
 
  // cierra la sesión del usuario actual
  Future<void> logout() async {
    await _auth.signOut();
  }
 
  // traduce los códigos de error de Firebase a mensajes en español.
  String _parseFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      // Registro
      case 'email-already-in-use':
        return 'Este correo ya está en uso. Prueba con otro.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'weak-password':
        return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      case 'operation-not-allowed':
        return 'Registro con email/contraseña no habilitado.';
 
      // login
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
 
      // genérico
      case 'network-request-failed':
        return 'Sin conexión a internet. Verifica tu red.';
      default:
        return e.message ?? 'Ha ocurrido un error desconocido.';
    }
  }
}
