import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  //  cerrar sesión 
 
  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await _showLogoutDialog(context);
    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().logout();
      // el AuthWrapper detecta el cambio en el stream y redirige al Login.
    }
  }
 
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
 
  //  UI pendiente de la persona de diseño
 
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          // botón de cerrar sesión
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // datos del usuario autenticado disponibles para diseño
            Text('Bienvenido, ${user?.displayName ?? user?.email ?? 'Usuario'}'),
          ],
        ),
      ),
    );
  }
}
