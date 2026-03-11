import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_event.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late final ValueNotifier<List<Color>> _backgroundColors;

  @override
  void initState() {
    super.initState();
    _backgroundColors = ValueNotifier<List<Color>>(AppTheme.defaultColors);
    final initialPalette =
        context.read<GarmentGeneratorBloc>().state.garmentPaletteColors;
    if (initialPalette != null && initialPalette.isNotEmpty) {
      _backgroundColors.value = initialPalette;
    }
  }

  @override
  void dispose() {
    _backgroundColors.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<GarmentGeneratorBloc, GarmentGeneratorState>(
        listenWhen: (prev, next) =>
            prev.garmentPaletteColors != next.garmentPaletteColors,
        listener: (context, state) {
          final colors = state.garmentPaletteColors;
          if (colors == null || colors.isEmpty) {
            _backgroundColors.value = AppTheme.defaultColors;
            return;
          }
          _backgroundColors.value = colors;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBackground(colorsListenable: _backgroundColors),
            BlocBuilder<GarmentGeneratorBloc, GarmentGeneratorState>(
              builder: (context, state) {
                final originalImagePath = state.uploadedGarmentImage;
                final urls = state.transformations?.transformedGarments
                        .map((e) => e.imageURL).toList();
                        // .where((e) => e.isNotEmpty)
                        // .where((e) => originalImagePath == null || e != originalImagePath)
                        // .toList() ??
                    // const <String>[];

                return FadezCarousel(
                  imageUrls: urls ?? [],
                  backgroundColor: Colors.transparent,
                );
              },
            ),
            Positioned(
              bottom: 40,
              
              child: Row(
                mainAxisSize: MainAxisSize.max,
                spacing: 12,
                mainAxisAlignment: .spaceBetween,
                children: [
                  _ResultsIconButton(
                    icon: Icons.favorite_border,
                    onTap: () {
                      // TODO: hook up like interaction
                    },
                  ),
                
                  _ResultsPrimaryButton(
                    label: 'Request Remake',
                    onTap: () {
                      context.read<GarmentGeneratorBloc>().add(
                            ClearUploadedGarmentImageEvent(),
                          );
                    },
                  ),
             
                  _ResultsIconButton(
                    icon: Icons.ios_share,
                    onTap: () {
                      // TODO: hook up share interaction
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsIconButton extends StatelessWidget {
  const _ResultsIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.10);
    final border =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.20);

    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassButtonShell(
        borderRadius: 28,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _ResultsPrimaryButton extends StatelessWidget {
  const _ResultsPrimaryButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18);
    final border =
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.30);

    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassButtonShell(
        borderRadius: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: border, width: 0.5),
          ),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}