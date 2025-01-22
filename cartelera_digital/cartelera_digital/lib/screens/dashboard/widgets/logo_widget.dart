import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const LogoWidget({
    this.size = 160.0,
    this.fit = BoxFit.contain,
    this.padding = const EdgeInsets.all(16.0),
    this.alignment = Alignment.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: alignment,
      child: Image.asset(
        'assets/images/Logo_SIMCUV.png',
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}

class CircularLogoWidget extends StatelessWidget {
  final double size;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  const CircularLogoWidget({
    this.size = 160.0,
    this.fit = BoxFit.cover,
    this.padding = const EdgeInsets.all(16.0),
    this.alignment = Alignment.center,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      alignment: alignment,
      child: ClipOval(
        child: Image.asset(
          'assets/images/Logo_SIMCUV.png',
          width: size,
          height: size,
          fit: fit,
        ),
      ),
    );
  }
}
