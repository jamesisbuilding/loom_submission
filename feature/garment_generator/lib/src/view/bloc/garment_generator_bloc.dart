import 'dart:io';

import 'package:garment_transformation_service/garment_transformation_service.dart';
import 'package:image_palette_service/image_palette_service.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_event.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';

class GarmentGeneratorBloc
    extends Bloc<GarmentGeneratorEvent, GarmentGeneratorState> {
  GarmentGeneratorBloc({
    required GarmentTransformationRepository transformationRepository,
    ImagePaletteService paletteService = const ImagePaletteService(),
  })  : _transformationRepository = transformationRepository,
        _paletteService = paletteService,
        super(GarmentGeneratorState.initial) {
    on<UploadImageEvent>(_onUploadImageEvent);
    on<ClearUploadedGarmentImageEvent>(_onClearUploadedGarmentImageEvent);
    on<BeginGenerationEvent>(_onBeginGenerationEvent);
  }

  final GarmentTransformationRepository _transformationRepository;
  final ImagePaletteService _paletteService;

  Future<void> _onUploadImageEvent(
    UploadImageEvent event,
    Emitter<GarmentGeneratorState> emit,
  ) async {
    final path = event.image.path;
    emit(
      state.copyWith(
        uploadedGarmentImage: path,
      ),
    );

    try {
      final bytes = await File(path).readAsBytes();
      final extracted = _paletteService.extractRandomColorsFromBytes(bytes);
      final colors = extracted.length >= 4 ? extracted : AppTheme.defaultColors;
      if (isClosed) return;
      emit(state.copyWith(garmentPaletteColors: colors));
    } catch (_) {
      // If palette extraction fails, keep background as-is.
    }
  }

  void _onClearUploadedGarmentImageEvent(
    ClearUploadedGarmentImageEvent event,
    Emitter<GarmentGeneratorState> emit,
  ) {
    emit(
      state.copyWith(
        uploadedGarmentImage: null,
        garmentPaletteColors: null,
        isLoading: false,
        transformations: null,
      ),
    );
  }

  Future<void> _onBeginGenerationEvent(
    BeginGenerationEvent event,
    Emitter<GarmentGeneratorState> emit,
  ) async {
    final imagePath = state.uploadedGarmentImage;
    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        isLoading: true,
        transformations: null,
      ),
    );

    try {
      // Simulate network / processing delay while we are still
      // wiring up the real implementation.
      await Future.delayed(const Duration(seconds: 5));

      final analysis = await _transformationRepository.analyseGarment(
        originalGarmentImage: imagePath,
      );

      final ideas = await _transformationRepository.ideateGarment(
        garmentAnalysis: analysis,
        originalGarmentImage: imagePath,
      );

      final transforms =
          await _transformationRepository.generateGarmentTransformations(
        garmentIdeas: ideas,
        originalGarmentImage: imagePath,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          isLoading: false,
          transformations: transforms,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoading: false,
          transformations: null,
        ),
      );
    }
  }
}


