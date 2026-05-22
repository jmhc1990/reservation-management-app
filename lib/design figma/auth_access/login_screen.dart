import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../auth_register/join_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    context.read<AuthController>().clearError();
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await context.read<AuthController>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();
    final isDark = themeCtrl.isDark;

    
    final Color bgBarberia = isDark ? const Color(0xFF0F0F1A) : const Color(0xFFFDFBF7);
    final Color doradoBarberia = const Color(0xFFD4AF37);
    final Color negroBarberia = const Color(0xFF1A1A1A);
    final Color textoPrincipal = isDark ? Colors.white : negroBarberia;

    return Scaffold(
      backgroundColor: bgBarberia,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: themeCtrl.toggle,
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: doradoBarberia),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                Text(
                  'INICIAR SESIÓN',
                  style: GoogleFonts.oswald(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: textoPrincipal,
                  ),
                ),
                
                
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 4,
                  width: double.infinity,
                  color: doradoBarberia,
                ),
                
                const SizedBox(height: 40),

                
                TextFormField(
                  controller: _emailController,
                  style: GoogleFonts.lato(color: textoPrincipal),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: GoogleFonts.lato(color: textoPrincipal.withOpacity(0.6)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: doradoBarberia, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: doradoBarberia, width: 4),
                    ),
                  ),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Email no válido' : null,
                ),

                const SizedBox(height: 25),

              
                Consumer<AuthController>(
                  builder: (context, auth, _) => TextFormField(
                    controller: _passwordController,
                    obscureText: auth.obscurePassword,
                    style: GoogleFonts.lato(color: textoPrincipal),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: GoogleFonts.lato(color: textoPrincipal.withOpacity(0.6)),
                      suffixIcon: IconButton(
                        icon: Icon(auth.obscurePassword ? Icons.visibility_off : Icons.visibility, color: doradoBarberia),
                        onPressed: auth.togglePasswordVisibility,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: doradoBarberia, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: doradoBarberia, width: 4),
                      ),
                    ),
                    validator: (value) => (value == null || value.length < 6) ? 'Contraseña corta' : null,
                  ),
                ),

                const SizedBox(height: 50),

                
                Consumer<AuthController>(
                  builder: (context, auth, _) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: doradoBarberia,
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: auth.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'ENTRAR',
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                
                context.select((AuthController a) => a.errorMessage) != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(context.read<AuthController>().errorMessage!, style: const TextStyle(color: Colors.red)),
                      )
                    : const SizedBox.shrink(),

                const SizedBox(height: 30),

                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  const MyRegisterScreen())),
                  child: Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: GoogleFonts.lato(color: textoPrincipal, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}