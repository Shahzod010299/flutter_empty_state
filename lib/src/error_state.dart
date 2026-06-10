import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'state_layout.dart';

/// Shown when something failed and you want to let the user try again.
///
/// ```dart
/// ErrorState(
///   title: 'Something went wrong',
///   message: 'Please try again later.',
///   actionText: 'Retry',
///   onAction: _retry,
/// )
/// ```
///
/// Unlike [EmptyState], [title], [message] and [actionText] default to
/// error-friendly copy, so `ErrorState(onAction: _retry)` already gives you a
/// working retry screen.
///
/// Pass [details] to tuck the raw error behind a collapsed "Details" button —
/// useful in debug builds or for "report a bug" flows:
///
/// ```dart
/// ErrorState(
///   onAction: _retry,
///   details: error.toString(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.icon = Icons.error_outline,
    this.iconWidget,
    this.title = 'Something went wrong',
    this.message = 'Please try again later.',
    this.details,
    this.detailsLabel = 'Details',
    this.actionText = 'Retry',
    this.onAction,
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

  /// {@macro fes.icon}
  final IconData? icon;

  /// {@macro fes.iconWidget}
  final Widget? iconWidget;

  /// {@macro fes.title}
  final String? title;

  /// {@macro fes.message}
  final String? message;

  /// Raw technical details — an exception message, a status code, a stack
  /// trace. Collapsed behind a small [detailsLabel] button so they don't scare
  /// regular users, and selectable once expanded so they can be copied into a
  /// bug report.
  final String? details;

  /// Label for the button that expands [details].
  final String detailsLabel;

  /// {@macro fes.actionText}
  final String? actionText;

  /// {@macro fes.onAction}
  final FutureOr<void> Function()? onAction;

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
      details: details,
      detailsLabel: detailsLabel,
      actionText: actionText,
      onAction: onAction,
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
    properties
      ..add(StringProperty('title', title, defaultValue: null))
      ..add(StringProperty('message', message, defaultValue: null))
      ..add(StringProperty('details', details, defaultValue: null))
      ..add(
          FlagProperty('action', value: onAction != null, ifTrue: 'tappable'));
  }
}
