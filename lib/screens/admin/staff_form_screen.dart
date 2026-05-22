import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/staff.dart';
import '../../models/services.dart';
import '../../services/staff_service.dart';
import '../../services/catalog_service.dart';

class StaffFormScreen extends StatefulWidget {
  final ModeloStaff? staff;

  const StaffFormScreen({
    super.key,
    this.staff,
  });

  @override
  State<StaffFormScreen> createState() => _StaffFormScreenState();
}

class _StaffFormScreenState extends State<StaffFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _specialtyController = TextEditingController();

  final StaffService _staffService = StaffService();
  final CatalogService _catalogService = CatalogService();

  bool _isLoading = false;
  bool get _isEditing => widget.staff != null;
  Specialization _specialization = Specialization.barber; // Valor por defecto

  // Especialidades
  List<String> _specialties = [];

  // Servicios seleccionados
  List<String> _selectedServiceIds = [];
  List<ModeloServicio> _availableServices = [];

  // Horario semanal
  final Map<String, List<TramoHorario>?> _workingHours = {
    'mon': null,
    'tue': null,
    'wed': null,
    'thu': null,
    'fri': null,
    'sat': null,
    'sun': null,
  };

  final Map<String, String> _dayNames = {
    'mon': 'Lunes',
    'tue': 'Martes',
    'wed': 'Miércoles',
    'thu': 'Jueves',
    'fri': 'Viernes',
    'sat': 'Sábado',
    'sun': 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    _loadServices();
    if (_isEditing) {
      _nameController.text = widget.staff!.name;
      _bioController.text = widget.staff!.bio;
      _specialization = widget.staff!.specialization;
      _specialties = List.from(widget.staff!.specialties);
      _selectedServiceIds = List.from(widget.staff!.serviceIds);
      widget.staff!.workingHours.forEach((dia, tramos) {
        _workingHours[dia] = tramos != null ? List.from(tramos) : null;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final services = await _catalogService.getServices();
      setState(() => _availableServices = services);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar servicios: $e')),
        );
      }
    }
  }

  void _addSpecialty() {
    final specialty = _specialtyController.text.trim();
    if (specialty.isNotEmpty && !_specialties.contains(specialty)) {
      setState(() {
        _specialties.add(specialty);
        _specialtyController.clear();
      });
    }
  }

  void _removeSpecialty(String specialty) {
    setState(() => _specialties.remove(specialty));
  }

  void _addTramo(String dia) {
    setState(() {
      if (_workingHours[dia] == null) {
        _workingHours[dia] = [];
      }
      _workingHours[dia]!.add(
        TramoHorario(startHour: '09:00', endHour: '18:00'),
      );
    });
  }

  void _removeTramo(String dia, int index) {
    setState(() {
      _workingHours[dia]!.removeAt(index);
      if (_workingHours[dia]!.isEmpty) {
        _workingHours[dia] = null;
      }
    });
  }

  // Valida que no haya solapamientos y que hora fin > hora inicio
  static bool _tramosValidos(Map<String, List<dynamic>?> workingHours) {
    for (final entry in workingHours.entries) {
      final tramos = entry.value;
      if (tramos == null || tramos.isEmpty) continue;

      for (int i = 0; i < tramos.length; i++) {
        final start = _toMinutes(tramos[i].startHour);
        final end = _toMinutes(tramos[i].endHour);

        // Hora fin debe ser mayor que hora inicio
        if (end <= start) return false;

        // Comprueba solapamiento con el resto de tramos
        for (int j = i + 1; j < tramos.length; j++) {
          final aStart = _toMinutes(tramos[i].startHour);
          final aEnd = _toMinutes(tramos[i].endHour);
          final bStart = _toMinutes(tramos[j].startHour);
          final bEnd = _toMinutes(tramos[j].endHour);

          if (aStart < bEnd && bStart < aEnd) return false;
        }
      }
    }
    return true;
  }

  static int _toMinutes(String hour) {
    final parts = hour.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if(!_tramosValidos(_workingHours)){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hay horas que se solapan o incorrectas.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.staff!.copyWith(
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          specialization: _specialization,
          specialties: _specialties,
          serviceIds: _selectedServiceIds,
          workingHours: _workingHours,
        );
        await _staffService.updateStaff(updated);
      } else {
        final staff = ModeloStaff(
          id: '',
          name: _nameController.text.trim(),
          bio: _bioController.text.trim(),
          specialization: _specialization,
          specialties: _specialties,
          serviceIds: _selectedServiceIds,
          workingHours: _workingHours,
        );
        await _staffService.addStaff(staff);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Trabajador actualizado correctamente'
                : 'Trabajador creado correctamente',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar trabajador' : 'Nuevo trabajador'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Nombre
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La biografía es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<Specialization>(
                initialValue: _specialization,
                decoration: const InputDecoration(
                  labelText: 'Especialización',
                  prefixIcon: Icon(Icons.work_outline),
                ),
                items: Specialization.values.map((spec) {
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(spec == Specialization.barber ? 'Barbero' : 'Estilista'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _specialization = value);
                },
              ),

              // Especialidades
              const Text(
                'Especialidades',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _specialtyController,
                      decoration: const InputDecoration(
                        labelText: 'Añadir especialidad',
                        prefixIcon: Icon(Icons.star_outline),
                      ),
                      onFieldSubmitted: (_) => _addSpecialty(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSpecialty,
                    icon: const Icon(Icons.add_circle, color: AppColors.gold),
                    tooltip: 'Añadir',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _specialties.map((specialty) {
                  return Chip(
                    label: Text(specialty),
                    onDeleted: () => _removeSpecialty(specialty),
                    deleteIconColor: AppColors.cancel,
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Servicios
              const Text(
                'Servicios que ofrece',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              if (_availableServices.isEmpty)
                const Text('Cargando servicios...')
              else
                ..._availableServices.map((servicio) {
                  return CheckboxListTile(
                    title: Text(servicio.name),
                    subtitle: Text('${servicio.price}€ · ${servicio.duration} min'),
                    value: _selectedServiceIds.contains(servicio.id),
                    activeColor: AppColors.gold,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedServiceIds.add(servicio.id);
                        } else {
                          _selectedServiceIds.remove(servicio.id);
                        }
                      });
                    },
                  );
                }),
              const SizedBox(height: 24),

              // Horario semanal
              const Text(
                'Horario semanal',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ..._workingHours.entries.map((entry) {
                final dia = entry.key;
                final tramos = entry.value;
                final isWorking = tramos != null;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dayNames[dia]!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Switch(
                              value: isWorking,
                              activeThumbColor: AppColors.gold,
                              onChanged: (value) {
                                setState(() {
                                  _workingHours[dia] = value ? [] : null;
                                  if (value) _addTramo(dia);
                                });
                              },
                            ),
                          ],
                        ),
                        if (isWorking) ...[
                          ...tramos.asMap().entries.map((e) {
                            final index = e.key;
                            final tramo = e.value;
                            return Row(
                              children: [
                                // Hora inicio
                                Expanded(
                                  child: TextFormField(
                                    initialValue: tramo.startHour,
                                    decoration: const InputDecoration(
                                      labelText: 'Inicio',
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      _workingHours[dia]![index] = TramoHorario(
                                        startHour: value,
                                        endHour: _workingHours[dia]![index].endHour,
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Hora fin
                                Expanded(
                                  child: TextFormField(
                                    initialValue: tramo.endHour,
                                    decoration: const InputDecoration(
                                      labelText: 'Fin',
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      _workingHours[dia]![index] = TramoHorario(
                                        startHour: _workingHours[dia]![index].startHour,
                                        endHour: value,
                                      );
                                    },
                                  ),
                                ),
                                // Eliminar tramo
                                IconButton(
                                  onPressed: () => _removeTramo(dia, index),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.cancel,
                                  ),
                                ),
                              ],
                            );
                          }),
                          // Añadir tramo
                          TextButton.icon(
                            onPressed: () => _addTramo(dia),
                            icon: const Icon(Icons.add, color: AppColors.gold),
                            label: const Text(
                              'Añadir tramo',
                              style: TextStyle(color: AppColors.gold),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Botón guardar
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: AppColors.gold,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Actualizar trabajador' : 'Crear trabajador',
                        style: const TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}