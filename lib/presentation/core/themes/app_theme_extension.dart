import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color leaveDeleteColor;

  const AppColorsExtension({required this.leaveDeleteColor});
  
  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? leaveDeleteColor
  }) {
    return AppColorsExtension(leaveDeleteColor: leaveDeleteColor ?? this.leaveDeleteColor);
  }
  
  @override
  ThemeExtension<AppColorsExtension> lerp(covariant ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(leaveDeleteColor: Color.lerp(leaveDeleteColor, other.leaveDeleteColor, t)!);
  }
}