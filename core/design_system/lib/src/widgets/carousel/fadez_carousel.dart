import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:design_system/src/widgets/images/cached_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const int _kMaxVisible = 3;

class FadezCarousel extends StatefulWidget {
  const FadezCarousel({
    super.key,
    required this.imageUrls,
    this.backgroundColor = const Color(0xFFF9F5F6),
  });

  final List<String> imageUrls;
  final Color backgroundColor;

  @override
  State<FadezCarousel> createState() => _FadezCarouselState();
}

class _FadezCarouselState extends State<FadezCarousel>
    with TickerProviderStateMixin {
  static const double _dragExtent = 250.0;
  static const double _commitThreshold = 0.35;

  late List<int> _order;

  late final AnimationController _exitCtrl;
  late final AnimationController _fadeCtrl;
  late final Animation<Offset> _exitSlide;
  late final Animation<double> _exitFade;
  late final Animation<double> _exitScale;

  bool _isDragging = false;
  bool _isAnimating = false;
  bool _isCancelling = false;
  int? _exitingCardId;

  @override
  void initState() {
    super.initState();
    _order = List.generate(_effectiveCardCount, (i) => i);
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _exitSlide = _exitCtrl
        .drive(CurveTween(curve: Curves.easeInCubic))
        .drive(Tween(begin: Offset.zero, end: const Offset(0, 0.7)));

    _exitFade = _fadeCtrl
        .drive(CurveTween(curve: Curves.easeIn))
        .drive(Tween(begin: 1.0, end: 0.0));

    _exitScale = _exitCtrl
        .drive(CurveTween(curve: Curves.easeInCubic))
        .drive(Tween(begin: 1.0, end: 1.75));
  }

  @override
  void didUpdateWidget(covariant FadezCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.imageUrls, widget.imageUrls)) {
      _order = List.generate(_effectiveCardCount, (i) => i);
      _exitingCardId = null;
      _isDragging = false;
      _isAnimating = false;
      _isCancelling = false;
      _resetControllers();
    }
  }

  int get _effectiveCardCount =>
      math.max(widget.imageUrls.length, _kMaxVisible + 1);

  // Render only as many back cards as real outputs.
  int get _visibleBackCount {
    final backCount = widget.imageUrls.length - 1;
    return backCount < _kMaxVisible ? backCount : _kMaxVisible;
  }

  String _imageForOrderId(int id) {
    if (widget.imageUrls.isEmpty) return '';
    return widget.imageUrls[id % widget.imageUrls.length];
  }

  @override
  void dispose() {
    _exitCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _resetControllers() {
    _exitCtrl.value = 0;
    _fadeCtrl.value = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    final delta = details.primaryDelta ?? 0;
    if (delta < 0 && _exitCtrl.value <= 0) return;

    if (!_isDragging && delta > 0) {
      _isDragging = true;
      _exitingCardId = _order.removeAt(0);
      _order.add(_exitingCardId!);
      setState(() {});
    }

    if (!_isDragging || _exitingCardId == null) return;

    final progress = (_exitCtrl.value + delta / _dragExtent).clamp(0.0, 1.0);
    _exitCtrl.value = progress;
    _fadeCtrl.value = progress;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!_isDragging || _exitingCardId == null) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0;
    final committed = _exitCtrl.value >= _commitThreshold || velocity > 500;

    if (committed) {
      _isCancelling = false;
      _isAnimating = true;
      _exitCtrl.forward().then((_) {
        setState(() {
          _isAnimating = false;
          _exitingCardId = null;
        });
        _resetControllers();
      });
      _fadeCtrl.forward();
    } else {
      _isAnimating = true;
      setState(() => _isCancelling = true);
      _exitCtrl.animateTo(0, duration: const Duration(milliseconds: 200)).then((
        _,
      ) {
        if (_exitingCardId == null) return;
        setState(() {
          _order.remove(_exitingCardId!);
          _order.insert(0, _exitingCardId!);
          _isAnimating = false;
          _isCancelling = false;
          _exitingCardId = null;
        });
        _resetControllers();
      });
      _fadeCtrl.animateTo(0, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return ColoredBox(
      color: widget.backgroundColor,
      child: GestureDetector(
        onVerticalDragUpdate: _onDragUpdate,
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedBuilder(
          animation: _exitCtrl,
          builder: (context, _) {
            final progress = _exitingCardId != null ? _exitCtrl.value : 1.0;
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back cards (position 1+)
                  for (int i = _visibleBackCount; i >= 1; i--)
                    if (i < _order.length && _order[i] != _exitingCardId)
                      _FadezCard(
                        key: ValueKey(_order[i]),
                        stackPosition: i,
                        progress: progress,
                        imageUrl: _imageForOrderId(_order[i]),
                      ),

                  // Blur under front card (normal forward scroll)
                  if (!_isCancelling)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: const SizedBox.expand(),
                      ),
                    ),

                  // Front card (position 0)
                  if (_order.isNotEmpty && _order[0] != _exitingCardId)
                    _FadezCard(
                      key: ValueKey(_order[0]),
                      stackPosition: 0,
                      progress: progress,
                      imageUrl: _imageForOrderId(_order[0]),
                    ),

                  // Blur over front card (cancelling / scrolling back)
                  if (_isCancelling)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                        child: const SizedBox.expand(),
                      ),
                    ),

                  if (_exitingCardId != null)
                    SlideTransition(
                      position: _exitSlide,
                      child: FadeTransition(
                        opacity: _exitFade,
                        child: ScaleTransition(
                          scale: _exitScale,
                          child: AnimatedBuilder(
                            animation: _fadeCtrl,
                            builder: (context, child) {
                              final t = _fadeCtrl.value;
                              final blur = t * 10.0;
                              final shadowOpacity = (t * 0.4).clamp(0.0, 0.4);
                              final shadowBlur = t * 24.0;
                              final shadowOffset = t * 12.0;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: shadowOpacity,
                                      ),
                                      blurRadius: shadowBlur,
                                      offset: Offset(0, shadowOffset),
                                    ),
                                  ],
                                ),
                                child: ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: blur,
                                    sigmaY: blur,
                                  ),
                                  child: child,
                                ),
                              );
                            },
                            child: _FadezCard(
                              key: ValueKey(_exitingCardId),
                              stackPosition: 0,
                              progress: 1.0,
                              imageUrl: _imageForOrderId(_exitingCardId!),
                            ),
                          ),
                        ),
                      ),
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

