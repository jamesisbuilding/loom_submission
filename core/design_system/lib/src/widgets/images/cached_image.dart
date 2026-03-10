import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A network image with caching, shimmer placeholder, and error fallback.
class CachedImage extends StatelessWidget {
  const CachedImage({
    super.key,
    required this.url,
    this.fit,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final BoxFit? fit;

  bool isLikelyNetworkUrl(String url) {
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('ftp://') ||
        url.startsWith('www.');
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty || !isLikelyNetworkUrl(url)) {
      return _errorWidget(context);
    }
    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          image: DecorationImage(image: imageProvider, fit: fit),
        ),
      ),
      placeholder: (context, url) => ShimmerImage(
        width: width,
        height: height,
        borderRadius: borderRadius,
        centerWidget: Icon(
          Icons.image,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      errorWidget: (context, url, error) => _errorWidget(context),
    );
  }

  Widget _errorWidget(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: borderRadius,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
    ),
    alignment: Alignment.center,
    child: Icon(
      Icons.image_not_supported_outlined,
      color: Theme.of(context).colorScheme.primary,
    ),
  );
}

/// Shimmer placeholder for image loading states.
class ShimmerImage extends StatelessWidget {
  const ShimmerImage({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.centerWidget,
  });

  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final Widget? centerWidget;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color.fromARGB(255, 237, 237, 237),
      highlightColor: const Color.fromARGB(255, 255, 255, 255),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: Colors.white,
        ),
        child: Center(child: centerWidget),
      ),
    );
  }
}
