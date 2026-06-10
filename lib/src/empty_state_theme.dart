import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// App-wide defaults for the flutter_empty_state widgets.
///
/// Register it once in your [ThemeData] and every state widget picks it up, so
/// you don't have to repeat the same `iconColor:` / `spacing:` on every screen:
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [
///       EmptyStateTheme(iconColor: Colors.teal, spacing: 20),
///     ],
///   ),
/// )
/// ```
///
/// Resolution order for every property is: the value passed to the widget
/// directly, then this theme, then the package's built-in default. In other
/// words an explicit `EmptyState(iconColor: Colors.red)` always wins, and the
/// theme only fills in what you left out.
@immutable
class EmptyStateTheme extends ThemeExtension<EmptyStateTheme> {
  const EmptyStateTheme({
    this.iconColor,
    this.iconSize,
    this.spacing,
    this.padding,
    this.maxContentWidth,
    this.textAlign,
    this.titleStyle,
    this.messageStyle,
    this.buttonStyle,
    this.secondaryButtonStyle,
    this.animate,
    this.animationDuration,
    this.skeletonBaseColor,
    this.skeletonHighlightColor,
  });

  /// Default icon colour.
  final Color? iconColor;

  /// Default icon size.
  final double? iconSize;

  /// Default vertical spacing between the icon, text and button.
  final double? spacing;

  /// Default padding around the content.
  final EdgeInsetsGeometry? padding;

  /// Default cap on the content width (keeps long text readable on big screens).
  final double? maxContentWidth;

  /// Default alignment for the title and message.
  final TextAlign? textAlign;

  /// Default title text style.
  final TextStyle? titleStyle;

  /// Default message text style.
  final TextStyle? messageStyle;

  /// Default action-button style.
  final ButtonStyle? buttonStyle;

  /// Default style for the secondary (text) action button.
  final ButtonStyle? secondaryButtonStyle;

  /// Whether the entrance animation plays by default.
  final bool? animate;

  /// Default entrance-animation duration.
  final Duration? animationDuration;

  /// Base colour of [Skeleton] shapes and the shimmer. Defaults to a blend of
  /// the colour scheme's `surface` and `onSurface`.
  final Color? skeletonBaseColor;

  /// Colour of the moving shimmer highlight. Defaults to a lighter blend of
  /// the colour scheme's `surface` and `onSurface`.
  final Color? skeletonHighlightColor;

  @override
  EmptyStateTheme copyWith({
    Color? iconColor,
    double? iconSize,
    double? spacing,
    EdgeInsetsGeometry? padding,
    double? maxContentWidth,
    TextAlign? textAlign,
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    ButtonStyle? buttonStyle,
    ButtonStyle? secondaryButtonStyle,
    bool? animate,
    Duration? animationDuration,
    Color? skeletonBaseColor,
    Color? skeletonHighlightColor,
  }) {
    return EmptyStateTheme(
      iconColor: iconColor ?? this.iconColor,
      iconSize: iconSize ?? this.iconSize,
      spacing: spacing ?? this.spacing,
      padding: padding ?? this.padding,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      textAlign: textAlign ?? this.textAlign,
      titleStyle: titleStyle ?? this.titleStyle,
      messageStyle: messageStyle ?? this.messageStyle,
      buttonStyle: buttonStyle ?? this.buttonStyle,
      secondaryButtonStyle: secondaryButtonStyle ?? this.secondaryButtonStyle,
      animate: animate ?? this.animate,
      animationDuration: animationDuration ?? this.animationDuration,
      skeletonBaseColor: skeletonBaseColor ?? this.skeletonBaseColor,
      skeletonHighlightColor:
          skeletonHighlightColor ?? this.skeletonHighlightColor,
    );
  }

  @override
  EmptyStateTheme lerp(covariant EmptyStateTheme? other, double t) {
    if (other == null) return this;
    return EmptyStateTheme(
      iconColor: Color.lerp(iconColor, other.iconColor, t),
      iconSize: lerpDouble(iconSize, other.iconSize, t),
      spacing: lerpDouble(spacing, other.spacing, t),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
      buttonStyle: ButtonStyle.lerp(buttonStyle, other.buttonStyle, t),
      secondaryButtonStyle:
          ButtonStyle.lerp(secondaryButtonStyle, other.secondaryButtonStyle, t),
      skeletonBaseColor:
          Color.lerp(skeletonBaseColor, other.skeletonBaseColor, t),
      skeletonHighlightColor:
          Color.lerp(skeletonHighlightColor, other.skeletonHighlightColor, t),
      // These can't be interpolated, so flip them at the halfway point.
      textAlign: t < 0.5 ? textAlign : other.textAlign,
      animate: t < 0.5 ? animate : other.animate,
      animationDuration: t < 0.5 ? animationDuration : other.animationDuration,
    );
  }

  // Value equality so an identical theme doesn't trigger needless rebuilds and
  // so it behaves predictably in tests.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmptyStateTheme &&
        other.iconColor == iconColor &&
        other.iconSize == iconSize &&
        other.spacing == spacing &&
        other.padding == padding &&
        other.maxContentWidth == maxContentWidth &&
        other.textAlign == textAlign &&
        other.titleStyle == titleStyle &&
        other.messageStyle == messageStyle &&
        other.buttonStyle == buttonStyle &&
        other.secondaryButtonStyle == secondaryButtonStyle &&
        other.animate == animate &&
        other.animationDuration == animationDuration &&
        other.skeletonBaseColor == skeletonBaseColor &&
        other.skeletonHighlightColor == skeletonHighlightColor;
  }

  @override
  int get hashCode => Object.hash(
        iconColor,
        iconSize,
        spacing,
        padding,
        maxContentWidth,
        textAlign,
        titleStyle,
        messageStyle,
        buttonStyle,
        secondaryButtonStyle,
        animate,
        animationDuration,
        skeletonBaseColor,
        skeletonHighlightColor,
      );
}
