import 'package:flutter/material.dart';
import '../../models/staff.dart';
import '../../services/staff_service.dart';
import 'staff_form_screen.dart';
import '../../core/theme/app_colors.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final _staffService = StaffService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trabajadores'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Añadir trabajador',
          ),
        ],
      ),
      body: StreamBuilder<List<ModeloStaff>>(
        stream: _staffService.streamStaff(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando trabajadores'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final staff = snapshot.data ?? [];

          if (staff.isEmpty) {
            return const Center(child: Text('No hay trabajadores'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: staff.length,
            itemBuilder: (context, index) {
              return _StaffCard(
                staff: staff[index],
                staffService: _staffService,
              );
            },
          );
        },
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final ModeloStaff staff;
  final StaffService staffService;

  const _StaffCard({
    required this.staff,
    required this.staffService,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar trabajador'),
        content: Text('¿Estás seguro de que quieres eliminar a "${staff.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.cancel),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await staffService.deleteStaff(staff.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trabajador eliminado')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          Icons.manage_accounts,
          size: 40,
          color: staff.isActive ? AppColors.gold : AppColors.textSubtitle,
        ),
        title: Text(staff.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staff.specialization == Specialization.barber ? 'Barbero' : 'Estilista',
              style: const TextStyle(
                fontSize: 12, 
                color: AppColors.gold, 
                fontWeight: FontWeight.bold,
              ),
            ),
            // Especialidades
            if (staff.specialties.isNotEmpty)
              Text(
                staff.specialties.join(' · '),
                style: const TextStyle(fontSize: 12),
              ),
            // Estado activo/inactivo
            Text(
              staff.isActive ? 'Activo' : 'Inactivo',
              style: TextStyle(
                fontSize: 12,
                color: staff.isActive ? AppColors.confirmation : AppColors.cancel,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle activo/inactivo
            Switch(
              value: staff.isActive,
              activeThumbColor: AppColors.gold,
              onChanged: (value) async {
                try {
                  await staffService.setStaffActive(staff.id, value);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al actualizar estado: $e')),
                    );
                  }
                }
              },
            ),
            // Editar
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffFormScreen(staff: staff),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar trabajador',
            ),
            // Eliminar
            IconButton(
              onPressed: () => _handleDelete(context),
              icon: const Icon(Icons.delete_outline, color: AppColors.cancel),
              tooltip: 'Eliminar trabajador',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}