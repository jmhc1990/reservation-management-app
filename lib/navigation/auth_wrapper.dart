import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../services/firestore_service.dart';
import '../core/theme/app_colors.dart';

/// widget raíz que escucha el estado de autenticación de Firebase
/// y redirige al usuario a la pantalla correcta de forma automática.
///
/// Usuario autenticado  -> [AdminPanelScreen] si rol admin
/// Usuario autenticado  -> [HomeScreen] si rol client/staff
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
          // lee el rol en Firestore y redirige según corresponda
          return FutureBuilder<RolUsuario>(
            future: FirestoreService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              // espera mientras se obtiene el rol
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const _SplashScreen();
              }
              final role = roleSnapshot.data ?? RolUsuario.client;
              if (role == RolUsuario.admin) return const AdminScreen();
              return const HomeScreen();
            },
          );
        }

        // sin sesión activa
        return const LoginScreen();
      },
    );
  }
}

/// pantalla de carga mientras firebase resuelve el estado inicial.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.content_cut,
              color: AppColors.gold,
              size: 64,
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(
              color: AppColors.gold,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
