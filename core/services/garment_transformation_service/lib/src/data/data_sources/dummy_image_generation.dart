import 'package:garment_transformation_service/garment_transformation_service.dart';

/// Dummy data source used during development.
///
/// - analyseGarment: returns a trivial analysis using the original image path.
/// - ideateGarment: returns three hard-coded ideation options.
/// - generateGarmentTransformations: returns three transformations that all
///   reuse the original image URL with descriptive text.
class DummyImageGeneration implements GarmentTransformationDataSource {
  const DummyImageGeneration();

  @override
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  }) async {
    return GarmentAnalysisModel(
      description: 'Dummy analysis for $originalGarmentImage',
      imageURL: originalGarmentImage,
    );
  }

  @override
  Future<GarmentIdeationModel> ideateGarment({
    required GarmentAnalysisModel garmentAnalysis,
    required String originalGarmentImage,
  }) async {
    return GarmentIdeationModel(
      variations: [
        IdeationModel(
          name: 'Cropped Top',
          description:
              'Shorten the garment into a cropped top keeping the original fabric and style.',
        ),
        IdeationModel(
          name: 'Everyday Tote',
          description:
              'Transform the fabric into a sturdy tote bag suitable for daily use.',
        ),
        IdeationModel(
          name: 'Layered Jacket',
          description:
              'Refine the piece into a lightweight layered jacket, preserving key details.',
        ),
      ],
    );
  }

  @override
  Future<GarmentTransformationCollection> generateGarmentTransformations({
    required GarmentIdeationModel garmentIdeas,
    required String originalGarmentImage,
  }) async {
    final variations = garmentIdeas.variations.take(3).toList();
    final transformed = variations.map((idea) {
      return GarmentTransformationModel(
        image: originalGarmentImage,
        description: idea.description,
        imageURL: originalGarmentImage,
      );
    }).toList();

    return GarmentTransformationCollection(
      transformedGarments: transformed,
    );
  }
}

