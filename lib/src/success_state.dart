import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'empty_state_theme.dart';
import 'state_layout.dart';

/// A positive, "you're all done" state — order placed, file uploaded, form
/// submitted.
///
/// ```dart
/// SuccessState(
///   title: 'Order placed',
///   message: 'We\'ll email you a receipt shortly.',
///   actionText: 'Back to home',
///   onAction: _goHome,
/// )
/// ```
///
/// It's the same layout as the other states, just tuned for good news: a
/// check icon that defaults to the theme's primary colour instead of the
/// muted grey the error/empty states use.
class SuccessState extends StatelessWidget {
  const SuccessState({
    super.key,
    this.icon = Icons.check_circle_outline_rounded,
    this.iconWidget,
    this.title = 'All done',
    this.message,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
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

  /// {@macro fes.actionText}
  final String? actionText;

  /// {@macro fes.onAction}
  final FutureOr<void> Function()? onAction;

  /// {@macro fes.secondaryActionText}
  final String? secondaryActionText;

  /// {@macro fes.onSecondaryAction}
  final FutureOr<void> Function()? onSecondaryAction;

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

  /// Icon colour. Falls back to the [EmptyStateTheme], then the theme's
  /// primary colour (not the muted grey, since this is good news).
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
    final theme = Theme.of(context);
    // Same precedence as everywhere else (explicit arg > theme > default), but
    // the built-in default is the primary colour so success reads as positive.
    final resolvedIconColor = iconColor ??
        theme.extension<EmptyStateTheme>()?.iconColor ??
        theme.colorScheme.primary;
    return StateLayout(
      icon: icon,
      iconWidget: iconWidget,
      title: title,
      message: message,
      actionText: actionText,
      onAction: onAction,
      secondaryActionText: secondaryActionText,
      onSecondaryAction: onSecondaryAction,
      iconSize: iconSize,
      spacing: spacing,
      padding: padding,
      maxContentWidth: maxContentWidth,
      textAlign: textAlign,
      iconColor: resolvedIconColor,
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
      ..add(
          FlagProperty('action', value: onAction != null, ifTrue: 'tappable'));
  }
}
