import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
 
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
 
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}
 
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
 
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
 
  // Acción del registro
 
  Future<void> _handleRegister() async {
    context.read<AuthController>().clearError();
 
    if (!_formKey.currentState!.validate()) return;
 
    FocusScope.of(context).unfocus();
 
    final success = await context.read<AuthController>().register(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        );
 
    if (success && mounted) {
      Navigator.pop(context);
    }
  }
 
  // Helper decoración de campos
 
  InputDecoration _fieldDecoration({
    required String label,
    required IconData prefixIconData,
    required Color subColor,
    required Color iconColor,
    required Color cardBg,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.lato(color: subColor),
      prefixIcon: Icon(prefixIconData, color: iconColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cardBg,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2),
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
    );
  }
 
  // UI
 
  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDark;

    // Colores según tema
    final bg        = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFDFBF7);
    final cardBg    = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.1);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subColor  = isDark ? Colors.white60 : Colors.black54;
    final iconColor = isDark ? Colors.white54 : const Color(0xFF1A1A1A);
 
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
    ));
 
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            title: Text(
              'Crear cuenta',
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
            backgroundColor: bg,
            foregroundColor: textColor,
            elevation: 0,
            iconTheme: IconThemeData(color: textColor),
            actions: [
              IconButton(
                onPressed: themeCtrl.toggle,
                tooltip: isDark ? 'Modo claro' : 'Modo oscuro',
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: const Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 38),
                    Text(
                      'Únete a la Barbería',
                      style: GoogleFonts.oswald(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Crea tu cuenta para empezar a reservar',
                      style: GoogleFonts.lato(color: subColor, fontSize: 15),
                    ),
 
                    const SizedBox(height: 24),
 
                    // Nombre
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: _fieldDecoration(
                        label: 'Nombre completo',
                        prefixIconData: Icons.person,
                        subColor: subColor,
                        iconColor: iconColor,
                        cardBg: cardBg,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce tu nombre';
                        }
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
 
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: _fieldDecoration(
                        label: 'Correo electrónico',
                        prefixIconData: Icons.email,
                        subColor: subColor,
                        iconColor: iconColor,
                        cardBg: cardBg,
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
 
                    // Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: controller.obscurePassword,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: _fieldDecoration(
                        label: 'Contraseña',
                        prefixIconData: Icons.lock,
                        subColor: subColor,
                        iconColor: iconColor,
                        cardBg: cardBg,
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(
                            controller.obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: iconColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce una contraseña';
                        }
                        if (value.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
 
                    // Confirmar contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: controller.obscureConfirmPassword,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: _fieldDecoration(
                        label: 'Confirmar contraseña',
                        prefixIconData: Icons.lock_outline,
                        subColor: subColor,
                        iconColor: iconColor,
                        cardBg: cardBg,
                        suffixIcon: IconButton(
                          onPressed: controller.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            controller.obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: iconColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirma tu contraseña';
                        }
                        if (value != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
 
                    // Teléfono
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.lato(color: textColor),
                      decoration: _fieldDecoration(
                        label: 'Teléfono',
                        prefixIconData: Icons.phone,
                        subColor: subColor,
                        iconColor: iconColor,
                        cardBg: cardBg,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce tu teléfono';
                        }
                        if (value.trim().length < 9) {
                          return 'El teléfono no parece válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
 
                    // Botón registrarse
                    ElevatedButton(
                      onPressed: controller.isLoading ? null : _handleRegister,
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
                              'REGISTRARSE',
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
 
                    // Enlace de vuelta al login
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '¿Ya tienes cuenta? Inicia sesión',
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

