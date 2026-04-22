import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../../controllers/auth_controller.dart';
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
 
  // Tema local
  bool _isDark = true;
 
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
 
  // Acción del login 
 
  Future<void> _handleLogin() async {
    context.read<AuthController>().clearError();
 
    if (!_formKey.currentState!.validate()) return;
 
    FocusScope.of(context).unfocus();
 
    await context.read<AuthController>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
 
  void _goToRegister() {
    context.read<AuthController>().clearError();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
 
  // UI
 
  @override
  Widget build(BuildContext context) {
    // Colores que cambian según el tema
    final bg         = _isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFDFBF7);
    final cardBg     = _isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.1);
    final textColor  = _isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor   = _isDark ? Colors.white60 : Colors.black54;
    final iconColor  = _isDark ? Colors.white54 : const Color(0xFF1A1A1A);
    final focusBorder = const Color(0xFFD4AF37);
 
    // Ajusta el color de la barra de estado del sistema
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: _isDark ? Brightness.dark : Brightness.light,
    ));
 
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                onPressed: () => setState(() => _isDark = !_isDark),
                tooltip: _isDark ? 'Modo claro' : 'Modo oscuro',
                icon: Icon(
                  _isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              // Esto evita el overflow amarillo/negro
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono tijeras
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.content_cut,
                          color: Color(0xFFD4AF37),
                          size: 52,
                        ),
                      ),
                    ),
 
                    const SizedBox(height: 16),
 
                    // Título y subtítulo
                    Text(
                      'Bienvenido de nuevo',
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Inicia sesión para gestionar tus citas',
                      style: GoogleFonts.lato(
                        color: subColor,
                        fontSize: 15,
                      ),
                    ),
 
                    const SizedBox(height: 24),
 
                    // Campo email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        labelStyle: GoogleFonts.lato(color: subColor),
                        prefixIcon: Icon(Icons.email, color: iconColor),
                        filled: true,
                        fillColor: cardBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: focusBorder, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce tu correo';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'El correo no tiene un formato válido';
                        }
                        return null;
                      },
                    ),
 
                    const SizedBox(height: 14),
 
                    // Campo contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: controller.obscurePassword,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: GoogleFonts.lato(color: subColor),
                        prefixIcon: Icon(Icons.lock, color: iconColor),
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: iconColor,
                          ),
                        ),
                        filled: true,
                        fillColor: cardBg,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: focusBorder, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                        ),
                        errorStyle: const TextStyle(color: Colors.redAccent),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce tu contraseña';
                        }
                        return null;
                      },
                    ),
 
                    const SizedBox(height: 20),
 
                    // Botón entrar
                    ElevatedButton(
                      onPressed: controller.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'ENTRAR',
                              style: GoogleFonts.oswald(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ),
 
                    // Error de firebase 
                    if (controller.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        controller.errorMessage!,
                        style: GoogleFonts.lato(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ],
 
                    const SizedBox(height: 20),
 
                    // Enlace al registro 
                    Center(
                      child: TextButton(
                        onPressed: _goToRegister,
                        child: Text(
                          '¿No tienes cuenta? Regístrate aquí',
                          style: GoogleFonts.lato(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

