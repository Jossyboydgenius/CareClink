import 'package:flutter/material.dart';

class AppImageData {
  static const _base = 'assets/images';
  static const String careclinkLogo = '$_base/careclink_logo.png';
  static const String logo = '$_base/logo.png';
}

class AppImages extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final BoxFit? fit;

  const AppImages({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _errorWidget();
      },
    );
  }

  Widget _errorWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey.withOpacity(0.4),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.red,
        ),
      ),
    );
  }
} 
