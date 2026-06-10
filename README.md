# flutter_empty_state

[![pub package](https://img.shields.io/pub/v/flutter_empty_state.svg)](https://pub.dev/packages/flutter_empty_state)
[![CI](https://github.com/Shahzod010299/flutter_empty_state/actions/workflows/ci.yml/badge.svg)](https://github.com/Shahzod010299/flutter_empty_state/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/Shahzod010299/flutter_empty_state/branch/master/graph/badge.svg)](https://codecov.io/gh/Shahzod010299/flutter_empty_state)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

**[▶ Live demo](https://shahzod010299.github.io/flutter_empty_state/)** · **[pub.dev](https://pub.dev/packages/flutter_empty_state)**

Stop rewriting the same `Center(child: Text('No data found'))` in every screen.

**flutter_empty_state** is a tiny, dependency-free set of widgets for the states every app has but nobody enjoys building: empty, error, offline, empty search, and loading. They use your app's theme out of the box, look right in light and dark, and stay fully customisable when you need them to.

```dart
return items.isEmpty
    ? const EmptyState(title: 'No products yet')
    : ProductList(items: items);
```

## Preview

| Empty | Error | No internet |
| :---: | :---: | :---: |
| <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/empty_state_light.png" width="220"/> | <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/error_state_light.png" width="220"/> | <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/no_internet_light.png" width="220"/> |
| **Search empty** | **Skeleton loader** | **Dark mode** |
| <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/search_empty_light.png" width="220"/> | <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/skeleton_light.png" width="220"/> | <img src="https://raw.githubusercontent.com/Shahzod010299/flutter_empty_state/master/screenshots/empty_state_dark.png" width="220"/> |

## Features

- **Zero dependencies** — pure Flutter, nothing extra to audit or update.
- **Theme-aware** — colours and text styles come from your `ThemeData`, so light/dark just works.
- **Six ready-made states** — `EmptyState`, `ErrorState`, `NoInternetState`, `SearchEmptyState`, `LoadingState`, `SuccessState`.
- **`StateView`** — render the right widget from a single `ViewState` value, with a cross-fade between states.
- **Future & Stream views** — `FutureStateView` / `StreamStateView` map an async source straight to loading / error / empty / content.
- **Localized** — every default string is translatable; 10 languages ship in the box, with English fallback.
- **Pull-to-refresh** — pass `onRefresh` and any state becomes a `RefreshIndicator` scrollable.
- **Async-aware buttons** — return a `Future` from an action and the button shows inline progress until it's done.
- **Error details** — tuck raw exception text behind a collapsible, selectable "Details" disclosure.
- **Global styling** — set your defaults once with an `EmptyStateTheme`, override per widget when needed.
- **Subtle entrance animation** — a tasteful fade + slide that respects the OS "reduce motion" setting.
- **Skeleton loaders** — shimmer list, paragraph, card and grid primitives, RTL-aware and themable.
- **Accessible** — real text widgets, decorative icons, and a live region on the loading state.
- **Drops in anywhere** — `Scaffold`, `Center`, `Column`, `ListView` and `CustomScrollView` all work without layout gymnastics.
- **Null-safe** and covered by widget tests.

## Installation

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_empty_state: ^0.1.0
```

Then run `flutter pub get` and import it:

```dart
import 'package:flutter_empty_state/flutter_empty_state.dart';
```

## Basic usage

Every widget works on its own with zero required parameters, so you can start small and customise later:

```dart
const EmptyState();        // sensible defaults
const LoadingState();      // a centered spinner
```

## The widgets

### EmptyState

```dart
EmptyState(
  icon: Icons.inbox_outlined,
  title: 'No data found',
  message: 'There is nothing to show here yet.',
  actionText: 'Refresh',
  onAction: () => _reload(),
)
```

> The action button shows up only when you pass **both** `actionText` and `onAction`.

Need a second, lower-emphasis option? Add a secondary action and it renders as
a `TextButton` under the main one:

```dart
EmptyState(
  title: 'Your cart is empty',
  actionText: 'Browse products',
  onAction: _browse,
  secondaryActionText: 'View wishlist',
  onSecondaryAction: _openWishlist,
)
```

### Async actions & pull-to-refresh

Every action callback accepts a `Future`. Return one and the button disables
itself and shows a small inline spinner until the work finishes — no state
management needed:

```dart
ErrorState(
  onAction: () async => _reload(), // button shows progress while this runs
)
```

And if you'd rather let users pull down to reload (even though there's no list
on screen), pass `onRefresh` and the state wraps itself in a `RefreshIndicator`:

```dart
EmptyState(
  title: 'No orders yet',
  onRefresh: () => _reload(),
)
```

### ErrorState

```dart
ErrorState(
  title: 'Something went wrong',
  message: 'Please try again later.',
  actionText: 'Retry',
  onAction: () => _retry(),
)
```

`title`, `message` and `actionText` already default to error-friendly copy, so `ErrorState(onAction: _retry)` is enough for a working retry screen.

Got a raw exception you'd like to keep around for bug reports? Pass it as
`details` and it hides behind a collapsed, selectable "Details" section:

```dart
ErrorState(
  onAction: _retry,
  details: error.toString(), // expands on tap, selectable for copy-paste
)
```

### NoInternetState

```dart
NoInternetState(
  onRetry: () => _reconnect(),
)
```

### SearchEmptyState

```dart
SearchEmptyState(
  query: 'iPhone',
  onClear: () => _clearSearch(),
)
```

When you don't pass a `message`, it builds one from the query — e.g. `No matches for "iPhone".`

### LoadingState

```dart
LoadingState(
  message: 'Loading...',
)
```

### SuccessState

For the happy path — order placed, file uploaded, form submitted:

```dart
SuccessState(
  title: 'Order placed',
  message: 'We\'ll email you a receipt shortly.',
  actionText: 'Back to home',
  onAction: _goHome,
)
```

Same layout as the other states, tuned for good news: the check icon defaults
to your theme's primary colour instead of the muted grey.

### Skeleton loading

For a more polished wait, swap the spinner for a shimmering placeholder list:

```dart
StateView(
  state: state,
  loading: const SkeletonList(),   // shimmer instead of a spinner
  child: ProductList(items: items),
)
```

Need a custom shape? Compose your own from the `Skeleton`, `SkeletonParagraph` and `Shimmer` primitives:

```dart
Shimmer(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Skeleton.circle(size: 56),
      SizedBox(height: 12),
      SkeletonParagraph(lines: 3),    // a text block with a shorter last line
      SizedBox(height: 8),
      Skeleton(width: 180, height: 14),
    ],
  ),
)
```

Building a grid instead of a list? `SkeletonGrid` (made of `SkeletonCard`s) is the grid counterpart to `SkeletonList`:

```dart
StateView(
  state: state,
  loading: const SkeletonGrid(crossAxisCount: 2),
  child: ProductGrid(items: items),
)
```

The shimmer is theme-aware (looks right in light and dark), follows the text direction (RTL included) and freezes to a static placeholder when "reduce motion" is on. Want brand-specific colours? Set `skeletonBaseColor` / `skeletonHighlightColor` on your `EmptyStateTheme`.

## StateView

Describe each state once and switch on a single value instead of juggling `if/else` chains in your build method:

```dart
StateView(
  state: viewState, // a ViewState
  loading: const LoadingState(),
  empty: const EmptyState(title: 'No products found'),
  error: ErrorState(onAction: _retry),
  noInternet: NoInternetState(onRetry: _retry),
  child: ProductList(items: items),
)
```

In the common case you don't even need to spell out the error states — pass
`onRetry` once and the default error and no-internet widgets come pre-wired
with a working retry button:

```dart
StateView(
  state: viewState,
  onRetry: _load,
  child: ProductList(items: items),
)
```

Want something fancier than the default cross-fade? `transitionBuilder` has
the same contract as `AnimatedSwitcher`:

```dart
StateView(
  state: viewState,
  transitionBuilder: (child, animation) =>
      ScaleTransition(scale: animation, child: child),
  child: ProductList(items: items),
)
```

`ViewState` is just an enum:

```dart
enum ViewState { loading, empty, error, noInternet, content }
```

Any slot you leave out falls back to a default widget, so you only fill in what you want to change. A typical controller flow looks like this:

```dart
ViewState state = ViewState.loading;

Future<void> load() async {
  setState(() => state = ViewState.loading);
  try {
    items = await api.fetchProducts();
    setState(() => state = items.isEmpty ? ViewState.empty : ViewState.content);
  } on SocketException {
    setState(() => state = ViewState.noInternet);
  } catch (_) {
    setState(() => state = ViewState.error);
  }
}
```

## Driving from a Future or Stream

Most of the time you don't even track a `ViewState` yourself — you have a
`Future` or a `Stream`. `FutureStateView` and `StreamStateView` wire the whole
lifecycle (loading → error / offline / empty → content) to it for you, so the
controller flow above collapses to a single widget:

```dart
FutureStateView<List<Product>>(
  future: _future,
  isEmpty: (products) => products.isEmpty,          // → empty state
  noInternetWhen: (e) => e is SocketException,       // → no-internet state
  onRetry: () => setState(() => _future = _load()),  // pre-wired retry button
  builder: (context, products) => ProductList(products: products),
)
```

`StreamStateView` has the same API for a `Stream`. Already inside a
`FutureBuilder`/`StreamBuilder`? Use `AsyncStateView`, which takes the
`AsyncSnapshot` directly. All three leave any slot you don't set to the same
sensible defaults as `StateView`.

## Localization

Every default string ("Retry", "No internet connection", …) is translatable.
Ten languages ship in the box — English, Uzbek, Russian, Spanish, French,
German, Portuguese, Turkish, Arabic and Chinese — and any other locale falls
back to English. It works with **zero setup**; to switch languages, register
the delegate:

```dart
MaterialApp(
  localizationsDelegates: const [
    EmptyStateLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: EmptyStateLocalizations.supportedLocales,
)
```

Explicit strings always win, so `ErrorState(title: 'Custom')` overrides the
translation, and `title: null` still hides the element. Need a language that
isn't bundled? Subclass `EmptyStateLocalizations` and provide it through your
own delegate.

## Custom styling

Nothing is locked down. Override as little or as much as you like:

```dart
EmptyState(
  icon: Icons.favorite_border,
  iconSize: 96,
  iconColor: Colors.pink,
  title: 'No favourites yet',
  message: 'Tap the heart on any item to save it here.',
  spacing: 20,
  padding: const EdgeInsets.all(32),
  textAlign: TextAlign.center,
  titleStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  messageStyle: TextStyle(color: Colors.grey.shade600),
  actionText: 'Browse items',
  onAction: _browse,
  buttonStyle: FilledButton.styleFrom(backgroundColor: Colors.pink),
)
```

Need a full illustration instead of a Material icon? Use `iconWidget`:

```dart
EmptyState(
  iconWidget: Image.asset('assets/empty_box.png', height: 140),
  title: 'Your cart is empty',
)
```

## Global styling with `EmptyStateTheme`

Don't want to repeat the same `iconColor:` / `spacing:` on every screen? Set your defaults once as a theme extension and every widget picks them up:

```dart
MaterialApp(
  theme: ThemeData(
    extensions: const [
      EmptyStateTheme(
        iconColor: Colors.teal,
        spacing: 20,
        titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    ],
  ),
)
```

Resolution order for every property is **explicit argument → `EmptyStateTheme` → built-in default**, so a one-off `EmptyState(iconColor: Colors.red)` still wins where you need it.

## Animation & accessibility

Each widget plays a subtle fade-and-slide when it first appears, and `StateView` cross-fades between states. It's all opt-out:

```dart
EmptyState(animate: false);                                  // no entrance animation
EmptyState(animationDuration: const Duration(milliseconds: 200));
StateView(state: state, duration: Duration.zero, child: ...); // no cross-fade
```

Animations are skipped automatically when the user has **"reduce motion"** turned on. The loading state is also exposed as a live region with a semantic label, so screen readers announce the wait.

## Light & dark themes

By default every widget reads its colours and text styles from `Theme.of(context)`:

- the icon uses `colorScheme.onSurfaceVariant`,
- the title uses `textTheme.titleMedium`,
- the message uses `textTheme.bodyMedium`,
- the button is a Material 3 `FilledButton` that follows your `colorScheme`.

So switching your app between light and dark needs no extra work here — these widgets follow along.

## Placing it in a layout

The widgets center themselves when they're given a bounded height (a `Scaffold` body, a `Center`, an `Expanded`) and lay out naturally inside a scrollable like `ListView`, so the same widget works in all of these:

```dart
Scaffold(body: const EmptyState());                 // centered on screen
Center(child: const EmptyState());                  // centered
Column(children: [Expanded(child: EmptyState())]);  // fills and centers
ListView(children: const [EmptyState()]);           // sits naturally, no crash
```

Inside a `CustomScrollView`, wrap the state in a `SliverFillRemaining` and it
centers in the leftover space under your app bar:

```dart
CustomScrollView(
  slivers: [
    const SliverAppBar(title: Text('Orders')),
    SliverFillRemaining(
      hasScrollBody: false,
      child: EmptyState(title: 'No orders yet'),
    ),
  ],
)
```

## Why use this package?

- **Consistency** — the same empty/error/loading look across every screen and every project.
- **Less boilerplate** — no more hand-rolled `Center`/`Column`/`Text` for each state.
- **No baggage** — zero runtime dependencies and a small surface area.
- **Theme-first** — light and dark are handled for you.
- **Customisable when it matters** — good defaults now, full control later.

## Running the tests

```bash
flutter test                       # unit + widget tests
flutter test --exclude-tags golden # what CI runs (skips pixel tests)
flutter test --update-goldens --tags golden  # regenerate the golden images
```

Golden (pixel) tests are tagged `golden` and excluded on CI, since golden files
are tied to the platform that generated them.

## Contributing

Issues and pull requests are welcome over on
[GitHub](https://github.com/Shahzod010299/flutter_empty_state). CI runs
formatting, analysis, tests and a publish dry-run on every push.

## License

[MIT](LICENSE)
