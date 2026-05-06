import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../models/staff.dart';
import '../../services/user_service.dart';

class RoleDialog {
  static Future<void> show(BuildContext context, ModeloUsuario user) async {
    RolUsuario selectedRole = user.role;
    Specialization? selectedSpecialization = user.specialization;
    final userService = UserService();

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
                DropdownButton<RolUsuario>(
                  value: selectedRole,
                  isExpanded: true,
                  items: RolUsuario.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(roleName(role)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedRole = value;
                        if (value != RolUsuario.staff) {
                          selectedSpecialization = null;
                        }
                      });
                    }
                  },
                ),
                if (selectedRole == RolUsuario.staff) ...[
                  const SizedBox(height: 16),
                  const Text('Especialización:'),
                  const SizedBox(height: 8),
                  DropdownButton<Specialization>(
                    value: selectedSpecialization,
                    isExpanded: true,
                    hint: const Text('Seleccionar especialización'),
                    items: Specialization.values.map((spec) {
                      return DropdownMenuItem(
                        value: spec,
                        child: Text(specializationLabel(spec)),
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
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  static String roleName(RolUsuario role) {
    switch (role) {
      case RolUsuario.admin:
        return 'Admin';
      case RolUsuario.staff:
        return 'Staff';
      case RolUsuario.client:
        return 'Cliente';
    }
  }

  static String specializationLabel(Specialization spec) {
    switch (spec) {
      case Specialization.barber:
        return 'Barbero';
      case Specialization.stylist:
        return 'Estilista';
    }
  }
}