import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'state_layout.dart';

/// A friendly placeholder for a screen or list that simply has no content yet.
///
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No data found',
///   message: 'There is nothing to show here yet.',
///   actionText: 'Refresh',
///   onAction: _reload,
/// )
/// ```
///
/// The action button only appears when you pass both [actionText] and
/// [onAction].
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.iconWidget,
    this.title = 'Nothing here yet',
    this.message,
    this.actionText,
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

  /// {@template fes.icon}
  /// Material icon shown above the text. Ignored when [iconWidget] is set.
  /// {@endtemplate}
  final IconData? icon;

  /// {@template fes.iconWidget}
  /// A custom illustration to use instead of [icon] — an image, an SVG, a
  /// Lottie animation, anything. Wins over [icon] when both are set.
  /// {@endtemplate}
  final Widget? iconWidget;

  /// {@template fes.title}
  /// The headline. Pass null to hide it.
  /// {@endtemplate}
  final String? title;

  /// {@template fes.message}
  /// The supporting line under the title. Pass null to hide it.
  /// {@endtemplate}
  final String? message;

  /// {@template fes.actionText}
  /// Label for the action button. The button only shows when both this and
  /// [onAction] are set.
  /// {@endtemplate}
  final String? actionText;

  /// {@template fes.onAction}
  /// Called when the action button is tapped. Returning a [Future] makes the
  /// button disable itself and show an inline progress indicator until the
  /// future completes — handy for async retries.
  /// {@endtemplate}
  final FutureOr<void> Function()? onAction;

  /// {@template fes.secondaryActionText}
  /// Label for an optional secondary (text) button under the main action.
  /// Only shows when both this and [onSecondaryAction] are set.
  /// {@endtemplate}
  final String? secondaryActionText;

  /// {@template fes.onSecondaryAction}
  /// Called when the secondary button is tapped. Behaves like [onAction],
  /// including the async progress treatment.
  /// {@endtemplate}
  final FutureOr<void> Function()? onSecondaryAction;

  /// {@template fes.onRefresh}
  /// Enables pull-to-refresh. When set, the state is wrapped in a
  /// [RefreshIndicator] with an always-scrollable viewport, so the user can
  /// pull down to reload even though there's no list on screen.
  /// {@endtemplate}
  final Future<void> Function()? onRefresh;

  /// {@template fes.iconSize}
  /// Icon size. Falls back to the [EmptyStateTheme], then `72`.
  /// {@endtemplate}
  final double? iconSize;

  /// {@template fes.spacing}
  /// Vertical gap between the icon, text and button. Falls back to the
  /// [EmptyStateTheme], then `16`.
  /// {@endtemplate}
  final double? spacing;

  /// {@template fes.padding}
  /// Padding around the whole block. Falls back to the [EmptyStateTheme], then
  /// `EdgeInsets.all(24)`.
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template fes.maxContentWidth}
  /// Caps the content width so text stays readable on tablets and the web.
  /// Falls back to the [EmptyStateTheme], then `320`.
  /// {@endtemplate}
  final double? maxContentWidth;

  /// {@template fes.textAlign}
  /// Alignment for the title and message. Falls back to the [EmptyStateTheme],
  /// then [TextAlign.center].
  /// {@endtemplate}
  final TextAlign? textAlign;

  /// {@template fes.iconColor}
  /// Icon colour. Falls back to the [EmptyStateTheme], then the theme's
  /// `onSurfaceVariant`.
  /// {@endtemplate}
  final Color? iconColor;

  /// {@template fes.titleStyle}
  /// Title text style. Falls back to the [EmptyStateTheme], then the theme's
  /// `titleMedium`.
  /// {@endtemplate}
  final TextStyle? titleStyle;

  /// {@template fes.messageStyle}
  /// Message text style. Falls back to the [EmptyStateTheme], then the theme's
  /// `bodyMedium`.
  /// {@endtemplate}
  final TextStyle? messageStyle;

  /// {@template fes.buttonStyle}
  /// Action-button style. Falls back to the [EmptyStateTheme], then the
  /// [FilledButton] theme.
  /// {@endtemplate}
  final ButtonStyle? buttonStyle;

  /// {@template fes.secondaryButtonStyle}
  /// Style for the secondary [TextButton]. Falls back to the
  /// [EmptyStateTheme], then the ambient [TextButton] theme.
  /// {@endtemplate}
  final ButtonStyle? secondaryButtonStyle;

  /// {@template fes.animate}
  /// Whether to play a subtle fade + slide when the widget first appears.
  /// Defaults to `true` and is skipped automatically when the OS "reduce
  /// motion" accessibility setting is on.
  /// {@endtemplate}
  final bool? animate;

  /// {@template fes.animationDuration}
  /// How long the entrance animation runs. Falls back to the [EmptyStateTheme],
  /// then 350ms.
  /// {@endtemplate}
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context) {
    return StateLayout(
      icon: icon,
      iconWidget: iconWidget,
      title: title,
      message: message,
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
      ..add(DiagnosticsProperty<IconData>('icon', icon, defaultValue: null))
      ..add(
          FlagProperty('action', value: onAction != null, ifTrue: 'tappable'));
  }
}
