import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_bloc.dart';
import 'package:garment_generator/src/view/bloc/garment_generator_state.dart';
import 'package:garment_generator/src/view/widgets/loading_text_logo.dart';
import 'package:image_background_remover/image_background_remover.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with SingleTickerProviderStateMixin {
  String? _currentPath;
  ImageProvider? _bgRemovedProvider;
  bool _isRemovingBg = false;

  late final AnimationController _pulseController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    BackgroundRemover.instance.initializeOrt();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    BackgroundRemover.instance.dispose();
    super.dispose();
  }

  Future<void> _removeBackgroundFor(String path) async {
    if (_isRemovingBg) return;
    _isRemovingBg = true;
    try {
      final bytes = await File(path).readAsBytes();
      final resultImage = await BackgroundRemover.instance.removeBg(
        Uint8List.fromList(bytes),
      );
      final byteData = await resultImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (!mounted || byteData == null) return;
      setState(() {
        _bgRemovedProvider = MemoryImage(byteData.buffer.asUint8List());
      });
    } catch (_) {
      // Keep original image if background removal fails.
    } finally {
      _isRemovingBg = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GarmentGeneratorBloc, GarmentGeneratorState>(
        builder: (context, state) {
          final palette = state.garmentPaletteColors ?? AppTheme.defaultColors;
          final backgroundColor = palette.first;
          final lineColor = palette.length > 1
              ? palette[1].withValues(alpha: 0.8)
              : palette.first.withValues(alpha: 0.7);

          final path = state.uploadedGarmentImage;
          if (path == null || path.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_currentPath != path) {
            _currentPath = path;
            _bgRemovedProvider = null;
            _removeBackgroundFor(path);
          }

          final originalProvider = FileImage(File(path));
          final displayedProvider = _bgRemovedProvider ?? originalProvider;

          return Stack(
            children: [
              Positioned.fill(
                child: LinearWavesBackground(
                  backgroundColor: backgroundColor,
                  lineColor: lineColor,
                ),
              ),

              Center(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final shadowBlur = 20 + (_pulseController.value * 16);
                    final hasBgRemovedImage = _bgRemovedProvider != null;
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Hero(
                        tag: 'garmentImageHero',
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: hasBgRemovedImage
                                ? const []
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.20,
                                      ),
                                      blurRadius: shadowBlur,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Image(
                                key: ValueKey(
                                  _bgRemovedProvider == null
                                      ? 'orig'
                                      : 'cutout',
                                ),
                                image: displayedProvider,
                                fit: BoxFit.contain,
                                height: 300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 40,
              height: 300,
              child: Center(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.white70,
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: const LoadingTextLogo(),
                ),
              ),
            ),
            ],
          );
        },
      ),
    );
  }
}
