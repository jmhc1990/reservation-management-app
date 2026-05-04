import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/staff.dart';
import '../../services/staff_service.dart';
import 'staff_off_days_screen.dart';

class StaffSelectorScreen extends StatefulWidget {
  const StaffSelectorScreen({super.key});

  @override
  State<StaffSelectorScreen> createState() => _StaffSelectorScreenState();
}

class _StaffSelectorScreenState extends State<StaffSelectorScreen> {
  final _staffService = StaffService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar trabajador'),
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
              final member = staff[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    Icons.manage_accounts,
                    size: 40,
                    color: member.isActive
                        ? AppColors.gold
                        : AppColors.textSubtitle,
                  ),
                  title: Text(member.name),
                  subtitle: Text(
                    member.specialization == Specialization.barber
                        ? 'Barbero'
                        : 'Estilista',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StaffOffDaysScreen(staff: member),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}