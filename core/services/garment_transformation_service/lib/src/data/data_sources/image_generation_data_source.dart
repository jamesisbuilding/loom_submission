import '../../domain/models/garment_analysis_model.dart';
import '../../domain/models/garment_ideation_model.dart';
import '../../domain/models/garment_transformation_collection.dart';

abstract class GarmentTransformationDataSource {
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  });

  Future<GarmentIdeationModel> ideateGarment({
    required GarmentAnalysisModel garmentAnalysis,
    required String originalGarmentImage,
  });

  Future<GarmentTransformationCollection> generateGarmentTransformations({
    required GarmentIdeationModel garmentIdeas,
    required String originalGarmentImage,
  });
}

