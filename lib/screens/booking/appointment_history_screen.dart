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

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final _appointmentService = AppointmentService();
  final _staffService = StaffService();
  final _catalogService = CatalogService();

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

  String _statusLabel(EstadoCita status) {
    return switch (status) {
      EstadoCita.confirmed => 'Confirmada',
      EstadoCita.cancelled => 'Cancelada',
      EstadoCita.completed => 'Completada',
      EstadoCita.noShow => 'No asistió',
    };
  }

  Color _statusColor(EstadoCita status) {
    return switch (status) {
      EstadoCita.confirmed => AppColors.confirmation,
      EstadoCita.cancelled => AppColors.cancel,
      EstadoCita.completed => AppColors.gold,
      EstadoCita.noShow => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isLoadingCatalog) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<ModeloCita>>(
      stream: _appointmentService.streamClientAppointments(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error cargando el historial'));
        }

        final now = DateTime.now();
        final history = (snapshot.data ?? [])
            .where((c) => !c.startTime.isAfter(now))
            .toList()
          ..sort((a, b) => b.startTime.compareTo(a.startTime)); // más reciente primero

        if (history.isEmpty) {
          return const Center(child: Text('No tienes citas anteriores'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final cita = history[index];
            final service = _serviceById[cita.serviceId];
            final staff = _staffById[cita.staffId];
            final dateLabel = DateFormat("EEE d MMM · HH:mm", 'es_ES')
                .format(cita.startTime);
            final color = _statusColor(cita.status);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: color.withValues(alpha: 0.4), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                                  service?.name ?? 'Servicio no disponible',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: color.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  _statusLabel(cita.status),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _capitalize(dateLabel),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          if (staff != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              staff.name,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}