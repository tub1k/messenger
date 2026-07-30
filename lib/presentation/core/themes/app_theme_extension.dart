import 'package:flutter/material.dart';

class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color leaveDeleteColor;
  final Color halfOpaqueText;
  final Color defaultButtonColor;
  final Color dateDividerBg;
  final Color newMessageDotColor;
  final Color messageText;
  final Color incomingMessageBG;
  final Color outgoingMessageBG;

  const AppColorsExtension({
    required this.leaveDeleteColor,
    required this.halfOpaqueText, 
    required this.defaultButtonColor, 
    required this.dateDividerBg,
    required this.newMessageDotColor, 
    required this.messageText,
    required this.incomingMessageBG,
    required this.outgoingMessageBG,
  });

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? leaveDeleteColor,
    Color? halfOpaqueText,
    Color? defaultButtonColor,
    Color? dateDividerBg,
    Color? newMessageDotColor,
    Color? messageText,
    Color? incomingMessageBG,
    Color? outgoingMessageBG,
  }) {
    return AppColorsExtension(
      leaveDeleteColor: leaveDeleteColor ?? this.leaveDeleteColor,
      halfOpaqueText: halfOpaqueText ?? this.halfOpaqueText,
      defaultButtonColor: defaultButtonColor ?? this.defaultButtonColor,
      dateDividerBg: dateDividerBg ?? this.dateDividerBg,
      newMessageDotColor: newMessageDotColor ?? this.newMessageDotColor,
      messageText: messageText ?? this.messageText,
      incomingMessageBG: incomingMessageBG ?? this.incomingMessageBG,
      outgoingMessageBG: outgoingMessageBG ?? this.outgoingMessageBG,
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
      messageText: Color.lerp(messageText, other.messageText, t)!,
      incomingMessageBG: Color.lerp(incomingMessageBG, other.incomingMessageBG, t)!,
      outgoingMessageBG: Color.lerp(outgoingMessageBG, other.outgoingMessageBG, t)!,
    );
  }
}