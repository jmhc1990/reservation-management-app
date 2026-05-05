import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/services.dart';
import '../../../services/catalog_service.dart';
import './service_form_screen.dart';
import '../../core/theme/app_colors.dart';

class ServicesListScreen extends StatefulWidget {
  final bool isAdmin;

  const ServicesListScreen({super.key, this.isAdmin = false});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen> {
  final _catalogService = CatalogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServiceFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              tooltip: 'Añadir servicio',
            ),
        ],
      ),
      body: StreamBuilder<List<ModeloServicio>>(
        stream: _catalogService.streamServices(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error cargando servicios'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data ?? [];

          if (services.isEmpty) {
            return const Center(child: Text('No hay servicios'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final servicio = services[index];
              return _ServiceCard(servicio: servicio, isAdmin: widget.isAdmin);
            },
          );
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ModeloServicio servicio;
  final bool isAdmin;
  final CatalogService _catalogService = CatalogService();

  _ServiceCard({required this.servicio, required this.isAdmin});

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${servicio.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: AppColors.cancel)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _catalogService.deleteService(servicio.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Servicio eliminado')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
        }
      }
    }
  }

  Widget _buildImage() {
    if (servicio.imageUrl == null || servicio.imageUrl!.isEmpty) {
      return Container(
        color: Colors.white10,
        child: const Icon(Icons.cut, color: AppColors.gold),
      );
    }
    if (servicio.imageUrl!.startsWith('http')) {
      return Image.network(
        servicio.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.white10,
          child: const Icon(Icons.cut, color: AppColors.gold),
        ),
      );
    } else {
      try {
        return Image.memory(
          base64Decode(servicio.imageUrl!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.white10,
            child: const Icon(Icons.cut, color: AppColors.gold),
          ),
        );
      } catch (_) {
        return Container(
          color: Colors.white10,
          child: const Icon(Icons.cut, color: AppColors.gold),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.black,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.gold, width: 0.8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 70, height: 70, child: _buildImage()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servicio.name,
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${servicio.duration} min • ${servicio.price}€',
                    style: const TextStyle(color: AppColors.textSubtitle, fontSize: 14),
                  ),
                ],
              ),
            ),
            if (isAdmin)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServiceFormScreen(servicio: servicio),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.gold,
                    ),
                    tooltip: 'Editar servicio',
                  ),
                  IconButton(
                    onPressed: () => _handleDelete(context),
                    icon: const Icon(Icons.delete_outline, color: AppColors.cancel),
                    tooltip: 'Eliminar servicio',
                  ),
                ],
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.gold,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
