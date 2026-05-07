import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../booking/booking_screen.dart';
import '../booking/my_appointments_screen.dart';
import '../services/services_list_screen.dart';
import '../admin/admin_screen.dart';
 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
 
  static const Color gold = AppColors.gold;
 
  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final themeController = Provider.of<ThemeController>(context);
    final isDark = themeController.isDark;
 
    // Colores dinámicos según tema
    final bg          = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceBg   = isDark ? AppColors.darkSurface : Colors.grey.withValues(alpha: 0.08);
    final surfaceCard = isDark ? AppColors.darkCard : Colors.grey.withValues(alpha: 0.12);
    final textColor   = isDark ? Colors.white : AppColors.black;
    final subColor    = isDark ? Colors.white60 : Colors.black54;
 
    // LÓGICA TEMPORAL
    bool haReservadoAntes = false;
    String nombreBarbero = "David";
    int puntosFidelidad = 4;
    String userRole = 'cliente';
 
    // Redirección si es Admin
    if (userRole == 'admin') return const AdminScreen();
 
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              onLogout: () => authController.logout(),
              onToggleTheme: () => themeController.toggle(),
              isDark: isDark,
            ),
            _SectionTitle(title: 'Inicio', textColor: textColor),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
 
                    // --- SI YA ES CLIENTE ---
                    if (haReservadoAntes) ...[
                      Text(
                        'Tus Servicios Favoritos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ExpertCard(
                        nombre: nombreBarbero,
                        cardColor: surfaceCard,
                        textColor: textColor,
                        subColor: subColor,
                      ),
                      const SizedBox(height: 14),
                      _ServiceInfo(textColor: textColor, subColor: subColor),
                      const SizedBox(height: 16),
                      _buildButton(
                        'REPETIR ESTA EXPERIENCIA',
                        gold,
                        Colors.black,
                        () {},
                        icon: Icons.repeat,
                      ),
                    ]
                    // --- SI ES NUEVO ---
                    else ...[
                      _WelcomeGreeting(
                        uid: authController.currentUser?.uid,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'Reserva tu cita ahora mismo.',
                          style: TextStyle(color: subColor),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // sección de próximas citas (vacía si el cliente no tiene)
                    MyAppointmentsSection(textColor: textColor),

                    const SizedBox(height: 10),

                    // Botón reservar cita (BookingScreen)
                    _buildButton(
                      'RESERVAR CITA',
                      gold,
                      Colors.black,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingScreen()),
                      ),
                      icon: Icons.calendar_month,
                    ),

                    const SizedBox(height: 12),

                    // botón ver servicios
                    _buildButton(
                      haReservadoAntes ? 'RESERVAR OTRO SERVICIO' : 'VER SERVICIOS',
                      Colors.transparent,
                      gold,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ServicesListScreen(isAdmin: false),
                        ),
                      ),
                      isOutlined: true,
                    ),
 
                    const SizedBox(height: 30),
 
                    _GoldDivider(),
                    Center(
                      child: Text(
                        'Tarjeta de Fidelización',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ),
                    _GoldDivider(),
                    const SizedBox(height: 20),
                    _LoyaltyCard(
                      puntos: puntosFidelidad,
                      surfaceBg: surfaceBg,
                      surfaceCard: surfaceCard,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '*Te faltan ${10 - puntosFidelidad} servicios para tu corte gratuito.',
                        style: TextStyle(fontSize: 11, color: subColor),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
 
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
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: txt,
          elevation: 0,
          side: isOutlined ? const BorderSide(color: gold, width: 1.5) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
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
 
// Componentes

// Saludo "Bienvenido, [nombre]" — escucha el doc del usuario en Firestore
// si carga o falla, muestra solo "¡Bienvenido!".
class _WelcomeGreeting extends StatelessWidget {
  final String? uid;
  final Color textColor;

  const _WelcomeGreeting({required this.uid, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: textColor,
    );

    if (uid == null) {
      return Center(child: Text('¡Bienvenido!', style: style));
    }

    return StreamBuilder<ModeloUsuario?>(
      stream: UserService().streamUserById(uid!),
      builder: (context, snapshot) {
        final firstName = snapshot.data?.name.split(' ').first;
        final text = (firstName != null && firstName.isNotEmpty)
            ? 'Bienvenido, $firstName'
            : '¡Bienvenido!';
        return Center(child: Text(text, style: style));
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onToggleTheme;
  final bool isDark;
 
  const _Header({
    required this.onLogout,
    required this.onToggleTheme,
    required this.isDark,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HomeScreen.gold, width: 1.5)),
      ),
      child: Row(
        children: [
          const Spacer(),
          // Botón de cambio de tema
          IconButton(
            onPressed: onToggleTheme,
            tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: HomeScreen.gold,
            ),
          ),
          // Botón de cerrar sesión con diálogo de confirmación
          IconButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar sesión'),
                  content: const Text('¿Seguro que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true) onLogout();
            },
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout, color: HomeScreen.gold),
          ),
        ],
      ),
    );
  }
}
 
class _SectionTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  const _SectionTitle({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HomeScreen.gold, width: 1.5)),
      ),
      child: Row(
        children: [
          // Barra de acento dorada
          Container(
            width: 4,
            height: 26,
            decoration: BoxDecoration(
              color: HomeScreen.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          // Diamante decorativo en el lateral derecho
          Icon(
            Icons.diamond_outlined,
            color: HomeScreen.gold.withValues(alpha: 0.85),
            size: 20,
          ),
        ],
      ),
    );
  }
}
 
class _GoldDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: HomeScreen.gold, thickness: 1),
    );
  }
}
 
class _ExpertCard extends StatelessWidget {
  final String nombre;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
 
  const _ExpertCard({
    required this.nombre,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: HomeScreen.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: HomeScreen.gold.withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: HomeScreen.gold, size: 34),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nombre,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor)),
              Text('Tu experto',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: subColor)),
            ],
          ),
        ],
      ),
    );
  }
}
 
class _ServiceInfo extends StatelessWidget {
  final Color textColor;
  final Color subColor;
  const _ServiceInfo({required this.textColor, required this.subColor});
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('✂️ Corte Signature',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: textColor)),
        const SizedBox(height: 4),
        Text('Asesoramiento, corte a tijera y lavado\npremium. 60 min.',
            style: TextStyle(fontSize: 13, color: subColor)),
      ],
    );
  }
}
 
class _LoyaltyCard extends StatelessWidget {
  final int puntos;
  final Color surfaceBg;
  final Color surfaceCard;
 
  const _LoyaltyCard({
    required this.puntos,
    required this.surfaceBg,
    required this.surfaceCard,
  });
 
 @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HomeScreen.gold.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: GridView.count(
        crossAxisCount: 5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: List.generate(10, (index) {
          final filled = index < puntos;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled
                  ? HomeScreen.gold.withValues(alpha: 0.15)
                  : surfaceBg,
              border: Border.all(
                color: filled
                    ? HomeScreen.gold
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: filled
                ? const Icon(Icons.star, color: HomeScreen.gold, size: 22)
                : Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.grey.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          );
        }),
      ),
    );
  }
}