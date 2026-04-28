class ModeloServicio {
  final String id;
  final String name;
  final double price;
  final int duration;
  final String description;
  final String? imageUrl;

  ModeloServicio({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.description,
    this.imageUrl,
  });

  factory ModeloServicio.fromMap(Map<String, dynamic> map) {
    return ModeloServicio(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      duration: int.tryParse(map['duration']?.toString() ?? '0') ?? 0,
      description: map['description'] ?? '',
      imageUrl: map['image_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'duration': duration,
      'description': description,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  ModeloServicio copyWith({
    String? id,
    String? name,
    double? price,
    int? duration,
    String? description,
    String? imageUrl,
  }) {
    return ModeloServicio(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}