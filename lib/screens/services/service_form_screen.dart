import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/services.dart';
import '../../../services/catalog_service.dart';

class ServiceFormScreen extends StatefulWidget {
  final ModeloServicio? servicio; // Si es null, se crea uno nuevo

  const ServiceFormScreen({
    super.key,
    this.servicio,
  });

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  final _catalogService = CatalogService();
  File? _image;
  bool _isLoading = false;

  // Si servicio es null, estamos creando uno nuevo, si no, estamos editando
  bool get _isEditing => widget.servicio != null; 

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.servicio!.name;
      _descriptionController.text = widget.servicio!.description;
      _priceController.text = widget.servicio!.price.toString();
      _durationController.text = widget.servicio!.duration.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Seleccionar imagen con validación de tamaño
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final sizeInMB = await file.length() / (1024 * 1024);

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

  // Guardar o actualizar servicio en Firestore
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        // Para actualizar, mantenemos el mismo ID y solo cambiamos los campos editables
        final updatedServicio = widget.servicio!.copyWith(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          duration: int.parse(_durationController.text.trim()),
        );

        await _catalogService.updateService(updatedServicio);
      } else {
        // Para crear un nuevo servicio, el ID se genera automáticamente en Firestore
        final servicio = ModeloServicio(
          id: '',
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          duration: int.parse(_durationController.text.trim()),
        );

        await _catalogService.createService(servicio);
      }
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                ? 'Servicio actualizado correctamente'
                : 'Servicio creado correctamente'
            )
          ),
        );
        Navigator.pop(context);
      
    } catch (e) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el servicio: $e')),
        );
    } finally {
        if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Cambia el título según si estamos editando o creando
        title: Text(
          _isEditing 
            ? 'Editar servicio'
            : 'Crear servicio'
        )
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del servicio',
                  prefixIcon: Icon(Icons.cut),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 20),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 20),

              // Precio
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Precio (€)',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es obligatorio';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'El precio debe ser mayor que 0';
                  }
                  return null;
                }
              ),
              const SizedBox(height: 20),

              // Duración
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  labelText: 'Duración (minutos)',
                  prefixIcon: Icon(Icons.timer),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La duración es obligatoria';
                  }
                  final duration = int.tryParse(value.trim());
                  if (duration == null || duration <= 0) {
                    return 'La duración debe ser mayor que 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Imagen (temporal)
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Seleccionar imagen'),
              ),
              if (_image != null) ...[
                const SizedBox(height: 25),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _image!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Boton de guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                  : Text(
                    // El texto del botón cambia según si estamos editando o creando
                    _isEditing 
                      ? 'Actualizar servicio' 
                      : 'Crear servicio'
                  ),
              ),
            ],
          ),
        ),
      )
    );
  }
}