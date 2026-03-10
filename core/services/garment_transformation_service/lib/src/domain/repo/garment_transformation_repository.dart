import '../models/garment_analysis_model.dart';
import '../models/garment_ideation_model.dart';
import '../models/garment_transformation_collection.dart';

abstract class GarmentTransformationRepository {
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

