import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), 
      body: SingleChildScrollView( 
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: const Color(0xFFFDFBF7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Stack(
            children: [
              
              const Positioned(
                left: 80,
                top: 97,
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 40,
                    fontFamily: 'Oswald', 
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              
              Positioned(
                left: 45,
                top: 240,
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: const TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Inter'),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ),

            
              Positioned(
                left: 45,
                top: 320,
                child: SizedBox(
                  width: 300,
                  child: TextField(
                    obscureText: true, 
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Color(0xFF1A1A1A), fontFamily: 'Inter'),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ),

              
              Positioned(
                left: 70,
                top: 450,
                child: GestureDetector(
                  onTap: () {
                    print("Intentando iniciar sesión...");
                  },
                  child: Container(
                    width: 250,
                    height: 50,
                    decoration: ShapeDecoration(
                      color: const Color(0xFF8B6B4E), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'ENTRAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const Positioned(
                left: 110,
                top: 520,
                child: Text(
                  '¿Has olvidado tu contraseña?',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontFamily: 'Inter',
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}