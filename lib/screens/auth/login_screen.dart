import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import 'register_screen.dart';
 
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
 
  //  acción del login
 
  Future<void> _handleLogin() async {
    context.read<AuthController>().clearError();
 
    if (!_formKey.currentState!.validate()) return;
 
    FocusScope.of(context).unfocus();
 
    await context.read<AuthController>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
 
  // navegación al registro
 
  void _goToRegister() {
    context.read<AuthController>().clearError();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }
 
  //  UI pendiente de la persona de diseño
 
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // campo email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo electrónico'),
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
 
                    const SizedBox(height: 16),
 
                    // campo contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: controller.obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        suffixIcon: IconButton(
                          onPressed: controller.togglePasswordVisibility,
                          icon: Icon(controller.obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce tu contraseña';
                        }
                        return null;
                      },
                    ),
 
                    const SizedBox(height: 24),
 
                    // botón login con estado de carga
                    ElevatedButton(
                      onPressed: controller.isLoading ? null : _handleLogin,
                      child: controller.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Iniciar sesión'),
                    ),
 
                    const SizedBox(height: 12),
 
                    // mensaje de error de Firebase
                    if (controller.errorMessage != null)
                      Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
 
                    // enlace a registro
                    TextButton(
                      onPressed: _goToRegister,
                      child: const Text('¿No tienes cuenta? Regístrate'),
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