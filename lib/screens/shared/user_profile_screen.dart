import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../widgets/role_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final ModeloUsuario user;
  final bool isAdmin;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isAdmin = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _userService = UserService();

  Future<void> _showEditDialog({
    required String label,
    required String currentValue,
    required Future<void> Function(String) onSave,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: currentValue);
    final screenContext = context;

    try {
      await showDialog(
        context: screenContext,
        builder: (dialogContext) => AlertDialog(
          title: Text('Editar $label'),
          content: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final value = controller.text.trim();
                if (value.isEmpty) {
                  ScaffoldMessenger.of(screenContext).showSnackBar(
                    SnackBar(content: Text('$label no puede estar vacío')),
                  );
                  return;
                }
                try {
                  await onSave(value);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext); // ← cierra el dialog
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text('$label actualizado correctamente')),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(screenContext).showSnackBar(
                      SnackBar(content: Text('Error al actualizar: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: const Text('Guardar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } finally {
        WidgetsBinding.instance.addPostFrameCallback((_){
          controller.dispose(); // ← siempre se ejecuta, incluso al cancelar
        });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: StreamBuilder<ModeloUsuario?>(
        stream: _userService.streamUserById(widget.user.uid),
        builder: (context, snapshot) {
          final user = snapshot.data ?? widget.user;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              // Nombre
              _EditableInfoTile(
                icon: Icons.person,
                label: 'Nombre',
                value: user.name,
                onTap: () => _showEditDialog(
                  label: 'Nombre',
                  currentValue: user.name,
                  onSave: (value) => _userService.updateUser(
                    uid: user.uid,
                    name: value,
                  ),
                ),
              ),
              const Divider(),

              // Email
              if(widget.isAdmin) _EditableInfoTile(
                icon: Icons.email, 
                label: 'Email', 
                value: user.email, 
                onTap: () => _showEditDialog(
                  label: 'Email',
                  currentValue: user.email,
                  onSave: (value) => _userService.updateUser(
                    uid: user.uid,
                    email: value,
                  ),
                ),
              )
              else _InfoTile(
                icon: Icons.email,
                label: 'Email',
                value: user.email,
                ),
              const Divider(),

              // Teléfono
              _EditableInfoTile(
                icon: Icons.phone,
                label: 'Teléfono',
                value: user.phone,
                onTap: () => _showEditDialog(
                  label: 'Teléfono',
                  currentValue: user.phone,
                  keyboardType: TextInputType.phone,
                  onSave: (value) => _userService.updateUser(
                    uid: user.uid,
                    phone: value,
                  ),
                ),
              ),
              const Divider(),

              // Rol — solo admin
              if (widget.isAdmin) ...[
                _EditableInfoTile(
                  icon: Icons.badge,
                  label: 'Rol',
                  value: user.role == RolUsuario.staff && user.specialization != null
                      ? '${RoleDialog.roleName(user.role)} · ${RoleDialog.specializationLabel(user.specialization!)}'
                      : RoleDialog.roleName(user.role),
                  onTap: () => RoleDialog.show(context, user),
                ),
                const Divider(),

                // Sellos para el siguiente descuento
                _InfoTile(
                  icon: Icons.star_half,
                  label: 'Sellos para el siguiente descuento',
                  value: '${user.stampsSinceLastReward}',
                ),
                const Divider(),
              ],

              // Sellos totales — ambos roles
              _InfoTile(
                icon: Icons.star,
                label: 'Sellos de fidelización totales acumulados',
                value: '${user.loyaltyStamps}',
              ),
              const Divider(),

              // Descuento pendiente — solo admin
              if (widget.isAdmin && user.pendingDiscount != null) ...[
                _InfoTile(
                  icon: Icons.local_offer,
                  label: 'Descuento pendiente',
                  value: user.pendingDiscount!['type'] == '20_percent'
                      ? '20% de descuento'
                      : 'Servicio gratuito',
                ),
                const Divider(),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EditableInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _EditableInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style:  TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.edit_outlined, 
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), 
              size: 18
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}