class _FadezCard extends StatelessWidget {
  final int stackPosition;
  final double progress;
  final String imageUrl;

  const _FadezCard({
    super.key,
    required this.stackPosition,
    required this.progress,
    required this.imageUrl,
  });

  static const double _scaleStep = 0.2;
  static const double _slidePerPos = -0.19;

  bool _isNetworkImage(String value) =>
      value.startsWith('http://') || value.startsWith('https://');

  bool _isLocalFileImage(String value) =>
      value.startsWith('/') || value.startsWith('file://');

  String _normalizeLocalPath(String value) =>
      value.startsWith('file://') ? value.replaceFirst('file://', '') : value;

  Widget _buildImage() {
    if (_isNetworkImage(imageUrl)) {
      return CachedImage(
        url: imageUrl,
        fit: BoxFit.cover,
        width: 300,
        height: 300,
      );
    }

    if (_isLocalFileImage(imageUrl)) {
      return Image.file(
        File(_normalizeLocalPath(imageUrl)),
        fit: BoxFit.cover,
        width: 300,
        height: 300,
      );
    }

    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      width: 300,
      height: 300,
    );
  }

  @override
  Widget build(BuildContext context) {
    final speedUp = 1.0 + stackPosition * 0.6;
    final cardProgress = Curves.decelerate.transform(
      (progress * speedUp).clamp(0.0, 1.0),
    );
    final effectivePos = stackPosition + (1.0 - cardProgress);
    final scale = (1.0 - effectivePos * _scaleStep).clamp(0.0, 1.0);
    final slideY = effectivePos * _slidePerPos;
    final opacity = (_kMaxVisible.toDouble() - effectivePos).clamp(0.0, 1.0);

    Widget card = Container(
      height: 300,
      width: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: _buildImage(),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: FractionalTranslation(
        translation: Offset(0, slideY),
        child: Transform.scale(scale: scale, child: card),
      ),
    );
  }
}
