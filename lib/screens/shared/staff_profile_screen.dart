import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/staff.dart';
import '../../models/services.dart';
import '../../services/catalog_service.dart';
import '../admin/staff_form_screen.dart';
import '../../services/staff_service.dart';

class StaffProfileScreen extends StatefulWidget {
  final ModeloStaff staff;

  const StaffProfileScreen({
    super.key,
    required this.staff,
  });

  @override
  State<StaffProfileScreen> createState() => _StaffProfileScreenState();
}

class _StaffProfileScreenState extends State<StaffProfileScreen> {
  final _catalogService = CatalogService();
  final _staffService = StaffService();
  List<ModeloServicio> _services = [];

  final Map<String, String> _dayNames = {
    'mon': 'Lunes', 'tue': 'Martes', 'wed': 'Miércoles',
    'thu': 'Jueves', 'fri': 'Viernes', 'sat': 'Sábado', 'sun': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _catalogService.getServices();
      setState(() => _services = services);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar servicios: $e')),
        );
      }
    }
  }

  String _serviceName(String serviceId) {
    final service = _services.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => ModeloServicio(
        id: serviceId,
        name: serviceId,
        price: 0,
        duration: 0,
        description: '',
      ),
    );
    return service.name;
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staff.name),
      ),
      body: StreamBuilder<ModeloStaff?>(
      stream: _staffService.streamStaffById(widget.staff.id),
      builder: (context, snapshot) {
        if(snapshot.hasError) {
          return const Center(child: Text('Error cargando trabajador'));
        }
        if(snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
      
    
      final staff = snapshot.data ?? widget.staff;

      return ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Nombre
          _InfoTile(
            icon: Icons.person,
            label: 'Nombre',
            value: staff.name,
          ),
          const Divider(),

          // Bio
          _InfoTile(
            icon: Icons.info_outline,
            label: 'Biografía',
            value: staff.bio,
          ),
          const Divider(),

          // Especialización
          _InfoTile(
            icon: Icons.work_outline,
            label: 'Especialización',
            value: staff.specialization == Specialization.barber
                ? 'Barbero'
                : 'Estilista',
          ),
          const Divider(),

          // Estado
          _InfoTile(
            icon: Icons.circle,
            label: 'Estado',
            value: staff.isActive ? 'Activo' : 'Inactivo',
            valueColor: staff.isActive ? AppColors.confirmation : AppColors.cancel,
          ),
          const Divider(),

          // Especialidades
          if (staff.specialties.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.star_outline, color: AppColors.gold, size: 24),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especialidades',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: staff.specialties.map((s) {
                          return Chip(label: Text(s));
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Servicios
          if (staff.serviceIds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cut, color: AppColors.gold, size: 24),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servicios que ofrece',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...staff.serviceIds.map((id) {
                        return Text(
                          '• ${_serviceName(id)}',
                          style: const TextStyle(fontSize: 16),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
          ],

          // Horario semanal
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.schedule, color: AppColors.gold, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario semanal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...(_dayNames.entries.map((entry) {
                        final dia = entry.key;
                        final nombre = entry.value;
                        final tramos = staff.workingHours[dia];

                        if (tramos == null || tramos.isEmpty) {
                          return Text(
                            '$nombre: Libre',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$nombre:',
                              style: const TextStyle(fontSize: 14),
                            ),
                            ...tramos.map((t) => Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                '${t.startHour} - ${t.endHour}',
                                style: const TextStyle(fontSize: 14),
                                ),
                            )),
                          ],
                        );
                      })),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Botón editar
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StaffFormScreen(staff: staff),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              'Editar trabajador',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
        );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}