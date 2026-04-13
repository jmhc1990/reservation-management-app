import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
 
/// widget raíz que escucha el estado de autenticación de Firebase
/// y redirige al usuario a la pantalla correcta de forma automática.
///
/// Usuario autenticado  -> [HomeScreen]
/// Usuario sin sesión   -> [LoginScreen]
/// Cargando             -> Pantalla de splash
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
 
  @override
  Widget build(BuildContext context) {
    final authController = context.read<AuthController>();
 
    return StreamBuilder<User?>(
      stream: authController.authStateChanges,
      builder: (context, snapshot) {
        // espera la respuesta inicial de Firebase
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
 
        // usuario autenticado 
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
 
        // sin sesión activa 
        return const LoginScreen();
      },
    );
  }
}
 
/// pantalla de carga mientras Firebase resuelve el estado inicial.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
 
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.content_cut,
              color: Color(0xFFD4AF37),
              size: 64,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: Color(0xFFD4AF37),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
