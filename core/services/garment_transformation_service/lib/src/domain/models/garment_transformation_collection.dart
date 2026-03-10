import 'package:garment_transformation_service/src/domain/models/garment_transformation_model.dart';

class GarmentTransformationCollection {
  final List<GarmentTransformationModel> transformedGarments;

  GarmentTransformationCollection({
    required this.transformedGarments,
  });

  /// Create an instance with an empty list
  factory GarmentTransformationCollection.empty() {
    return GarmentTransformationCollection(
      transformedGarments: [],
    );
  }

  /// Copy this collection, optionally replacing the list
  GarmentTransformationCollection copyWith({
    List<GarmentTransformationModel>? transformedGarments,
  }) {
    return GarmentTransformationCollection(
      transformedGarments: transformedGarments ?? this.transformedGarments,
    );
  }

  /// Create from a JSON map
  factory GarmentTransformationCollection.fromJson(Map<String, dynamic> json) {
    return GarmentTransformationCollection(
      transformedGarments: (json['transformedGarments'] as List<dynamic>? ?? [])
          .map((item) => GarmentTransformationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'transformedGarments': transformedGarments.map((e) => e.toJson()).toList(),
    };
  }
}

