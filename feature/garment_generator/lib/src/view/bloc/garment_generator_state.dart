import 'package:flutter/material.dart';
import 'package:garment_transformation_service/garment_transformation_service.dart';

class GarmentGeneratorState {
  final String? uploadedGarmentImage;
  final String? uploadedModelImage;
  final List<Color>? garmentPaletteColors;
  final bool isLoading;
  final GarmentTransformationCollection? transformations;

  GarmentGeneratorState({
    this.uploadedGarmentImage,
    this.uploadedModelImage,
    this.garmentPaletteColors,
    this.isLoading = false,
    this.transformations,
  });

  static final GarmentGeneratorState initial = GarmentGeneratorState(
    uploadedGarmentImage: null,
    uploadedModelImage: null,
    garmentPaletteColors: null,
    isLoading: false,
    transformations: null,
  );

  GarmentGeneratorState copyWith({
    Object? uploadedGarmentImage = _noSet,
    Object? uploadedModelImage = _noSet,
    Object? garmentPaletteColors = _noSet,
    Object? isLoading = _noSet,
    Object? transformations = _noSet,
  }) {
    return GarmentGeneratorState(
      uploadedGarmentImage: uploadedGarmentImage == _noSet
          ? this.uploadedGarmentImage
          : uploadedGarmentImage as String?,
      uploadedModelImage: uploadedModelImage == _noSet
          ? this.uploadedModelImage
          : uploadedModelImage as String?,
      garmentPaletteColors: garmentPaletteColors == _noSet
          ? this.garmentPaletteColors
          : garmentPaletteColors as List<Color>?,
      isLoading: isLoading == _noSet
          ? this.isLoading
          : isLoading as bool,
      transformations: transformations == _noSet
          ? this.transformations
          : transformations as GarmentTransformationCollection?,
    );
  }

  factory GarmentGeneratorState.empty() {
    return GarmentGeneratorState(
      uploadedGarmentImage: null,
      uploadedModelImage: null,
      garmentPaletteColors: null,
      isLoading: false,
      transformations: null,
    );
  }
}

const Object _noSet = Object();