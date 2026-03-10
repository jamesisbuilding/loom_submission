import 'package:garment_transformation_service/garment_transformation_service.dart';

class GarmentTransformationRepositoryImpl
    implements GarmentTransformationRepository {
  GarmentTransformationRepositoryImpl({
    required GarmentTransformationDataSource dataSource,
  }) : _dataSource = dataSource;

  final GarmentTransformationDataSource _dataSource;

  @override
  Future<GarmentAnalysisModel> analyseGarment({
    required String originalGarmentImage,
  }) {
    return _dataSource.analyseGarment(
      originalGarmentImage: originalGarmentImage,
    );
  }

  @override
  Future<GarmentIdeationModel> ideateGarment({
    required GarmentAnalysisModel garmentAnalysis,
    required String originalGarmentImage,
  }) {
    return _dataSource.ideateGarment(
      garmentAnalysis: garmentAnalysis,
      originalGarmentImage: originalGarmentImage,
    );
  }

  @override
  Future<GarmentTransformationCollection> generateGarmentTransformations({
    required GarmentIdeationModel garmentIdeas,
    required String originalGarmentImage,
  }) {
    return _dataSource.generateGarmentTransformations(
      garmentIdeas: garmentIdeas,
      originalGarmentImage: originalGarmentImage,
    );
  }
}

