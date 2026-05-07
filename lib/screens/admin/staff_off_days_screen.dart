import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';
import '../../models/staff.dart';
import '../../models/staff_off_day.dart';
import '../../services/staff_off_day_service.dart';

class StaffOffDaysScreen extends StatefulWidget {
  final ModeloStaff staff;

  const StaffOffDaysScreen({
    super.key,
    required this.staff,
  });

  @override
  State<StaffOffDaysScreen> createState() => _StaffOffDaysScreenState();
}

class _StaffOffDaysScreenState extends State<StaffOffDaysScreen> {
  final _offDayService = StaffOffDayService();
  List<ModeloStaffOffDay> _offDays = [];
  DateTime _focusedDay = DateTime.now();
  StreamSubscription<List<ModeloStaffOffDay>>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _offDayService.streamOffDays(widget.staff.id).listen((offDays) {
      if (mounted) setState(() => _offDays = offDays);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Color _reasonColor(TipoAusencia reason) {
    switch (reason) {
      case TipoAusencia.vacation:
        return AppColors.gold;
      case TipoAusencia.sick:
        return AppColors.cancel;
      case TipoAusencia.dayOff:
        return Colors.blue;
      case TipoAusencia.training:
        return AppColors.confirmation;
    }
  }

  String _reasonLabel(TipoAusencia reason) {
    switch (reason) {
      case TipoAusencia.vacation:
        return 'Vacaciones';
      case TipoAusencia.sick:
        return 'Baja por enfermedad';
      case TipoAusencia.dayOff:
        return 'Día libre';
      case TipoAusencia.training:
        return 'Formación';
    }
  }

  TipoAusencia? _getReasonForDay(DateTime day) {
    for (final offDay in _offDays) {
      final start = DateTime(offDay.startDate.year, offDay.startDate.month, offDay.startDate.day);
      final end = DateTime(offDay.endDate.year, offDay.endDate.month, offDay.endDate.day);
      final current = DateTime(day.year, day.month, day.day);
      if (!current.isBefore(start) && !current.isAfter(end)) {
        return offDay.reason;
      }
    }
    return null;
  }

  Future<void> _showAddDialog(DateTime? initialDate) async {
    TipoAusencia selectedReason = TipoAusencia.vacation;
    DateTime? startDate = initialDate;
    DateTime? endDate = initialDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Añadir ausencia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo:'),
                const SizedBox(height: 8),
                DropdownButton<TipoAusencia>(
                  value: selectedReason,
                  isExpanded: true,
                  items: TipoAusencia.values.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _reasonColor(reason),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_reasonLabel(reason)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedReason = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Fecha inicio:'),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.gold),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                        if (endDate != null && endDate!.isBefore(startDate!)) {
                          endDate = startDate;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, color: AppColors.gold),
                  label: Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'Seleccionar',
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Fecha fin:'),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.gold),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setDialogState(() => endDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today, color: AppColors.gold),
                  label: Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'Seleccionar',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona las fechas')),
                    );
                    return;
                  }
                  try {
                    await _offDayService.addOffDay(ModeloStaffOffDay(
                      id: '',
                      staffId: widget.staff.id,
                      startDate: startDate!,
                      endDate: endDate!,
                      reason: selectedReason,
                    ));
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleDelete(ModeloStaffOffDay offDay) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar ausencia'),
        content: const Text('¿Estás seguro de que quieres eliminar esta ausencia?'),
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
        await _offDayService.deleteOffDay(offDay.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ausencia eliminada')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Ausencias — ${widget.staff.name}'),
        actions: [
          IconButton(
            onPressed: () => _showAddDialog(null),
            icon: const Icon(Icons.add),
            tooltip: 'Añadir ausencia',
          ),
        ],
      ),
      body: Column(
        children: [
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
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_focusedDay, focusedDay)) {
                setState(() => _focusedDay = focusedDay);
              }
              if (_getReasonForDay(selectedDay) == null) {
                _showAddDialog(selectedDay);
              }
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
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                final reason = _getReasonForDay(day);
                if (reason != null) {
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _reasonColor(reason).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: TextStyle(color: _reasonColor(reason)),
                      ),
                    ),
                  );
                }
                return null;
              },
              todayBuilder: (context, day, focusedDay) {
                final reason = _getReasonForDay(day);
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: reason != null
                        ? _reasonColor(reason).withValues(alpha: 0.3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: reason != null ? _reasonColor(reason) : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Leyenda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: TipoAusencia.values.map((reason) {
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _reasonColor(reason),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _reasonLabel(reason),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // Lista de ausencias
          Expanded(
            child: _offDays.isEmpty
                ? const Center(child: Text('No hay ausencias registradas'))
                : ListView.builder(
                    padding: const EdgeInsets.all(10),
                    itemCount: _offDays.length,
                    itemBuilder: (context, index) {
                      final offDay = _offDays[index];
                      return ListTile(
                        onTap: () => _showEditDialog(offDay),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _reasonColor(offDay.reason),
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(_reasonLabel(offDay.reason)),
                        subtitle: Text(
                          '${offDay.startDate.day}/${offDay.startDate.month}/${offDay.startDate.year}'
                          ' → '
                          '${offDay.endDate.day}/${offDay.endDate.month}/${offDay.endDate.year}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () => _showEditDialog(offDay),
                              tooltip: 'Editar ausencia',
                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            IconButton(
                              onPressed: () => _handleDelete(offDay),
                              tooltip: 'Eliminar ausencia',
                              icon: const Icon(Icons.delete_outline, color: AppColors.cancel),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(ModeloStaffOffDay offDay) async {
    TipoAusencia selectedReason = offDay.reason;
    DateTime? startDate = offDay.startDate;
    DateTime? endDate = offDay.endDate;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Editar ausencia'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tipo:'),
                const SizedBox(height: 8),
                DropdownButton<TipoAusencia>(
                  value: selectedReason,
                  isExpanded: true,
                  items: TipoAusencia.values.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _reasonColor(reason),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_reasonLabel(reason)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setDialogState(() => selectedReason = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Fecha inicio:'),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 2),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.gold),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        startDate = picked;
                        if (endDate != null && endDate!.isBefore(startDate!)) {
                          endDate = startDate;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.calendar_today, color: AppColors.gold),
                  label: Text(
                    startDate != null
                        ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                        : 'Seleccionar',
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Fecha fin:'),
                const SizedBox(height: 4),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate ?? startDate ?? DateTime.now(),
                      firstDate: startDate ?? DateTime.now(),
                      lastDate: DateTime(DateTime.now().year + 2),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(primary: AppColors.gold),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setDialogState(() => endDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today, color: AppColors.gold),
                  label: Text(
                    endDate != null
                        ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                        : 'Seleccionar',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Selecciona las fechas')),
                    );
                    return;
                  }
                  try {
                    await _offDayService.updateOffDay(offDay.copyWith(
                      reason: selectedReason,
                      startDate: startDate,
                      endDate: endDate,
                    ));
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                child: const Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}