import 'dart:async';

import 'package:flutter/material.dart';

import 'state_view.dart';
import 'view_state.dart';

/// Builds your content widget from loaded data.
typedef AsyncWidgetBuilder<T> = Widget Function(BuildContext context, T data);

/// Renders the right state straight from an [AsyncSnapshot], so a `FutureBuilder`
/// or `StreamBuilder` becomes a one-liner that already handles loading, errors,
/// the offline case and "loaded but empty".
///
/// ```dart
/// FutureBuilder<List<Product>>(
///   future: _future,
///   builder: (context, snapshot) => AsyncStateView<List<Product>>(
///     snapshot: snapshot,
///     isEmpty: (products) => products.isEmpty,
///     onRetry: _reload,
///     builder: (context, products) => ProductList(products: products),
///   ),
/// )
/// ```
///
/// For the common cases you usually don't even need the `FutureBuilder` —
/// reach for [FutureStateView] or [StreamStateView] instead.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.snapshot,
    required this.builder,
    this.isEmpty,
    this.noInternetWhen,
    this.onRetry,
    this.loading,
    this.empty,
    this.error,
    this.noInternet,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  /// The snapshot to read the current state from.
  final AsyncSnapshot<T> snapshot;

  /// Builds the content widget once data has loaded (and isn't [isEmpty]).
  final AsyncWidgetBuilder<T> builder;

  /// {@template fes.async.isEmpty}
  /// Returns true when the loaded data should show the empty state instead of
  /// content — e.g. `(list) => list.isEmpty`. Defaults to never empty.
  /// {@endtemplate}
  final bool Function(T data)? isEmpty;

  /// {@template fes.async.noInternetWhen}
  /// Classifies an error as "no internet" rather than a generic failure, so
  /// you can show [NoInternetState] for connectivity issues. Kept as a
  /// predicate (instead of a hard-coded `SocketException` check) so it stays
  /// web-safe and works with your own error types:
  ///
  /// ```dart
  /// noInternetWhen: (error) => error is SocketException,
  /// ```
  /// {@endtemplate}
  final bool Function(Object error)? noInternetWhen;

  /// {@template fes.async.onRetry}
  /// Wires the retry button of the default error / no-internet states.
  /// {@endtemplate}
  final FutureOr<void> Function()? onRetry;

  /// {@macro fes.stateview.loading}
  final Widget? loading;

  /// {@macro fes.stateview.empty}
  final Widget? empty;

  /// {@macro fes.stateview.error}
  final Widget? error;

  /// {@macro fes.stateview.noInternet}
  final Widget? noInternet;

  /// {@template fes.async.animate}
  /// Whether to cross-fade between states. Forwarded to [StateView.animate].
  /// {@endtemplate}
  final bool animate;

  /// {@template fes.async.duration}
  /// Duration of the transition between states.
  /// {@endtemplate}
  final Duration duration;

  /// {@template fes.async.transitionBuilder}
  /// Custom transition between states. Forwarded to
  /// [StateView.transitionBuilder].
  /// {@endtemplate}
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Maps the snapshot onto a [ViewState]. Errors win, then loaded data
  /// (content or empty), then the waiting state.
  ViewState _stateFor() {
    if (snapshot.hasError) {
      final isOffline = noInternetWhen?.call(snapshot.error!) ?? false;
      return isOffline ? ViewState.noInternet : ViewState.error;
    }
    if (snapshot.hasData) {
      final data = snapshot.data as T;
      return (isEmpty?.call(data) ?? false)
          ? ViewState.empty
          : ViewState.content;
    }
    // No data and no error yet — still loading. This also covers
    // ConnectionState.none, which a bare FutureBuilder rarely hits.
    return ViewState.loading;
  }

  @override
  Widget build(BuildContext context) {
    final state = _stateFor();
    return StateView(
      state: state,
      onRetry: onRetry,
      loading: loading,
      empty: empty,
      error: error,
      noInternet: noInternet,
      animate: animate,
      duration: duration,
      transitionBuilder: transitionBuilder,
      child: state == ViewState.content
          ? builder(context, snapshot.data as T)
          : null,
    );
  }
}

