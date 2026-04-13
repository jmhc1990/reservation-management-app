import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
 
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
 
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
 
  //  acción de registro 
 
  Future<void> _handleRegister() async {
    context.read<AuthController>().clearError();
 
    if (!_formKey.currentState!.validate()) return;
 
    FocusScope.of(context).unfocus();
 
    final success = await context.read<AuthController>().register(
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          displayName: _nameController.text,
        );
 
    // si el registro va bien, el AuthWrapper detecta el nuevo usuario y navega automáticamente al Home
    if (success && mounted) {
      Navigator.pop(context);
    }
  }
 
  //  UI pendiente de la persona de diseño
 
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                // campo nombre
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
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
                      return 'Introduce una contraseña';
                    }
                    if (value.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
 
                // campo de confirmar contraseña
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: controller.obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    suffixIcon: IconButton(
                      onPressed: controller.toggleConfirmPasswordVisibility,
                      icon: Icon(controller.obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
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
 
                // botón registro con estado de carga
                ElevatedButton(
                  onPressed: controller.isLoading ? null : _handleRegister,
                  child: controller.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Crear cuenta'),
                ),
 
                // mensaje de error de Firebase
                if (controller.errorMessage != null)
                  Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
 
                // enlace de vuelta al login
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}