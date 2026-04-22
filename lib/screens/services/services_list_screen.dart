import 'package:flutter/material.dart';
import '../../../models/services.dart';
import '../../../services/catalog_service.dart';
import 'service_form_screen.dart';

class ServicesListScreen extends StatelessWidget {
  final bool isAdmin;

  const ServicesListScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
      actions: [
        // Solo mostrar botón de añadir si es admin
        if (isAdmin)
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ServiceFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Añadir servicio',
          )
      ]
      ),
      body: StreamBuilder<List<ModeloServicio>>(
        stream: CatalogService().streamServices(),
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
              return _ServiceCard(
                servicio: servicio,
                isAdmin: isAdmin,
              );
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

  const _ServiceCard({
    required this.servicio,
    required this.isAdmin,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text('¿Estás seguro de que quieres eliminar "${servicio.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      )
    );

    if (confirmed == true) {
      try {
        await CatalogService().deleteService(servicio.id);
        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio eliminado')),
          );
        }
      } catch(e) {
        if(context.mounted){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
        
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.cut, size: 40),
        title: Text(servicio.name),
        subtitle: Text('${servicio.price}€ · ${servicio.duration} min'),
        trailing: isAdmin
            ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Editar - pendiente implementar
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar( 
                        content: Text('Edición de servicios no implementada'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar servicio',
                ),
                // Eliminar
                IconButton(
                  onPressed: () => _handleDelete(context),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Eliminar servicio',
                ),
              ],
            )
            : null,
        ),
    );
  }
}