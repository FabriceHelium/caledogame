import 'package:flutter/material.dart';

class DefaultImage extends StatelessWidget {
  final String imagePath;
  final String fallbackPath;
  final BoxFit fit;
  final double width;
  final double height;

  const DefaultImage({
    Key? key,
    required this.imagePath,
    this.fallbackPath = 'assets/default.jpg',
    this.fit = BoxFit.cover,
    this.width = double.infinity,
    this.height = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackPath,
          fit: fit,
          width: width,
          height: height,
        );
      },
    );
  }
}
