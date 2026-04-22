import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  File? _image;

  // 📷 Seleccionar imagen con validación de tamaño
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);

      final sizeInBytes = await file.length();
      final sizeInMB = sizeInBytes / (1024 * 1024);

      // 🔥 Validación < 5MB
      if (sizeInMB > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen supera los 5MB'),
          ),
        );
        return;
      }

      setState(() {
        _image = file;
      });
    }
  }

  // 💾 Guardar servicio en Firestore (modo local)
  Future<void> saveService(String imagePath) async {
    try {
      await FirebaseFirestore.instance.collection('services').add({
        'name': 'Servicio prueba',
        'price': 10,
        'duration': 30,
        'image_url': imagePath,
      });

      debugPrint("Servicio guardado en Firestore");
    } catch (e) {
      debugPrint("Error guardando servicio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear servicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: const Text('Seleccionar imagen'),
            ),

            const SizedBox(height: 20),

            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                fit: BoxFit.cover,
              ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (_image == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona una imagen primero'),
                    ),
                  );
                  return;
                }

                final url = _image!.path;

                await saveService(url);

                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Servicio guardado (modo local)'),
                  ),
                );
              },
              child: const Text('Guardar servicio'),
            ),
          ],
        ),
      ),
    );
  }
}