# flutter_empty_state

[![pub package](https://img.shields.io/pub/v/flutter_empty_state.svg)](https://pub.dev/packages/flutter_empty_state)
[![CI](https://github.com/Shahzod010299/flutter_empty_state/actions/workflows/ci.yml/badge.svg)](https://github.com/Shahzod010299/flutter_empty_state/actions/workflows/ci.yml)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Stop rewriting the same `Center(child: Text('No data found'))` in every screen.

**flutter_empty_state** is a tiny, dependency-free set of widgets for the states every app has but nobody enjoys building: empty, error, offline, empty search, and loading. They use your app's theme out of the box, look right in light and dark, and stay fully customisable when you need them to.

```dart
return items.isEmpty
    ? const EmptyState(title: 'No products yet')
    : ProductList(items: items);
```

## Features

- 🪶 **Zero dependencies** — pure Flutter, nothing extra to audit or update.
- 🎨 **Theme-aware** — colours and text styles come from your `ThemeData`, so light/dark just works.
- 🧩 **Five ready-made states** — `EmptyState`, `ErrorState`, `NoInternetState`, `SearchEmptyState`, `LoadingState`.
- 🔀 **`StateView`** — render the right widget from a single `ViewState` value, with a cross-fade between states.
- 🌍 **Global styling** — set your defaults once with an `EmptyStateTheme`, override per widget when needed.
- ✨ **Subtle entrance animation** — a tasteful fade + slide that respects the OS "reduce motion" setting.
- 💀 **Skeleton loader** — a built-in shimmer placeholder list for a more polished loading state.
- ♿ **Accessible** — real text widgets, decorative icons, and a live region on the loading state.
- 📦 **Drops in anywhere** — `Scaffold`, `Center`, `Column` and `ListView` all work without layout gymnastics.
- ✅ **Null-safe** and covered by widget tests.

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

### Skeleton loading

For a more polished wait, swap the spinner for a shimmering placeholder list:

```dart
StateView(
  state: state,
  loading: const SkeletonList(),   // shimmer instead of a spinner
  child: ProductList(items: items),
)
```

Need a custom shape? Compose your own from the `Skeleton` and `Shimmer` primitives:

```dart
Shimmer(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Skeleton.circle(size: 56),
      SizedBox(height: 12),
      Skeleton(height: 18),           // fills the width
      SizedBox(height: 8),
      Skeleton(width: 180, height: 14),
    ],
  ),
)
```

The shimmer is theme-aware (looks right in light and dark) and freezes to a static placeholder when "reduce motion" is on.

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
