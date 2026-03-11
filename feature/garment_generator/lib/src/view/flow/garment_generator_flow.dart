import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';
import 'package:garment_generator/src/view/pages/upload_image_page.dart';
import 'package:garment_generator/src/view/pages/loading_page.dart';
import 'package:garment_generator/src/view/pages/results_page.dart';
import 'package:garment_transformation_service/garment_transformation_service.dart';

class GarmentGeneratorFlow extends StatelessWidget {
  const GarmentGeneratorFlow({super.key});

  static MaterialPage get page => MaterialPage(child: GarmentGeneratorFlow());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GarmentGeneratorBloc(
        transformationRepository: GarmentTransformationRepositoryImpl(
          dataSource: const GeminiImageGeneration(),
        ),
      ),
      child: BlocBuilder<GarmentGeneratorBloc, GarmentGeneratorState>(
        builder: (context, state) {
          Widget child;
          Key key;

          // return const LoadingPage();
          if (state.isLoading) {
            child = const LoadingPage();
            key = const ValueKey('loading');
          } else if (state.transformations != null) {
            child = const ResultsPage();
            key = const ValueKey('results');
          } else {
            child = const UploadImagePage();
            key = const ValueKey('upload');
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (widget, animation) {
              return FadeTransition(
                opacity: animation,
                child: widget,
              );
            },
            child: KeyedSubtree(
              key: key,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
