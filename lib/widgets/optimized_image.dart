import 'package:flutter/material.dart';

class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth,
    this.cacheHeight,
    this.borderRadius,
  });
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

// Preload critical images for better performance
class ImagePreloader {
  static final Set<String> _preloadedImages = {};

  static Future<void> preloadCriticalImages(BuildContext context) async {
    final criticalImages = [
      'assets/HAS.png',
      'assets/avater.png',
      'assets/background.jpg',
      'assets/Bot.jpg',
      'assets/Mag.jpg',
    ];

    for (final imagePath in criticalImages) {
      if (!_preloadedImages.contains(imagePath)) {
        try {
          await precacheImage(AssetImage(imagePath), context);
          _preloadedImages.add(imagePath);
        } catch (e) {
          debugPrint('Failed to preload $imagePath: $e');
        }
      }
    }
  }
}
