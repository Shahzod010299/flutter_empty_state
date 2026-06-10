import 'dart:async';

import 'package:flutter/material.dart';

import 'empty_state_theme.dart';

/// The shared skeleton behind every state widget in this package.
///
/// It resolves styling (explicit argument > [EmptyStateTheme] > built-in
/// default), stacks an optional icon, title, message, details section and up
/// to two action buttons, plays a subtle entrance animation and takes care of
/// centering. With [onRefresh] set it also wraps itself in a
/// [RefreshIndicator] so the state can be pulled to reload.
///
/// It's intentionally kept out of the public API — the named widgets wrap it
/// and hand it nice defaults, so callers never touch it directly.
class StateLayout extends StatelessWidget {
  const StateLayout({
    super.key,
    this.icon,
    this.iconWidget,
    this.title,
    this.message,
    this.details,
    this.detailsLabel,
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

  final IconData? icon;
  final Widget? iconWidget;
  final String? title;
  final String? message;
  final String? details;
  final String? detailsLabel;
  final String? actionText;
  final FutureOr<void> Function()? onAction;
  final String? secondaryActionText;
  final FutureOr<void> Function()? onSecondaryAction;
  final Future<void> Function()? onRefresh;
  final double? iconSize;
  final double? spacing;
  final EdgeInsetsGeometry? padding;
  final double? maxContentWidth;
  final TextAlign? textAlign;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final ButtonStyle? buttonStyle;
  final ButtonStyle? secondaryButtonStyle;
  final bool? animate;
  final Duration? animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ext = theme.extension<EmptyStateTheme>();

    // Resolution order everywhere: explicit argument > EmptyStateTheme > default.
    final iconSize = this.iconSize ?? ext?.iconSize ?? 72.0;
    final spacing = this.spacing ?? ext?.spacing ?? 16.0;
    final padding = this.padding ?? ext?.padding ?? const EdgeInsets.all(24);
    final maxWidth = maxContentWidth ?? ext?.maxContentWidth ?? 320.0;
    final textAlign = this.textAlign ?? ext?.textAlign ?? TextAlign.center;
    final iconColor =
        this.iconColor ?? ext?.iconColor ?? scheme.onSurfaceVariant;
    final titleStyle = this.titleStyle ??
        ext?.titleStyle ??
        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    final messageStyle = this.messageStyle ??
        ext?.messageStyle ??
        theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    final buttonStyle = this.buttonStyle ?? ext?.buttonStyle;
    final secondaryButtonStyle =
        this.secondaryButtonStyle ?? ext?.secondaryButtonStyle;
    final animate = this.animate ?? ext?.animate ?? true;
    final duration = animationDuration ??
        ext?.animationDuration ??
        const Duration(milliseconds: 350);

    final children = <Widget>[];

    // A custom widget always wins; otherwise we draw the Material icon.
    if (iconWidget != null) {
      children.add(iconWidget!);
    } else if (icon != null) {
      // Muted on purpose: the icon sets the mood, the text does the talking.
      children.add(Icon(icon, size: iconSize, color: iconColor));
    }

    if (title != null) {
      if (children.isNotEmpty) children.add(SizedBox(height: spacing));
      children.add(Text(title!, textAlign: textAlign, style: titleStyle));
    }

    if (message != null) {
      if (children.isNotEmpty) children.add(SizedBox(height: spacing / 2));
      children.add(Text(message!, textAlign: textAlign, style: messageStyle));
    }

    if (details != null) {
      children.add(SizedBox(height: spacing / 2));
      children.add(
        _DetailsSection(details: details!, label: detailsLabel ?? 'Details'),
      );
    }

    // A button only shows when there's both a label and something to do.
    final hasAction = onAction != null && actionText != null;
    final hasSecondary =
        onSecondaryAction != null && secondaryActionText != null;

    if (hasAction || hasSecondary) {
      children.add(SizedBox(height: spacing * 1.5));
    }
    if (hasAction) {
      children.add(
        _ActionButton(
          label: actionText!,
          onPressed: onAction!,
          style: buttonStyle,
        ),
      );
    }
    if (hasSecondary) {
      if (hasAction) children.add(SizedBox(height: spacing / 2));
      children.add(
        _ActionButton.secondary(
          label: secondaryActionText!,
          onPressed: onSecondaryAction!,
          style: secondaryButtonStyle,
        ),
      );
    }

    final content = Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );

    Widget result;
    if (onRefresh != null) {
      // Pull-to-refresh needs a scroll view even when the content doesn't
      // fill the screen, so we always provide a scrollable viewport and
      // stretch it to at least the available height to keep the centering.
      result = RefreshIndicator(
        onRefresh: onRefresh!,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!constraints.hasBoundedHeight) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: content,
              );
            }
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(child: content),
              ),
            );
          },
        ),
      );
    } else {
      // Center ourselves when the parent gives us a bounded height (Scaffold
      // body, Center, Expanded...). Inside a scrollable the height is infinite
      // and Center would throw, so there we just return the column as-is.
      result = LayoutBuilder(
        builder: (context, constraints) {
          if (!constraints.hasBoundedHeight) return content;
          return Center(child: content);
        },
      );
    }

    if (animate) {
      result = _EntranceAnimation(duration: duration, child: result);
    }
    return result;
  }
}

/// The action button used by every state widget.
///
/// When the callback returns a [Future] the button disables itself and shows
/// a small inline progress indicator until the future completes, so an async
/// retry gets sensible feedback for free.
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.style,
  }) : secondary = false;

  const _ActionButton.secondary({
    required this.label,
    required this.onPressed,
    this.style,
  }) : secondary = true;

  final String label;
  final FutureOr<void> Function() onPressed;
  final ButtonStyle? style;
  final bool secondary;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _busy = false;

  Future<void> _handlePressed() async {
    final result = widget.onPressed();
    if (result is! Future) return; // sync callback: nothing to wait for
    setState(() => _busy = true);
    try {
      await result;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _busy
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(widget.label),
            ],
          )
        : Text(widget.label);

    final onPressed = _busy ? null : _handlePressed;
    return widget.secondary
        ? TextButton(onPressed: onPressed, style: widget.style, child: child)
        : FilledButton(onPressed: onPressed, style: widget.style, child: child);
  }
}

/// A collapsed "Details" disclosure that expands into a selectable block of
/// technical text — raw error messages, status codes and the like.
class _DetailsSection extends StatefulWidget {
  const _DetailsSection({required this.details, required this.label});

  final String details;
  final String label;

  @override
  State<_DetailsSection> createState() => _DetailsSectionState();
}

class _DetailsSectionState extends State<_DetailsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 200);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: AnimatedRotation(
            turns: _expanded ? 0.5 : 0,
            duration: duration,
            child: const Icon(Icons.expand_more, size: 18),
          ),
          label: Text(widget.label),
        ),
        AnimatedSize(
          duration: duration,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: !_expanded
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    // Blended instead of a scheme role so it works across
                    // Flutter versions and looks right in light and dark.
                    color: Color.lerp(scheme.surface, scheme.onSurface, 0.06),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: SelectableText(
                    widget.details,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// A one-shot fade + small upward slide played when the widget first appears.
///
/// Uses [TweenAnimationBuilder] (no controller, no dependencies) and quietly
/// steps aside when the OS "reduce motion" setting is on.
class _EntranceAnimation extends StatelessWidget {
  const _EntranceAnimation({required this.child, required this.duration});

  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion || duration == Duration.zero) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, (1 - t) * 12), child: child),
        );
      },
    );
  }
}
