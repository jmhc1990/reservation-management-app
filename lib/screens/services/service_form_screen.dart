import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  File? _image;

  // 📷 Seleccionar imagen
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ☁️ Subir imagen a Firebase
  Future<String?> uploadImage(String serviceId) async {
    if (_image == null) return null;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('services/$serviceId/cover.jpg');

      await ref.putFile(_image!);

      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint("Error subiendo imagen: $e");
      return null;
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
                final url = await uploadImage("test123");

                if (url != null) {
                  debugPrint("URL: $url");

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Imagen subida correctamente')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al subir imagen')),
                  );
                }
              },
              child: const Text('Subir imagen'),
            ),
          ],
        ),
      ),
    );
  }
}