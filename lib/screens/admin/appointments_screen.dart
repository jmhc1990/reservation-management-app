import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendario
        TableCalendar(
          locale: 'es_ES',
          availableCalendarFormats: const {
            CalendarFormat.month: 'Mes', // solo deja la vista mensual
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

        // IMPLEMENTAR EL LISTADO DE CITAS PARA EL DÍA SELECCIONADO
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: AppColors.gold, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Citas del ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Próximamente',
                  style: TextStyle(color: AppColors.textSubtitle),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}