/// A [FutureBuilder] + [AsyncStateView] in one: hand it a [future] and a
/// [builder] and it shows loading / error / empty / content for you.
///
/// ```dart
/// FutureStateView<List<Product>>(
///   future: _future,
///   isEmpty: (products) => products.isEmpty,
///   onRetry: () => setState(() => _future = _load()),
///   builder: (context, products) => ProductList(products: products),
/// )
/// ```
class FutureStateView<T> extends StatelessWidget {
  const FutureStateView({
    super.key,
    required this.future,
    required this.builder,
    this.initialData,
    this.isEmpty,
    this.noInternetWhen,
    this.onRetry,
    this.loading,
    this.empty,
    this.error,
    this.noInternet,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  /// The future to watch. Re-create it (e.g. in `setState`) to reload.
  final Future<T>? future;

  /// Builds the content widget from the resolved value.
  final AsyncWidgetBuilder<T> builder;

  /// Seeds the snapshot before the future completes.
  final T? initialData;

  /// {@macro fes.async.isEmpty}
  final bool Function(T data)? isEmpty;

  /// {@macro fes.async.noInternetWhen}
  final bool Function(Object error)? noInternetWhen;

  /// {@macro fes.async.onRetry}
  final FutureOr<void> Function()? onRetry;

  /// {@macro fes.stateview.loading}
  final Widget? loading;

  /// {@macro fes.stateview.empty}
  final Widget? empty;

  /// {@macro fes.stateview.error}
  final Widget? error;

  /// {@macro fes.stateview.noInternet}
  final Widget? noInternet;

  /// {@macro fes.async.animate}
  final bool animate;

  /// {@macro fes.async.duration}
  final Duration duration;

  /// {@macro fes.async.transitionBuilder}
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      initialData: initialData,
      builder: (context, snapshot) => AsyncStateView<T>(
        snapshot: snapshot,
        isEmpty: isEmpty,
        noInternetWhen: noInternetWhen,
        onRetry: onRetry,
        loading: loading,
        empty: empty,
        error: error,
        noInternet: noInternet,
        animate: animate,
        duration: duration,
        transitionBuilder: transitionBuilder,
        builder: builder,
      ),
    );
  }
}

/// A [StreamBuilder] + [AsyncStateView] in one: hand it a [stream] and a
/// [builder] and it shows loading / error / empty / content as events arrive.
///
/// ```dart
/// StreamStateView<List<Message>>(
///   stream: _messages,
///   isEmpty: (messages) => messages.isEmpty,
///   builder: (context, messages) => MessageList(messages: messages),
/// )
/// ```
class StreamStateView<T> extends StatelessWidget {
  const StreamStateView({
    super.key,
    required this.stream,
    required this.builder,
    this.initialData,
    this.isEmpty,
    this.noInternetWhen,
    this.onRetry,
    this.loading,
    this.empty,
    this.error,
    this.noInternet,
    this.animate = true,
    this.duration = const Duration(milliseconds: 300),
    this.transitionBuilder,
  });

  /// The stream to watch.
  final Stream<T>? stream;

  /// Builds the content widget from the latest value.
  final AsyncWidgetBuilder<T> builder;

  /// Seeds the snapshot before the first event.
  final T? initialData;

  /// {@macro fes.async.isEmpty}
  final bool Function(T data)? isEmpty;

  /// {@macro fes.async.noInternetWhen}
  final bool Function(Object error)? noInternetWhen;

  /// {@macro fes.async.onRetry}
  final FutureOr<void> Function()? onRetry;

  /// {@macro fes.stateview.loading}
  final Widget? loading;

  /// {@macro fes.stateview.empty}
  final Widget? empty;

  /// {@macro fes.stateview.error}
  final Widget? error;

  /// {@macro fes.stateview.noInternet}
  final Widget? noInternet;

  /// {@macro fes.async.animate}
  final bool animate;

  /// {@macro fes.async.duration}
  final Duration duration;

  /// {@macro fes.async.transitionBuilder}
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      initialData: initialData,
      builder: (context, snapshot) => AsyncStateView<T>(
        snapshot: snapshot,
        isEmpty: isEmpty,
        noInternetWhen: noInternetWhen,
        onRetry: onRetry,
        loading: loading,
        empty: empty,
        error: error,
        noInternet: noInternet,
        animate: animate,
        duration: duration,
        transitionBuilder: transitionBuilder,
        builder: builder,
      ),
    );
  }
}
