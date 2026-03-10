import 'dart:io';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_event.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';
import 'package:image_picker/image_picker.dart';

class CustomUploadWidget extends StatefulWidget {
  final bool visible;
  final VoidCallback onGenerate;

  const CustomUploadWidget({
    super.key,
    required this.visible,
    required this.onGenerate,
  });

  @override
  State<CustomUploadWidget> createState() => _CustomUploadWidgetState();
}

class _CustomUploadWidgetState extends State<CustomUploadWidget> {
  late bool _expanded;
  final ImagePicker _imagePicker = ImagePicker();

  String? _imagePath;
  double? _imageAspectRatio;

  @override
  void initState() {
    super.initState();
    _expanded = widget.visible;
  }

  @override
  void didUpdateWidget(covariant CustomUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.visible != oldWidget.visible) {
      setState(() {
        _expanded = widget.visible;
      });
    }
  }

  Future<void> _onUploadTap() async {
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (!mounted) return;
    if (pickedImage == null) {
      context.read<GarmentGeneratorBloc>().add(
        ClearUploadedGarmentImageEvent(),
      );
      return;
    }

    context.read<GarmentGeneratorBloc>().add(
      UploadImageEvent(image: pickedImage),
    );
  }

  Future<void> _updateImage(String path) async {
    if (!mounted) return;

    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      if (!mounted) return;

      setState(() {
        _imagePath = path;
        _imageAspectRatio = image.width == 0 || image.height == 0
            ? null
            : image.width / image.height;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _imagePath = null;
        _imageAspectRatio = null;
      });
    }
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Assets.icons.newGarment.designImage(
          height: 100,
          color: AppTheme.periwinkle,
        ),
        SizedBox(height: 16),
        Text('Upload Garment Image'),
      ],
    );
  }

  Widget _buildImageContent() {
    if (_imagePath == null || _imageAspectRatio == null) {
      return _buildPlaceholder();
    }

    return AspectRatio(
      aspectRatio: _imageAspectRatio!,
      child: Hero(
        tag: 'garmentImageHero',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(File(_imagePath!), fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _expanded ? 1 : 0.3,
      duration: animationDuration,
      curve: animationCurveLarge,
      child: Opacity(
        opacity: _expanded ? 1 : 0,
        child: BlocBuilder<GarmentGeneratorBloc, GarmentGeneratorState>(
          builder: (context, state) {
            final garmentPath = state.uploadedGarmentImage;
            if (garmentPath != null && garmentPath != _imagePath) {
              _updateImage(garmentPath);
            }
            if (garmentPath == null && _imagePath != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _imagePath = null;
                  _imageAspectRatio = null;
                });
              });
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                spacing: 20,
                mainAxisAlignment: .center,
                children: [
                  UploadTile(
                    shimmerEnabled: state.uploadedGarmentImage == null,
                    onTap: _onUploadTap,
                    child: GyroParallaxCard(
                      enabled: _imagePath != null && _imageAspectRatio != null,
                      child: _imagePath != null && _imageAspectRatio != null
                          ? _buildImageContent()
                          : _buildPlaceholder(),
                    ),
                  ),
                  if (state.uploadedGarmentImage != null)
                    MainButton(
                      onTap: widget.onGenerate,
                      label: 'Generate Variations (3)',
                      animateIn: false,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
