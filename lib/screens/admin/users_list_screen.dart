import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../shared/user_profile_screen.dart';
import '../../widgets/role_dialog.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      body: StreamBuilder<List<ModeloUsuario>>(
        stream: _userService.streamUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando usuarios'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _UserCard(
                user: user,
                userService: _userService,
              );
            },
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final ModeloUsuario user;
  final UserService userService;

  const _UserCard({
    required this.user,
    required this.userService,
  });

  // Icono según rol
  IconData _roleIcon(RolUsuario role) {
    switch (role) {
      case RolUsuario.admin:
        return Icons.admin_panel_settings;
      case RolUsuario.staff:
        return Icons.content_cut;
      case RolUsuario.client:
        return Icons.person;
    }
  }

  // Texto del rol y especialización
  String _roleLabel(ModeloUsuario user) {
    if (user.role == RolUsuario.staff && user.specialization != null) {
      return 'Staff · ${RoleDialog.specializationLabel(user.specialization!)}';
    }
    return RoleDialog.roleName(user.role);
  }
  

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => UserProfileScreen(
                user: user, 
                isAdmin: true,
              ),
            ),
          );
        },
        leading: Icon(_roleIcon(user.role), size: 36),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _roleLabel(user),
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => RoleDialog.show(context, user),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Cambiar rol',
            ),
          ],
        ),
      ),
    );
  }
}