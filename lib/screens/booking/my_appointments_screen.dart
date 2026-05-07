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

// pantalla "Mis reservas": lista las citas del cliente y permite cancelarlas.
class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final _appointmentService = AppointmentService();
  final _staffService = StaffService();
  final _catalogService = CatalogService();

  // mapas {id -> objeto} para resolver el nombre del barbero/servicio de cada
  // cita sin volver a consultar Firestore en cada tarjeta.
  Map<String, ModeloStaff> _staffById = {};
  Map<String, ModeloServicio> _serviceById = {};

  bool _isLoadingCatalog = true;
  String? _catalogError;
  String? _cancellingId; // id de la cita que se está cancelando ahora mismo

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  // carga staff y servicios una sola vez al entrar en la pantalla.
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _catalogError = e.toString().replaceAll('Exception: ', '');
        _isLoadingCatalog = false;
      });
    }
  }

  // pide confirmación y, si acepta, cambia el estado de la cita a "cancelled".
  Future<void> _handleCancel(ModeloCita cita) async {
    final confirmed = await showDialog<bool>(
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

    if (confirmed != true) return;

    setState(() => _cancellingId = cita.id);
    try {
      await _appointmentService.updateStatus(
        appointmentId: cita.id,
        newStatus: EstadoCita.cancelled,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita cancelada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.cancel,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      // encadena los estados: sin sesión → cargando → error → lista
      body: user == null
          ? const Center(child: Text('Debes iniciar sesión para ver tus reservas'))
          : _isLoadingCatalog
              ? const Center(child: CircularProgressIndicator())
              : _catalogError != null
                  ? Center(child: Text('Error: $_catalogError'))
                  : _buildAppointmentsList(user.uid),
    );
  }

  Widget _buildAppointmentsList(String clientId) {
    return StreamBuilder<List<ModeloCita>>(
      stream: _appointmentService.streamClientAppointments(clientId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error cargando reservas: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Solo mostramos las citas confirmadas que aún no han ocurrido,
        // ordenadas de la más cercana a la más lejana.
        final now = DateTime.now();
        final upcoming = (snapshot.data ?? [])
            .where((c) =>
                c.status == EstadoCita.confirmed && c.startTime.isAfter(now))
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

        if (upcoming.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: upcoming.length,
          itemBuilder: (context, index) => _buildAppointmentCard(upcoming[index]),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: AppColors.gold),
            const SizedBox(height: 16),
            const Text(
              'No tienes reservas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando reserves una cita, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(ModeloCita cita) {
    // staff/service pueden ser null si fueron eliminados después de reservar.
    final staff = _staffById[cita.staffId];
    final service = _serviceById[cita.serviceId];
    final dateLabel = DateFormat("EEEE d 'de' MMMM 'de' y", 'es_ES').format(cita.startTime);
    final timeLabel = DateFormat('HH:mm').format(cita.startTime);
    final isCancelling = _cancellingId == cita.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.gold,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service?.name ?? 'Servicio no disponible',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(cita.status),
              ],
            ),
            const SizedBox(height: 12),
            _infoRow(Icons.person, staff?.name ?? 'Barbero no disponible'),
            const SizedBox(height: 6),
            _infoRow(Icons.calendar_today, _capitalize(dateLabel)),
            const SizedBox(height: 6),
            _infoRow(
              Icons.access_time,
              '$timeLabel · ${cita.duration} min'
              '${service != null ? ' · ${service.price}€' : ''}',
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isCancelling ? null : () => _handleCancel(cita),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cancel,
                  side: const BorderSide(color: AppColors.cancel),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: isCancelling
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.cancel,
                        ),
                      )
                    : const Icon(Icons.cancel_outlined, size: 18),
                label: Text(isCancelling ? 'Cancelando...' : 'Cancelar reserva'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(EstadoCita status) {
    final (label, color) = switch (status) {
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
