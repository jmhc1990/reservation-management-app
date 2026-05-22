import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../admin/appointments_screen.dart';
import '../admin/staff_list_screen.dart';
import '../admin/staff_selector_screen.dart';
import '../admin/users_list_screen.dart';
import '../booking/appointment_history_screen.dart';
import '../home/home_screen.dart';
import '../services/services_list_screen.dart';
import '../shared/settings_screen.dart';
import '../shared/user_profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  final RolUsuario role;
  final String uid;

  const NavigationScreen({
    super.key,
    required this.role,
    required this.uid,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens {
    if (widget.role == RolUsuario.admin) {
      return [
        const AppointmentsScreen(),
        const ServicesListScreen(isAdmin: true),
        const UsersListScreen(),
        const StaffListScreen(),
        const StaffSelectorScreen(),
      ];
    } else {
      return [
        const HomeScreen(),
        AppointmentHistoryScreen(),
        StreamBuilder<ModeloUsuario?>(
          stream: UserService().streamUserById(widget.uid),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return UserProfileScreen(
              user: snapshot.data!,
              isAdmin: false,
            );
          },
        ),
      ];
    }
  }

  List<BottomNavigationBarItem> get _items {
    if (widget.role == RolUsuario.admin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Citas'),
        BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Servicios'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuarios'),
        BottomNavigationBarItem(icon: Icon(Icons.manage_accounts), label: 'Trabajadores'),
        BottomNavigationBarItem(icon: Icon(Icons.beach_access), label: 'Vacaciones'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Mi perfil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role == RolUsuario.admin
            ? 'Panel de administración'
            : 'StyleSync'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ajustes',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textSubtitle,
        backgroundColor: AppColors.black,
        items: _items,
      ),
    );
  }
}