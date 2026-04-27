class ModeloServicio {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String description;

  ModeloServicio({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory ModeloServicio.fromMap(Map<String, dynamic> map) {
    return ModeloServicio(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      duration: int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
    };
  }

  ModeloServicio copyWith({
    String? id,
    String? name,
    double? price,
    int? duration,
    String? description,
  }) {
    return ModeloServicio(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
    );
  }
}