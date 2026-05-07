import 'package:flutter/material.dart';
import 'package:style_sync/screens/booking/my_appointments_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/appointments.dart';
import '../../models/staff.dart';
import '../../models/services.dart';
import '../../models/user.dart';
import '../../services/appointment_service.dart';
import '../../services/staff_service.dart';
import '../../services/catalog_service.dart';
import '../../services/user_service.dart';
import '../booking/booking_screen.dart';
import '../shared/appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _appointmentService = AppointmentService();
  final _staffService = StaffService();
  final _catalogService = CatalogService();
  final _userService = UserService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // Catálogos cargados una sola vez
  List<ModeloStaff> _staffList = [];
  Map<String, ModeloServicio> _serviceById = {};
  Map<String, ModeloUsuario> _userById = {};
  bool _isLoadingCatalog = true;

  // Citas del día seleccionado por trabajador
  Map<String, List<ModeloCita>> _citasByStaff = {};
  bool _isLoadingCitas = false;

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
        _userService.getUsers(),
      ]);

      final staff = results[0] as List<ModeloStaff>;
      final services = results[1] as List<ModeloServicio>;
      final users = results[2] as List<ModeloUsuario>;

      setState(() {
        _staffList = staff;
        _serviceById = {for (final s in services) s.id: s};
        _userById = {for (final u in users) u.uid: u};
        _isLoadingCatalog = false;
      });

      await _loadCitasDelDia();
    } catch (e) {
      setState(() => _isLoadingCatalog = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando datos: $e')),
        );
      }
    }
  }

  Future<void> _loadCitasDelDia() async {
    setState(() {
      _isLoadingCitas = true;
      _citasByStaff = {};
    });

    try {
      final Map<String, List<ModeloCita>> result = {};

      await Future.wait(_staffList.map((staff) async {
        final citas = await _appointmentService.getAllAppointmentsByStaffAndDate(
          staffId: staff.id,
          date: _selectedDay,
        );
        if (citas.isNotEmpty) {
          result[staff.id] = citas;
        }
      }));

      setState(() => _citasByStaff = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando citas: $e')),
        );
      }
    } finally {
      setState(() => _isLoadingCitas = false);
    }
  }

  String _statusLabel(EstadoCita status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return _isLoadingCatalog
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Text(
                    'Citas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Calendario
              TableCalendar(
                locale: 'es_ES',
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mes',
                },
                startingDayOfWeek: StartingDayOfWeek.monday,
                firstDay: DateTime(DateTime.now().year - 1),
                lastDay: DateTime(DateTime.now().year + 2),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _loadCitasDelDia();
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                    color: Colors.transparent,
                  ),
                  todayTextStyle: const TextStyle(color: Colors.white),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingScreen(isAdmin: true),),
                    );
                    _loadCitasDelDia(); // recargar al volver
                  },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Nueva cita', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),

              // Lista de citas
              Expanded(
                child: _isLoadingCitas
                    ? const Center(child: CircularProgressIndicator())
                    : _citasByStaff.isEmpty
                        ? Center(
                            child: Text(
                              'No hay citas el ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(10),
                            children: _staffList
                                .where((s) => _citasByStaff.containsKey(s.id))
                                .map((staff) {
                              final citas = _citasByStaff[staff.id]!;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cabecera del trabajador
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.manage_accounts,
                                            color: AppColors.gold, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          staff.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tarjetas de citas
                                  ...citas.map((cita) {
                                    final service =
                                        _serviceById[cita.serviceId];
                                    final user = _userById[cita.clientId];
                                    final hora =
                                        '${cita.startTime.hour.toString().padLeft(2, '0')}:${cita.startTime.minute.toString().padLeft(2, '0')}';
                                    final color = _statusColor(cita.status);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                        side: BorderSide(
                                          color:
                                              color.withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AppointmentDetailScreen(
                                                cita: cita,
                                                staff: _staffList.firstWhere((s) => s.id == cita.staffId),
                                                service: _serviceById[cita.serviceId], 
                                                client: _userById[cita.clientId],
                                                isAdmin: true,
                                              ),
                                            ),
                                          );
                                          _loadCitasDelDia();   // Recargar al volver para reflejar cambios de estado
                                        },
                                        leading: Text(
                                          hora,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.gold,
                                          ),
                                        ),
                                        title: Text(
                                          service?.name ??
                                              'Servicio no disponible',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          user?.name ??
                                              'Cliente no disponible',
                                          style: const TextStyle(
                                              fontSize: 12),
                                        ),
                                        trailing: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color:
                                                  color.withValues(alpha: 0.5),
                                            ),
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
                                      ),
                                    );
                                  }),

                                  const Divider(),
                                ],
                              );
                            }).toList(),
                          ),
              ),
            ],
          );
  }
}