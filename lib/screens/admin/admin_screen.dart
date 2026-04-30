import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../services/services_list_screen.dart';
import 'staff_list_screen.dart';
import 'staff_selector_screen.dart';
import 'users_list_screen.dart';
import '../../core/theme/app_colors.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
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
    if (confirmed == true && context.mounted) {
      await context.read<AuthController>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administración'),
        actions: [
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Servicios
          _AdminMenuItem(
            icon: Icons.cut,
            title: 'Servicios',
            subtitle: 'Gestionar catálogo de servicios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServicesListScreen(isAdmin: true),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Usuarios
          _AdminMenuItem(
            icon: Icons.people,
            title: 'Usuarios',
            subtitle: 'Gestionar los usuarios',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UsersListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Staff
          _AdminMenuItem(
            icon: Icons.manage_accounts,
            title: 'Trabajadores',
            subtitle: 'Gestionar información del personal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Vacaciones
          _AdminMenuItem(
            icon: Icons.beach_access,
            title: 'Vacaciones',
            subtitle: 'Gestionar vacaciones del personal',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffSelectorScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Galeria
          _AdminMenuItem(
            icon: Icons.photo_library,
            title: 'Galería',
            subtitle: 'Gestionar imágenes de la galería',
            onTap: () {

              // PENDIENTE IMPLEMENTAR
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestión de galería próximamente')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 36, color: AppColors.gold),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}