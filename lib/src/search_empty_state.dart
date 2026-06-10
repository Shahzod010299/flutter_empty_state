import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'state_layout.dart';

/// Shown when a search came back with nothing.
///
/// ```dart
/// SearchEmptyState(query: 'iPhone', onClear: _clearSearch)
/// ```
///
/// When [message] is left null it builds a default line that mentions the
/// [query], e.g. `No matches for "iPhone".`. Pass [onClear] to offer a button
/// that resets the search.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    this.query,
    this.onClear,
    this.clearText = 'Clear search',
    this.icon = Icons.search_off_rounded,
    this.iconWidget,
    this.title = 'No results found',
    this.message,
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

  /// The term the user searched for. Used to build the default [message].
  final String? query;

  /// Called when the clear button is tapped. No button is shown when null.
  /// Returning a [Future] makes the button show inline progress until it
  /// completes.
  final FutureOr<void> Function()? onClear;

  /// Label for the clear button.
  final String clearText;

  /// {@macro fes.icon}
  final IconData? icon;

  /// {@macro fes.iconWidget}
  final Widget? iconWidget;

  /// {@macro fes.title}
  final String? title;

  /// Overrides the auto-generated "No matches for ..." line.
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
    final hasQuery = query != null && query!.trim().isNotEmpty;
    final resolvedMessage = message ??
        (hasQuery ? 'No matches for "$query".' : 'Try a different search.');

    return StateLayout(
      icon: icon,
      iconWidget: iconWidget,
      title: title,
      message: resolvedMessage,
      actionText: clearText,
      onAction: onClear,
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
      ..add(StringProperty('query', query, defaultValue: null))
      ..add(FlagProperty('clear', value: onClear != null, ifTrue: 'tappable'));
  }
}
