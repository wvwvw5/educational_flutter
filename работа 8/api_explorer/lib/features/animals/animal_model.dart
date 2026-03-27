class Animal {
  final String name;
  final String taxonomy;
  final List<String> locations;
  final String characteristics;
  final double? minWeight;
  final double? maxWeight;
  final String? lifespan;

  Animal({
    required this.name,
    required this.taxonomy,
    required this.locations,
    required this.characteristics,
    this.minWeight,
    this.maxWeight,
    this.lifespan,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    final taxonomy = json['taxonomy'] as Map<String, dynamic>? ?? {};
    final chars = json['characteristics'] as Map<String, dynamic>? ?? {};
    final locs = json['locations'] as List<dynamic>? ?? [];

    return Animal(
      name: json['name'] ?? 'Unknown',
      taxonomy:
          '${taxonomy['kingdom'] ?? ''} > ${taxonomy['order'] ?? ''} > ${taxonomy['family'] ?? ''}',
      locations: locs.map((e) => e.toString()).toList(),
      characteristics: _buildCharacteristics(chars),
      lifespan: chars['lifespan']?.toString(),
    );
  }

  static String _buildCharacteristics(Map<String, dynamic> chars) {
    final parts = <String>[];
    if (chars['diet'] != null) parts.add('Diet: ${chars['diet']}');
    if (chars['habitat'] != null) parts.add('Habitat: ${chars['habitat']}');
    if (chars['top_speed'] != null) parts.add('Speed: ${chars['top_speed']}');
    if (chars['weight'] != null) parts.add('Weight: ${chars['weight']}');
    if (chars['color'] != null) parts.add('Color: ${chars['color']}');
    if (chars['skin_type'] != null) {
      parts.add('Skin: ${chars['skin_type']}');
    }
    return parts.join('\n');
  }
}
