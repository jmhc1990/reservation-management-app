import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/staff.dart';
import '../../models/services.dart';
import '../../models/appointments.dart';
import '../../services/staff_service.dart';
import '../../services/catalog_service.dart';
import '../../services/appointment_service.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _staffService = StaffService();
  final _catalogService = CatalogService();
  final _appointmentService = AppointmentService();

  int _currentStep = 0;

  // selecciones del usuario
  ModeloStaff? _selectedStaff;
  ModeloServicio? _selectedService;
  DateTime? _selectedDate;
  DateTime? _selectedSlot;

  // datos cargados de Firestore
  List<ModeloStaff> _staffList = [];
  List<ModeloServicio> _serviceList = [];
  List<DateTime> _availableSlots = [];

  bool _isLoading = false;
  bool _isLoadingSlots = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  // carga de datos

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final staff = await _staffService.getStaff();
      setState(() {
        // Solo mostramos staff activo
        _staffList = staff.where((s) => s.isActive).toList();
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadServices() async {
    if (_selectedStaff == null) return;
    setState(() => _isLoading = true);
    try {
      final services = await _catalogService.getServices();
      setState(() {
        // se filtra solo los servicios que ofrece el barbero seleccionado
        _serviceList = services
            .where((s) => _selectedStaff!.serviceIds.contains(s.id))
            .toList();
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedStaff == null || _selectedService == null || _selectedDate == null) return;
    setState(() {
      _isLoadingSlots = true;
      _availableSlots = [];
    });
    try {
      // obtenemos las citas ya existentes del barbero en ese día
      final existing = await _appointmentService.getAppointmentsByStaffAndDate(
        staffId: _selectedStaff!.id,
        date: _selectedDate!,
      );
      setState(() => _availableSlots = _generateSlots(existing));
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoadingSlots = false);
    }
  }

  // genera slots libres basándose en los horarios del barbero y las citas existentes
  List<DateTime> _generateSlots(List<ModeloCita> existing) {
    const dias = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final dia = dias[_selectedDate!.weekday - 1];
    final tramos = _selectedStaff!.workingHours[dia];

    // si no trabaja ese día, no hay slots
    if (tramos == null || tramos.isEmpty) return [];

    final duration = _selectedService!.duration;
    final slots = <DateTime>[];

    for (final tramo in tramos) {
      final startParts = tramo.startHour.split(':');
      final endParts = tramo.endHour.split(':');

      var current = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        int.parse(startParts[0]), int.parse(startParts[1]),
      );
      final end = DateTime(
        _selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        int.parse(endParts[0]), int.parse(endParts[1]),
      );

      while (current.add(Duration(minutes: duration)).compareTo(end) <= 0) {
        final slotEnd = current.add(Duration(minutes: duration));

        // comprobamos si el slot solapa con alguna cita existente
        final conflict = existing.any((a) =>
          current.isBefore(a.startTime.add(Duration(minutes: a.duration))) &&
          a.startTime.isBefore(slotEnd),
        );

        if (!conflict) slots.add(current);
        current = current.add(Duration(minutes: duration));
      }
    }

    return slots;
  }

  // navegación entre pasos

  void _nextStep() {
    setState(() {
      _currentStep++;
      _errorMessage = null;
    });
    if (_currentStep == 1) _loadServices();
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
      _errorMessage = null;
    });
  }

  // confirmar y guardar cita 

  Future<void> _handleConfirm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cita = ModeloCita(
        id: '',
        clientId: user.uid,
        staffId: _selectedStaff!.id,
        serviceId: _selectedService!.id,
        startTime: _selectedSlot!,
        duration: _selectedService!.duration,
        status: EstadoCita.confirmed,
      );

      await _appointmentService.createAppointment(cita);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cita reservada correctamente!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // UI principal

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar cita')),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildCurrentStep(),
          ),
          if (_errorMessage != null) _buildErrorBanner(),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // indicador de pasos

  Widget _buildStepIndicator() {
    final steps = ['Barbero', 'Servicio', 'Horario', 'Confirmar'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: isDone || isActive
                            ? const Color(0xFFD4AF37)
                            : Colors.grey.shade300,
                        child: isDone
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive ? const Color(0xFFD4AF37) : Colors.grey,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < steps.length - 1)
                  Expanded(
                    child: Divider(
                      color: i < _currentStep
                          ? const Color(0xFFD4AF37)
                          : Colors.grey.shade300,
                      thickness: 2,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0: return _buildStaffStep();
      case 1: return _buildServiceStep();
      case 2: return _buildScheduleStep();
      case 3: return _buildConfirmStep();
      default: return const SizedBox.shrink();
    }
  }

  // paso 1: seleccionar barbero

  Widget _buildStaffStep() {
    if (_staffList.isEmpty) {
      return const Center(child: Text('No hay barberos disponibles'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _staffList.length,
      itemBuilder: (context, index) {
        final staff = _staffList[index];
        final isSelected = _selectedStaff?.id == staff.id;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              backgroundImage: staff.photoUrl != null
                  ? NetworkImage(staff.photoUrl!)
                  : null,
              child: staff.photoUrl == null
                  ? const Icon(Icons.person, color: Color(0xFFD4AF37))
                  : null,
            ),
            title: Text(staff.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(staff.specialization.name),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                : null,
            onTap: () => setState(() {
              _selectedStaff = staff;
              // resetea selecciones posteriores al cambiar barbero
              _selectedService = null;
              _selectedDate = null;
              _selectedSlot = null;
              _availableSlots = [];
            }),
          ),
        );
      },
    );
  }

  // paso 2: seleccionar servicio

  Widget _buildServiceStep() {
    if (_serviceList.isEmpty) {
      return const Center(
          child: Text('Este barbero no tiene servicios asignados'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _serviceList.length,
      itemBuilder: (context, index) {
        final service = _serviceList[index];
        final isSelected = _selectedService?.id == service.id;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
              width: 2,
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.cut, color: Color(0xFFD4AF37)),
            title: Text(service.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${service.duration} min · ${service.price}€'),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                : null,
            onTap: () => setState(() {
              _selectedService = service;
              // resetea slot al cambiar servicio
              _selectedSlot = null;
              _availableSlots = [];
            }),
          ),
        );
      },
    );
  }

  // paso 3: seleccionar fecha y slot

  Widget _buildScheduleStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Selecciona una fecha',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          CalendarDatePicker(
            initialDate: DateTime.now().add(const Duration(days: 1)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 30)),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
                _selectedSlot = null;
                _availableSlots = [];
              });
              _loadAvailableSlots();
            },
          ),
          if (_selectedDate != null) ...[
            const SizedBox(height: 16),
            const Text('Horarios disponibles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (_isLoadingSlots)
              const Center(child: CircularProgressIndicator())
            else if (_availableSlots.isEmpty)
              const Text('No hay horarios disponibles para este día')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final isSelected = _selectedSlot == slot;
                  final label =
                      '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}';
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: const Color(0xFFD4AF37),
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }

  // paso 4: confirmar reserva

  Widget _buildConfirmStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumen de tu cita',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 24),
          _buildConfirmRow(Icons.person, 'Barbero', _selectedStaff?.name ?? ''),
          _buildConfirmRow(Icons.cut, 'Servicio', _selectedService?.name ?? ''),
          _buildConfirmRow(
              Icons.euro, 'Precio', '${_selectedService?.price ?? ''}€'),
          _buildConfirmRow(Icons.timer, 'Duración',
              '${_selectedService?.duration ?? ''} min'),
          if (_selectedSlot != null)
            _buildConfirmRow(
              Icons.calendar_today,
              'Fecha y hora',
              '${_selectedSlot!.day}/${_selectedSlot!.month}/${_selectedSlot!.year} · '
                  '${_selectedSlot!.hour.toString().padLeft(2, '0')}:${_selectedSlot!.minute.toString().padLeft(2, '0')}',
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFD4AF37), size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  // banner de error

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_errorMessage!,
                style: const TextStyle(color: Colors.redAccent)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  // botones de navegación

  Widget _buildNavigationButtons() {
    // el botón de continuar solo se activa si hay selección en el paso actual
    final canContinue = switch (_currentStep) {
      0 => _selectedStaff != null,
      1 => _selectedService != null,
      2 => _selectedSlot != null,
      _ => true,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                child: const Text('Atrás'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canContinue
                  ? (_currentStep == 3 ? _handleConfirm : _nextStep)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                disabledBackgroundColor:
                    const Color(0xFFD4AF37).withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black),
                    )
                  : Text(_currentStep == 3 ? 'Confirmar cita' : 'Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}