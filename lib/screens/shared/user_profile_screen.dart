import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../widgets/role_dialog.dart';

class UserProfileScreen extends StatelessWidget {
  final ModeloUsuario user;
  final bool isAdmin;

  const UserProfileScreen({
    super.key,
    required this.user,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Nombre
          _InfoTile(
            icon: Icons.person,
            label: 'Nombre',
            value: user.name,
          ),
          const Divider(),

          // Email
          _InfoTile(
            icon: Icons.email,
            label: 'Email',
            value: user.email,
          ),
          const Divider(),

          // Teléfono
          _InfoTile(
            icon: Icons.phone,
            label: 'Teléfono',
            value: user.phone,
          ),
          const Divider(),

          // Rol — solo admin
          if (isAdmin) ...[
            _InfoTile(
              icon: Icons.badge,
              label: 'Rol',
              value: user.role == RolUsuario.staff && user.specialization != null
                  ? '${RoleDialog.roleName(user.role)} · ${RoleDialog.specializationLabel(user.specialization!)}'
                  : RoleDialog.roleName(user.role),
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

          // Sellos totales
          _InfoTile(
            icon: Icons.star,
            label: isAdmin ? 'Sellos totales acumulados' : 'Sellos totales',
            value: '${user.loyaltyStamps}',
          ),
          const Divider(),

          // Descuento pendiente — solo admin
          if (isAdmin && user.pendingDiscount != null) ...[
            _InfoTile(
              icon: Icons.local_offer,
              label: 'Descuento pendiente',
              value: user.pendingDiscount!['type'] == '20_percent'
                  ? '20% de descuento'
                  : 'Servicio gratuito',
            ),
            const Divider(),
          ],

          // Botón editar rol — solo admin
          if (isAdmin) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => RoleDialog.show(context, user),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Editar rol',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ],
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubtitle,
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
        ],
      ),
    );
  }
}