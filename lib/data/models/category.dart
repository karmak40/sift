/// A user-defined document category, colored by [hue] (0-360, HSL hue).
class Category {
  const Category({required this.id, required this.name, required this.hue});

  final String id;
  final String name;
  final double hue;

  Category copyWith({String? id, String? name, double? hue}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      hue: hue ?? this.hue,
    );
  }
}
