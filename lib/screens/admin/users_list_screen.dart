import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../models/staff.dart';
import '../../services/user_service.dart';

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
      return 'Staff · ${_specializationLabel(user.specialization!)}';
    }
    return _roleName(user.role);
  }
  
  String _roleName(RolUsuario role) {
    switch (role) {
      case RolUsuario.admin:
        return 'Admin';
      case RolUsuario.staff:
        return 'Staff';
      case RolUsuario.client:
        return 'Cliente';
    }
  }

  String _specializationLabel(Specialization specialization) {
    switch (specialization) {
      case Specialization.barber:
        return 'Barbero';
      case Specialization.stylist:
        return 'Estilista';
    }
  }

  Future<void> _showRoleDialog(BuildContext context) async {
    RolUsuario selectedRole = user.role;
    Specialization? selectedSpecialization = user.specialization;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Cambiar rol — ${user.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Rol:'),
                const SizedBox(height: 8),

                // Selector de rol
                DropdownButton<RolUsuario>(
                  value: selectedRole,
                  isExpanded: true,
                  items: RolUsuario.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(_roleName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                        // Limpia especialización si no es staff
                        if (value != RolUsuario.staff) {
                          selectedSpecialization = null;
                        }
                      });
                    }
                  },
                ),

                // Selector de especialización — solo si es staff
                if (selectedRole == RolUsuario.staff) ...[
                  const SizedBox(height: 16),
                  const Text('Especialización:'),
                  const SizedBox(height: 8),
                  DropdownButton<Specialization>(
                    value: selectedSpecialization,
                    isExpanded: true,
                    hint: const Text('Seleccionar especialización'),
                    items: Specialization.values.map((specialization) {
                      return DropdownMenuItem(
                        value: specialization,
                        child: Text(
                          _specializationLabel(specialization),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() => selectedSpecialization = value);
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validar especialización si es staff
                  if (selectedRole == RolUsuario.staff &&
                      selectedSpecialization == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecciona una especialización para staff'),
                      ),
                    );
                    return;
                  }

                  try {
                    await userService.updateRole(
                      uid: user.uid,
                      newRole: selectedRole,
                      specialization: selectedSpecialization,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Rol actualizado correctamente')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar: $e')),
                      );
                    }
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
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
              onPressed: () => _showRoleDialog(context),
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Cambiar rol',
            ),
          ],
        ),
      ),
    );
  }
}