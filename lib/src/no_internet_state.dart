import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'state_layout.dart';

/// Shown when the app can't reach the network.
///
/// ```dart
/// NoInternetState(onRetry: _reconnect)
/// ```
///
/// It's essentially an error state tuned for connectivity, with its own icon
/// and copy. Pass [onRetry] to show the retry button.
class NoInternetState extends StatelessWidget {
  const NoInternetState({
    super.key,
    this.onRetry,
    this.retryText = 'Retry',
    this.icon = Icons.wifi_off_rounded,
    this.iconWidget,
    this.title = 'No internet connection',
    this.message = 'Please check your connection and try again.',
    this.secondaryActionText,
    this.onSecondaryAction,
    this.onRefresh,
    this.iconSize,
    this.spacing,
    this.padding,
    this.maxContentWidth,
    this.textAlign,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonStyle,
    this.secondaryButtonStyle,
    this.animate,
    this.animationDuration,
  });

  /// Called when the retry button is tapped. No button is shown when null.
  /// Returning a [Future] makes the button show inline progress until it
  /// completes.
  final FutureOr<void> Function()? onRetry;

  /// Label for the retry button.
  final String retryText;

  /// {@macro fes.icon}
  final IconData? icon;

  /// {@macro fes.iconWidget}
  final Widget? iconWidget;

  /// {@macro fes.title}
  final String? title;

  /// {@macro fes.message}
  final String? message;

  /// {@macro fes.secondaryActionText}
  final String? secondaryActionText;

  /// {@macro fes.onSecondaryAction}
  final FutureOr<void> Function()? onSecondaryAction;

  /// {@macro fes.onRefresh}
  final Future<void> Function()? onRefresh;

  /// {@macro fes.iconSize}
  final double? iconSize;

  /// {@macro fes.spacing}
  final double? spacing;

  /// {@macro fes.padding}
  final EdgeInsetsGeometry? padding;

  /// {@macro fes.maxContentWidth}
  final double? maxContentWidth;

  /// {@macro fes.textAlign}
  final TextAlign? textAlign;

  /// {@macro fes.iconColor}
  final Color? iconColor;

  /// {@macro fes.titleStyle}
  final TextStyle? titleStyle;

  /// {@macro fes.messageStyle}
  final TextStyle? messageStyle;

  /// {@macro fes.buttonStyle}
  final ButtonStyle? buttonStyle;

  /// {@macro fes.secondaryButtonStyle}
  final ButtonStyle? secondaryButtonStyle;

  /// {@macro fes.animate}
  final bool? animate;

  /// {@macro fes.animationDuration}
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context) {
    return StateLayout(
      icon: icon,
      iconWidget: iconWidget,
      title: title,
      message: message,
      // Map the connectivity-specific API onto the shared action slot.
      actionText: retryText,
      onAction: onRetry,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      onRefresh: onRefresh,
      iconSize: iconSize,
      spacing: spacing,
      padding: padding,
      maxContentWidth: maxContentWidth,
      textAlign: textAlign,
      iconColor: iconColor,
      titleStyle: titleStyle,
      messageStyle: messageStyle,
      buttonStyle: buttonStyle,
      secondaryButtonStyle: secondaryButtonStyle,
      animate: animate,
      animationDuration: animationDuration,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      FlagProperty('retry', value: onRetry != null, ifTrue: 'tappable'),
    );
  }
}
