import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
 
/// estados posibles de las operaciones de autenticación.
enum AuthStatus { idle, loading, success, error }
 
/// controller que gestiona el estado de las pantallas de Login y Registro.
class AuthController extends ChangeNotifier {
  final AuthService _authService;
 
  AuthController({AuthService? authService})
      : _authService = authService ?? AuthService();
 
  // estado 
 
  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
 
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _status == AuthStatus.loading;
 
  // stream de sesión para el AuthWrapper
 
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;
 
  // toggle visibilidad de contraseña 
 
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }
 
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }
 
  // registro
 
  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    String? displayName,
  }) async {
    // validación local antes de llamar a Firebase
    if (password != confirmPassword) {
      _setError('Las contraseñas no coinciden.');
      return false;
    }
    if (password.length < 6) {
      _setError('La contraseña debe tener al menos 6 caracteres.');
      return false;
    }
 
    _setLoading();
 
    final result = await _authService.register(
      email: email,
      password: password,
      displayName: displayName,
    );
 
    if (result.success) {
      _setSuccess();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Error al registrar.');
      return false;
    }
  }
 
  // login 
 
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading();
 
    final result = await _authService.login(
      email: email,
      password: password,
    );
 
    if (result.success) {
      _setSuccess();
      return true;
    } else {
      _setError(result.errorMessage ?? 'Error al iniciar sesión.');
      return false;
    }
  }
 
  // logout
 
  Future<void> logout() async {
    await _authService.logout();
    _setIdle();
  }
 
  // limpiar error manualmente 
 
  void clearError() {
    _errorMessage = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }
 
  // helpers privados
 
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }
 
  void _setSuccess() {
    _status = AuthStatus.success;
    _errorMessage = null;
    notifyListeners();
  }
 
  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }
 
  void _setIdle() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
