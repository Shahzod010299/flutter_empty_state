import 'package:flutter/material.dart';

import 'empty_state_theme.dart';

/// The shared skeleton behind every state widget in this package.
///
/// It resolves styling (explicit argument > [EmptyStateTheme] > built-in
/// default), stacks an optional icon, title, message and action button, plays a
/// subtle entrance animation and takes care of centering.
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
    this.actionText,
    this.onAction,
    this.iconSize,
    this.spacing,
    this.padding,
    this.maxContentWidth,
    this.textAlign,
    this.iconColor,
    this.titleStyle,
    this.messageStyle,
    this.buttonStyle,
    this.animate,
    this.animationDuration,
  });

  final IconData? icon;
  final Widget? iconWidget;
  final String? title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;
  final double? iconSize;
  final double? spacing;
  final EdgeInsetsGeometry? padding;
  final double? maxContentWidth;
  final TextAlign? textAlign;
  final Color? iconColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final ButtonStyle? buttonStyle;
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

    // Show the button only when there's both a label and something to do.
    if (onAction != null && actionText != null) {
      children.add(SizedBox(height: spacing * 1.5));
      children.add(
        FilledButton(
          onPressed: onAction,
          style: buttonStyle,
          child: Text(actionText!),
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

    // Center ourselves when the parent gives us a bounded height (Scaffold
    // body, Center, Expanded...). Inside a scrollable the height is infinite
    // and Center would throw, so there we just return the column as-is.
    Widget result = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight == double.infinity) return content;
        return Center(child: content);
      },
    );

    if (animate) {
      result = _EntranceAnimation(duration: duration, child: result);
    }
    return result;
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
