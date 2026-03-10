import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_event.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';
import 'package:garment_generator/src/view/widgets/begin_close_morph_button.dart';
import 'package:garment_generator/src/view/widgets/custom_upload_widget.dart';
import 'package:garment_generator/src/view/widgets/fade_overlay.dart';
import 'package:garment_generator/src/view/widgets/text_logo.dart';

class UploadImagePage extends StatefulWidget {
  const UploadImagePage({super.key});

  static MaterialPage get page => MaterialPage(child: UploadImagePage());

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  bool _expanded = false;
  late final ValueNotifier<List<Color>> _backgroundColors;

  @override
  void initState() {
    super.initState();
    _backgroundColors = ValueNotifier<List<Color>>(AppTheme.defaultColors);
  }

  @override
  void dispose() {
    _backgroundColors.dispose();
    super.dispose();
  }

  _toggleExpanded({required bool value}) {
    _expanded = value;
    setState(() {});
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
            TextLogo(expanded: _expanded),
            FadeOverlay(visible: _expanded),
            const GrainBackground(opacity: 0.2),
            CustomUploadWidget(
              visible: _expanded,
              onGenerate: () {
                context
                    .read<GarmentGeneratorBloc>()
                    .add(BeginGenerationEvent());
              },
            ),
            BeginCloseMorphButton(
              expanded: _expanded,
              onBegin: () {
                _toggleExpanded(value: true);
              },
              onClose: () {
                context.read<GarmentGeneratorBloc>().add(
                  ClearUploadedGarmentImageEvent(),
                );
                _toggleExpanded(value: false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
