import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color background;

  const AppColorsExtension({required this.background});
  
  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? background
  }) {
    return AppColorsExtension(background: background ?? this.background);
  }
  
  @override
  ThemeExtension<AppColorsExtension> lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(background: Color.lerp(background, other.background, t)!);
  }
}