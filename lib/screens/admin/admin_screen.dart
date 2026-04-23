import 'package:flutter/material.dart';
import '../services/services_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de administración'),
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

              // PENDIENTE IMPLEMENTAR

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestión de usuarios próximamente')),
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

              // PENDIENTE IMPLEMENTAR
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestión de vacaciones próximamente')),
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
        leading: Icon(icon, size: 36, color: const Color(0xFFD4AF37)),
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