import 'package:flutter/material.dart';

import 'state_layout.dart';

/// A centered spinner with an optional message underneath.
///
/// ```dart
/// LoadingState(message: 'Loading...')
/// ```
///
/// Reuses the same layout (and the same nice centering behaviour) as the other
/// states, so it drops into a `Scaffold`, a `Center` or a `ListView` the same
/// way they do. It's also marked as a live region, so screen readers announce
/// the wait.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.message,
    this.indicator,
    this.indicatorColor,
    this.indicatorSize = 36,
    this.strokeWidth = 4,
    this.spacing,
    this.padding,
    this.maxContentWidth,
    this.textAlign,
    this.messageStyle,
    this.animate,
    this.animationDuration,
  });

  /// Optional text shown below the spinner. Pass null for a bare spinner.
  final String? message;

  /// Swap in your own progress widget instead of the default circular one.
  final Widget? indicator;

  /// Colour of the default spinner. Defaults to the theme's primary colour.
  final Color? indicatorColor;

  /// Diameter of the default spinner. Defaults to `36`.
  final double indicatorSize;

  /// Stroke width of the default spinner. Defaults to `4`.
  final double strokeWidth;

  /// {@macro fes.spacing}
  final double? spacing;

  /// {@macro fes.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro fes.maxContentWidth}
  final double? maxContentWidth;

  /// {@macro fes.textAlign}
  final TextAlign? textAlign;

  /// {@macro fes.messageStyle}
  final TextStyle? messageStyle;

  /// {@macro fes.animate}
  final bool? animate;

  /// {@macro fes.animationDuration}
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context) {
    final spinner = indicator ??
        SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: indicatorColor,
            // Read out by screen readers so the wait isn't silent.
            semanticsLabel: message,
          ),
        );

    // Feed the spinner in as the "icon" so we inherit the shared layout for
    // free — no need to reinvent centering and spacing here.
    return Semantics(
      liveRegion: true,
      child: StateLayout(
        iconWidget: spinner,
        message: message,
        spacing: spacing,
        padding: padding,
        maxContentWidth: maxContentWidth,
        textAlign: textAlign,
        messageStyle: messageStyle,
        animate: animate,
        animationDuration: animationDuration,
      ),
    );
  }
}
