import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointments.dart';
import '../../models/services.dart';
import '../../models/staff.dart';
import '../../services/appointment_service.dart';
import '../../services/catalog_service.dart';
import '../../services/staff_service.dart';
import 'reservation_canceled_screen.dart';

// Sección embebida en HomeScreen que lista las próximas citas como tarjetas compactas
class MyAppointmentsSection extends StatefulWidget {
  const MyAppointmentsSection({super.key});

  @override
  State<MyAppointmentsSection> createState() => _MyAppointmentsSectionState();
}

class _MyAppointmentsSectionState extends State<MyAppointmentsSection> {
  final _appointmentService = AppointmentService();
  final _staffService = StaffService();
  final _catalogService = CatalogService();

  // mapas {id -> objeto} para resolver el nombre del barbero/servicio de cada
  // cita sin volver a consultar Firestore en cada tarjeta.
  Map<String, ModeloStaff> _staffById = {};
  Map<String, ModeloServicio> _serviceById = {};

  bool _isLoadingCatalog = true;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    try {
      final results = await Future.wait([
        _staffService.getStaff(),
        _catalogService.getServices(),
      ]);
      final staff = results[0] as List<ModeloStaff>;
      final services = results[1] as List<ModeloServicio>;
      if (!mounted) return;
      setState(() {
        _staffById = {for (final s in staff) s.id: s};
        _serviceById = {for (final s in services) s.id: s};
        _isLoadingCatalog = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCatalog = false);
    }
  }

  Future<bool> _confirmCancel() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: const Text(
          '¿Seguro que quieres cancelar esta reserva? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancelar cita',
              style: TextStyle(color: AppColors.cancel),
            ),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<bool> _doCancel(ModeloCita cita) async {
    try {
      await _appointmentService.cancelAppointment(
        appointmentId: cita.id,
        startTime: cita.startTime,
      );
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada correctamente')),
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se pudo cancelar la cita'),
          content: Text(e.toString().replaceAll('Exception: ', '')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
      return false;
    }
  }

  void _showDetailDialog(ModeloCita cita) {
    final staff = _staffById[cita.staffId];
    final service = _serviceById[cita.serviceId];
    final dateLabel = DateFormat(
      "EEEE d 'de' MMMM 'de' y",
      'es_ES',
    ).format(cita.startTime);
    final timeLabel = DateFormat('HH:mm').format(cita.startTime);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        // Estado local del diálogo para mostrar el spinner durante la cancelación
        bool cancelling = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.gold, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          service?.name ?? 'Servicio no disponible',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(cita.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    Icons.person,
                    staff?.name ?? 'Barbero no disponible',
                  ),
                  const SizedBox(height: 8),
                  _infoRow(Icons.calendar_today, _capitalize(dateLabel)),
                  const SizedBox(height: 8),
                  _infoRow(
                    Icons.access_time,
                    '$timeLabel · ${cita.duration} min'
                    '${service != null ? ' · ${service.price}€' : ''}',
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: cancelling
                              ? null
                              : () => Navigator.pop(dialogCtx),
                          child: const Text('Cerrar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (cita.status != EstadoCita.cancelled)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: cancelling
                                ? null
                                : () async {
                                    if (!await _confirmCancel()) return;
                                    setDialogState(() => cancelling = true);
                                    final ok = await _doCancel(cita);
                                    if (!mounted || !dialogCtx.mounted) return;
                                    if (ok) {
                                      // 1. Cerramos primero el cuadro flotante
                                      Navigator.pop(dialogCtx);

                                      // 2. Saltamos a tu pantalla de cancelación con las variables correctas
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ReservaCancelada(
                                                barbero:
                                                    staff?.name ?? 'Barbero',
                                                servicio:
                                                    service?.name ?? 'Servicio',
                                                fecha: dateLabel,
                                                hora: timeLabel,
                                              ),
                                        ),
                                      );
                                    } else {
                                      setDialogState(() => cancelling = false);
                                    }
                                  },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cancel,
                              side: const BorderSide(color: AppColors.cancel),
                            ),
                            icon: cancelling
                                ? const SizedBox(
                                    height: 14,
                                    width: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.cancel,
                                    ),
                                  )
                                : const Icon(Icons.cancel_outlined, size: 16),
                            label: Text(
                              cancelling ? 'Cancelando...' : 'Cancelar',
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isLoadingCatalog) return const SizedBox.shrink();

    return StreamBuilder<List<ModeloCita>>(
      stream: _appointmentService.streamClientAppointments(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return const SizedBox.shrink();
        }

        final now = DateTime.now();
        final upcoming =
            (snapshot.data ?? [])
                .where((c) => c.startTime.isAfter(now))
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

        if (upcoming.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2),
              child: Text(
                'Tus próximas citas',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            ...upcoming.map(_buildAppointmentCard),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCard(ModeloCita cita) {
    final service = _serviceById[cita.serviceId];
    // formato corto en español: "jue 7 may · 16:30"
    final shortLabel = DateFormat(
      "EEE d MMM · HH:mm",
      'es_ES',
    ).format(cita.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(cita),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service?.name ?? 'Servicio',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(cita.status),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _capitalize(shortLabel),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.gold, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildStatusBadge(EstadoCita status) {
    final (label, color) = switch (status) {
      EstadoCita.pending => ('Pendiente', AppColors.pending),
      EstadoCita.confirmed => ('Confirmada', AppColors.confirmation),
      EstadoCita.cancelled => ('Cancelada', AppColors.cancel),
      EstadoCita.completed => ('Completada', AppColors.gold),
      EstadoCita.noShow => ('No asistió', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
