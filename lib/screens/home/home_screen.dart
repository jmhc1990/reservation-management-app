import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../services/services_list_screen.dart';
import '../admin/admin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color gold = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFDFBF6);

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    // LÓGICA TEMPORAL
    bool haReservadoAntes = false;
    String nombreBarbero = "David";
    int puntosFidelidad = 0;
    String userRole = 'cliente';

    // Redirección si es Admin
    if (userRole == 'admin') return const AdminScreen();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onLogout: () => authController.logout()),
            const _SectionTitle(title: 'Inicio'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // --- SI YA ES CLIENTE ---
                    if (haReservadoAntes) ...[
                      const Text(
                        'Tus Servicios Favoritos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ExpertCard(nombre: nombreBarbero),
                      const SizedBox(height: 14),
                      const _ServiceInfo(),
                      const SizedBox(height: 16),
                      _buildButton(
                        'REPETIR ESTA EXPERIENCIA',
                        gold,
                        Colors.white,
                        () {},
                        icon: Icons.repeat,
                      ),
                    ]
                    // ---  SI ES NUEVO ---
                    else ...[
                      const Center(
                        child: Text(
                          '¡Bienvenido!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'Reserva tu primera cita ahora.',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],

                    const SizedBox(height: 10),

                    _buildButton(
                      haReservadoAntes
                          ? 'RESERVAR OTRO SERVICIO'
                          : 'RESERVAR MI PRIMERA CITA',
                      Colors.transparent,
                      Colors.black,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ServicesListScreen(isAdmin: false),
                        ),
                      ),
                      isOutlined: true,
                    ),

                    const SizedBox(height: 30),
                    const Divider(color: gold, thickness: 1),
                    const Center(
                      child: Text(
                        'Tarjeta de Fidelización',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const Divider(color: gold, thickness: 1),
                    const SizedBox(height: 20),
                    _LoyaltyCard(puntos: puntosFidelidad),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        '*Te faltan ${6 - puntosFidelidad} servicios para tu corte gratuito.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los botones
  Widget _buildButton(
    String text,
    Color bg,
    Color txt,
    VoidCallback onPress, {
    IconData? icon,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: txt,
          elevation: 0,
          side: isOutlined ? const BorderSide(color: gold, width: 2) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        onPressed: onPress,
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text),
      ),
    );
  }
}

// --- COMPONENTES DE DISEÑO ---
class _Header extends StatelessWidget {
  final VoidCallback onLogout;
  const _Header({required this.onLogout});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HomeScreen.gold, width: 2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back_ios_new, color: HomeScreen.gold),
          ),
          const Text(
            'Atrás',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: HomeScreen.gold),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HomeScreen.gold, width: 2)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final String nombre;
  const _ExpertCard({required this.nombre});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: HomeScreen.gold,
            child: Icon(Icons.person, color: Colors.black, size: 34),
          ),
          const SizedBox(width: 28),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const Text(
                'Tu experto',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceInfo extends StatelessWidget {
  const _ServiceInfo();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✂️ Corte Signature',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        Text(
          'Asesoramiento, corte a tijera y lavado\npremium. 60 min.',
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
      ],
    );
  }
}

class _LoyaltyCard extends StatelessWidget {
  final int puntos;
  const _LoyaltyCard({required this.puntos});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 18,
        runSpacing: 16,
        children: List.generate(6, (index) {
          final filled = index < puntos;
          return Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? Colors.black : HomeScreen.background,
              border: Border.all(color: Colors.black, width: 1.5),
            ),
            child: filled
                ? const Icon(Icons.star, color: HomeScreen.gold, size: 34)
                : null,
          );
        }),
      ),
    );
  }
}
