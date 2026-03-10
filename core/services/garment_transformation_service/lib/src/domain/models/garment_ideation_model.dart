class GarmentIdeationModel {
  final List<IdeationModel> variations;

  GarmentIdeationModel({required this.variations});

  factory GarmentIdeationModel.fromJson(Map<String, dynamic> json) {
    return GarmentIdeationModel(
      variations: (json['variations'] as List<dynamic>? ?? [])
          .map((e) => IdeationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'variations': variations.map((v) => v.toJson()).toList()};
  }

  GarmentIdeationModel copyWith({List<IdeationModel>? variations}) {
    return GarmentIdeationModel(variations: variations ?? this.variations);
  }

  factory GarmentIdeationModel.empty() {
    return GarmentIdeationModel(variations: []);
  }
}

class IdeationModel {
  final String name;
  final String description;

  IdeationModel({required this.name, required this.description});

  factory IdeationModel.fromJson(Map<String, dynamic> json) {
    return IdeationModel(
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }

  IdeationModel copyWith({String? name, String? description}) {
    return IdeationModel(
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  factory IdeationModel.empty() {
    return IdeationModel(name: '', description: '');
  }
}
