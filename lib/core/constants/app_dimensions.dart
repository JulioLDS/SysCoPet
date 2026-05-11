import 'package:flutter/material.dart';

class AppDimensions {
  // Border Radius
  static const borderRadiusSm = 8.0;
  static const borderRadius = 16.0;
  static const borderRadiusLg = 24.0;
  static const borderRadiusXl = 32.0;

  // Padding e Margin
  static const paddingSm = 8.0;
  static const padding = 16.0;
  static const paddingLg = 24.0;
  static const paddingXl = 32.0;

  static const marginSm = 8.0;
  static const margin = 16.0;
  static const marginLg = 24.0;

  // Heights
  static const buttonHeight = 50.0;
  static const inputHeight = 50.0;
  static const appBarHeight = 56.0;

  // Shadows
  static BoxShadow get shadowSm =>
      const BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 2));

  static BoxShadow get shadow => const BoxShadow(
    color: Colors.black,
    blurRadius: 20,
    offset: Offset(0, 10),
  );

  static BoxShadow get shadowLg => const BoxShadow(
    color: Colors.black,
    blurRadius: 30,
    offset: Offset(0, 15),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 20,
    offset: const Offset(0, 10),
  );

  // Opacidades
  static double get opacityDisabled => 0.5;
  static double get opacityHover => 0.9;
}
