class GarmentTransformationModel {
  final String image;
  final String description;
  final String imageURL;

  GarmentTransformationModel({
    required this.image,
    required this.description,
    required this.imageURL,
  });

  /// Create an instance with all fields as empty strings
  factory GarmentTransformationModel.empty() {
    return GarmentTransformationModel(
      image: '',
      description: '',
      imageURL: '',
    );
  }

  /// Copy this model, optionally replacing some fields
  GarmentTransformationModel copyWith({
    String? image,
    String? description,
    String? imageURL,
  }) {
    return GarmentTransformationModel(
      image: image ?? this.image,
      description: description ?? this.description,
      imageURL: imageURL ?? this.imageURL,
    );
  }

  /// Create from a JSON map
  factory GarmentTransformationModel.fromJson(Map<String, dynamic> json) {
    return GarmentTransformationModel(
      image: json['image'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageURL: json['imageURL'] as String? ?? '',
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'description': description,
      'imageURL': imageURL,
    };
  }
}
