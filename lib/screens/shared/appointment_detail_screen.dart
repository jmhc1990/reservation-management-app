import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointments.dart';
import '../../models/staff.dart';
import '../../models/services.dart';
import '../../models/user.dart';
import '../../services/appointment_service.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final ModeloCita cita;
  final ModeloStaff? staff;
  final ModeloServicio? service;
  final ModeloUsuario? client;
  final bool isAdmin;

  const AppointmentDetailScreen({
    super.key,
    required this.cita,
    this.staff,
    this.service,
    this.client,
    this.isAdmin = false,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _appointmentService = AppointmentService();
  late EstadoCita _currentStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.cita.status;
  }

  String _statusLabel(EstadoCita status) {
    switch (status) {
      case EstadoCita.pending:
        return 'Pendiente';
      case EstadoCita.confirmed:
        return 'Confirmada';
      case EstadoCita.cancelled:
        return 'Cancelada';
      case EstadoCita.completed:
        return 'Completada';
      case EstadoCita.noShow:
        return 'No asistió';
    }
  }

  Color _statusColor(EstadoCita status) {
    switch (status) {
      case EstadoCita.pending:
        return AppColors.pending;
      case EstadoCita.confirmed:
        return AppColors.confirmation;
      case EstadoCita.cancelled:
        return AppColors.cancel;
      case EstadoCita.completed:
        return AppColors.gold;
      case EstadoCita.noShow:
        return Colors.grey;
    }
  }

  Future<void> _handleStatusChange(EstadoCita newStatus) async {
    if (newStatus == _currentStatus) return;

    setState(() => _isUpdating = true);
    try {
      await _appointmentService.updateStatus(
        appointmentId: widget.cita.id,
        newStatus: newStatus,
      );
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado actualizado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar cita'),
        content: const Text('¿Estás seguro de que quieres eliminar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.cancel)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _appointmentService.deleteAppointment(widget.cita.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita eliminada correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cita = widget.cita;
    final fecha =
        '${cita.startTime.day}/${cita.startTime.month}/${cita.startTime.year}';
    final hora =
        '${cita.startTime.hour.toString().padLeft(2, '0')}:${cita.startTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la cita'),
        actions: [
          if (widget.isAdmin)
          IconButton(
            onPressed: _handleDelete,
            icon: const Icon(Icons.delete, color: AppColors.cancel),
            tooltip: 'Eliminar cita',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // Servicio
          _InfoTile(
            icon: Icons.cut,
            label: 'Servicio',
            value: widget.service?.name ?? 'Servicio no disponible',
          ),
          const Divider(),

          // Cliente
          _InfoTile(
            icon: Icons.person,
            label: 'Cliente',
            value: widget.client?.name ?? 'Cliente no disponible',
          ),
          const Divider(),

          // Trabajador
          _InfoTile(
            icon: Icons.manage_accounts,
            label: 'Trabajador',
            value: widget.staff?.name ?? 'Trabajador no disponible',
          ),
          const Divider(),

          // Fecha
          _InfoTile(
            icon: Icons.calendar_today,
            label: 'Fecha',
            value: fecha,
          ),
          const Divider(),

          // Hora
          _InfoTile(
            icon: Icons.access_time,
            label: 'Hora',
            value: hora,
          ),
          const Divider(),

          // Duración
          _InfoTile(
            icon: Icons.timer,
            label: 'Duración',
            value: '${cita.duration} min',
          ),
          const Divider(),

          // Precio
          if (widget.service != null) ...[
            _InfoTile(
              icon: Icons.euro,
              label: 'Precio',
              value: '${widget.service!.price}€',
            ),
            const Divider(),
          ],

          // Estado actual
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.gold, size: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado actual',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(_currentStatus)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _statusColor(_currentStatus)
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        _statusLabel(_currentStatus),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(_currentStatus),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),

          // Cambiar estado
          const SizedBox(height: 16),
          const Text(
            'Cambiar estado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (_isUpdating)
            const Center(child: CircularProgressIndicator())
          else
            ...EstadoCita.values.map((status) {
              final isSelected = status == _currentStatus;
              final color = _statusColor(status);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _handleStatusChange(status),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                        isSelected ? color.withValues(alpha: 0.15) : null,
                    side: BorderSide(
                      color: isSelected ? color : color.withValues(alpha: 0.6),
                      width: isSelected ? 2 : 1,
                    ),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      color: color,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
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
                style: TextStyle(
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
        ],
      ),
    );
  }
}