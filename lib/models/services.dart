class ModeloServicio {
  final String id;
  final String nombre;
  final double precio;
  final int duracionMinutos;
  final String descripcion;

  ModeloServicio({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.duracionMinutos,
    required this.descripcion,
  });

  factory ModeloServicio.fromMap(Map<String, dynamic> map) {
    return ModeloServicio(
      id: map['id'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      duracionMinutos: map['duracionMinutos'] ?? 0,
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'duracionMinutos': duracionMinutos,
      'descripcion': descripcion,
    };
  }

  ModeloServicio copyWith({
    String? id,
    String? nombre,
    double? precio,
    int? duracionMinutos,
    String? descripcion,
  }) {
    return ModeloServicio(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      duracionMinutos: duracionMinutos ?? this.duracionMinutos,
      descripcion: descripcion ?? this.descripcion,
    );
  }
}