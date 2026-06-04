import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'empty_state.dart';
import 'error_state.dart';
import 'loading_state.dart';
import 'no_internet_state.dart';
import 'view_state.dart';

/// Picks what to render based on the current [ViewState], and cross-fades
/// between states as it changes.
///
/// Instead of scattering `if (loading) ... else if (error) ...` across your
/// build methods, describe each case once and switch on a single value:
///
/// ```dart
/// StateView(
///   state: state,
///   loading: const LoadingState(),
///   empty: const EmptyState(title: 'No products found'),
///   error: ErrorState(onAction: _retry),
///   noInternet: NoInternetState(onRetry: _retry),
///   child: ProductList(products: products),
/// )
/// ```
///
/// Any slot you leave out falls back to a sensible default, so you only fill in
/// the ones you want to customise.
class StateView extends StatelessWidget {
  const StateView({
    super.key,
    required this.state,
    this.child,
    this.loading,
    this.empty,
    this.error,
    this.noInternet,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
  });

  /// Which state to show right now.
  final ViewState state;

  /// Shown for [ViewState.content] — your actual screen.
  final Widget? child;

  /// Shown for [ViewState.loading]. Defaults to a [LoadingState].
  final Widget? loading;

  /// Shown for [ViewState.empty]. Defaults to an [EmptyState].
  final Widget? empty;

  /// Shown for [ViewState.error]. Defaults to an [ErrorState].
  final Widget? error;

  /// Shown for [ViewState.noInternet]. Defaults to a [NoInternetState].
  final Widget? noInternet;

  /// Whether to cross-fade when [state] changes. Defaults to `true`, and is
  /// skipped automatically when the OS "reduce motion" setting is on.
  final bool animate;

  /// Duration of the cross-fade between states.
  final Duration duration;

  Widget _childFor(ViewState state) {
    switch (state) {
      case ViewState.loading:
        return loading ?? const LoadingState();
      case ViewState.empty:
        return empty ?? const EmptyState();
      case ViewState.error:
        return error ?? const ErrorState();
      case ViewState.noInternet:
        return noInternet ?? const NoInternetState();
      case ViewState.content:
        return child ?? const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _childFor(state);

    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!animate || reduceMotion || duration == Duration.zero) {
      return current;
    }

    return AnimatedSwitcher(
      duration: duration,
      // Key by the state so the switcher knows a real change happened and
      // cross-fades, rather than reusing the old element in place.
      child: KeyedSubtree(key: ValueKey<ViewState>(state), child: current),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<ViewState>('state', state))
      ..add(FlagProperty('animate', value: animate, ifFalse: 'no transition'));
  }
}
