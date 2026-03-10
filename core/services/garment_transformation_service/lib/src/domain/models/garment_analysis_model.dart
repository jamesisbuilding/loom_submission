class GarmentAnalysisModel {
  final String description;
  final String imageURL;

  GarmentAnalysisModel({
    this.description = '',
    this.imageURL = '',
  });

  factory GarmentAnalysisModel.fromJson(Map<String, dynamic> json) {
    return GarmentAnalysisModel(
      description: json['description'] as String? ?? '',
      imageURL: json['imageURL'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'imageURL': imageURL,
    };
  }

  GarmentAnalysisModel copyWith({
    String? description,
    String? imageURL,
  }) {
    return GarmentAnalysisModel(
      description: description ?? this.description,
      imageURL: imageURL ?? this.imageURL,
    );
  }

  factory GarmentAnalysisModel.empty() {
    return GarmentAnalysisModel(
      description: '',
      imageURL: '',
    );
  }
}

