import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color leaveDeleteColor;
  final Color halfOpaqueText;
  final Color defaultButtonColor;
  final Color dateDividerBg;
  final Color newMessageDotColor;

  const AppColorsExtension({
    required this.leaveDeleteColor,
    required this.halfOpaqueText, 
    required this.defaultButtonColor, required this.dateDividerBg,
    required this.newMessageDotColor,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? leaveDeleteColor,
    Color? halfOpaqueText,
    Color? defaultButtonColor,
    Color? dateDividerBg,
    Color? newMessageDotColor,
  }) {
    return AppColorsExtension(
      leaveDeleteColor: leaveDeleteColor ?? this.leaveDeleteColor,
      halfOpaqueText: halfOpaqueText ?? this.halfOpaqueText,
      defaultButtonColor: defaultButtonColor ?? this.defaultButtonColor,
      dateDividerBg: dateDividerBg ?? this.dateDividerBg,
      newMessageDotColor: newMessageDotColor ?? this.newMessageDotColor,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    covariant ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      leaveDeleteColor: Color.lerp(
        leaveDeleteColor,
        other.leaveDeleteColor,
        t,
      )!,
      halfOpaqueText: Color.lerp(halfOpaqueText, other.halfOpaqueText, t)!,
      defaultButtonColor: Color.lerp(defaultButtonColor, other.defaultButtonColor, t)!,
      dateDividerBg: Color.lerp(dateDividerBg, other.dateDividerBg, t)!,
      newMessageDotColor: Color.lerp(newMessageDotColor, other.newMessageDotColor, t)!,
    );
  }
}
