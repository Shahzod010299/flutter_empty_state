import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_empty_state/flutter_empty_state.dart';

// Wraps a widget in just enough app for it to render. Animations are off by
// default so most tests stay deterministic without pumpAndSettle gymnastics.
Widget _host(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}

// Like _host, but registers the package's localizations under a given locale,
// so we can assert the translated default copy.
Widget _localizedHost(Widget child, {required Locale locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      EmptyStateLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: EmptyStateLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  group('EmptyState', () {
    testWidgets('renders its title and message', (tester) async {
      await tester.pumpWidget(_host(const EmptyState(
        animate: false,
        title: 'No data found',
        message: 'There is nothing to show here yet.',
      )));

      expect(find.text('No data found'), findsOneWidget);
      expect(find.text('There is nothing to show here yet.'), findsOneWidget);
    });

    testWidgets('hides the button when there is no action', (tester) async {
      await tester.pumpWidget(_host(const EmptyState(animate: false)));
      expect(find.byType(FilledButton), findsNothing);
    });
  });

  testWidgets('ErrorState renders an action button that fires onAction',
      (tester) async {
    var tapped = false;
    await tester.pumpWidget(_host(ErrorState(
      animate: false,
      actionText: 'Retry',
      onAction: () => tapped = true,
    )));

    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(tapped, isTrue);
  });

  testWidgets('NoInternetState renders a retry button', (tester) async {
    var retried = false;
    await tester.pumpWidget(_host(NoInternetState(
      animate: false,
      onRetry: () => retried = true,
    )));

    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  group('SearchEmptyState', () {
    testWidgets('shows the query text', (tester) async {
      await tester.pumpWidget(
        _host(const SearchEmptyState(animate: false, query: 'iPhone')),
      );
      expect(find.textContaining('iPhone'), findsOneWidget);
    });

    testWidgets('falls back to a generic line without a query', (tester) async {
      await tester.pumpWidget(
        _host(const SearchEmptyState(animate: false)),
      );
      expect(find.text('Try a different search.'), findsOneWidget);
    });
  });

  testWidgets('LoadingState renders a progress indicator', (tester) async {
    await tester.pumpWidget(
      _host(const LoadingState(animate: false, message: 'Loading...')),
    );
    // The spinner animates forever, so just pump a single frame here.
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });

  group('StateView', () {
    testWidgets('shows the loading widget', (tester) async {
      await tester.pumpWidget(_host(const StateView(
        state: ViewState.loading,
        animate: false,
        loading: LoadingState(animate: false),
        child: Text('content'),
      )));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('content'), findsNothing);
    });

    testWidgets('shows the content child', (tester) async {
      await tester.pumpWidget(_host(const StateView(
        state: ViewState.content,
        animate: false,
        child: Text('content'),
      )));

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('falls back to a default ErrorState', (tester) async {
      await tester.pumpWidget(_host(const StateView(
        state: ViewState.error,
        animate: false,
        child: Text('content'),
      )));

      expect(find.byType(ErrorState), findsOneWidget);
      expect(find.text('content'), findsNothing);
    });

    testWidgets('falls back to a default NoInternetState', (tester) async {
      await tester.pumpWidget(_host(const StateView(
        state: ViewState.noInternet,
        animate: false,
        child: Text('content'),
      )));

      expect(find.byType(NoInternetState), findsOneWidget);
    });
  });

  group('Theming', () {
    final redTheme = ThemeData(
      extensions: const [EmptyStateTheme(iconColor: Color(0xFFFF0000))],
    );

    testWidgets('EmptyStateTheme provides default styling', (tester) async {
      await tester.pumpWidget(_host(
        const EmptyState(animate: false, icon: Icons.star),
        theme: redTheme,
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, const Color(0xFFFF0000));
    });

    testWidgets('an explicit argument beats the theme', (tester) async {
      await tester.pumpWidget(_host(
        const EmptyState(
          animate: false,
          icon: Icons.star,
          iconColor: Color(0xFF00FF00),
        ),
        theme: redTheme,
      ));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, const Color(0xFF00FF00));
    });
  });

  group('Animation', () {
    testWidgets('plays an entrance animation by default', (tester) async {
      await tester.pumpWidget(_host(const EmptyState()));
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('is skipped when reduce motion is on', (tester) async {
      await tester.pumpWidget(_host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: EmptyState(),
        ),
      ));
      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
    });
  });

  test('EmptyState exposes diagnostics for the inspector', () {
    final builder = DiagnosticPropertiesBuilder();
    const EmptyState(title: 'Hi', message: 'There')
        .debugFillProperties(builder);

    final names = builder.properties.map((p) => p.name).toList();
    expect(names, containsAll(<String>['title', 'message', 'icon', 'action']));
  });

  group('Actions', () {
    testWidgets('async onAction disables the button and shows progress',
        (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(_host(EmptyState(
        animate: false,
        actionText: 'Retry',
        onAction: () => completer.future,
      )));

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );

      completer.complete();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('renders a secondary action that fires', (tester) async {
      var skipped = false;
      await tester.pumpWidget(_host(EmptyState(
        animate: false,
        actionText: 'Add',
        onAction: () {},
        secondaryActionText: 'Skip',
        onSecondaryAction: () => skipped = true,
      )));

      expect(find.widgetWithText(FilledButton, 'Add'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Skip'));
      expect(skipped, isTrue);
    });

    testWidgets('secondary action renders without a primary one',
        (tester) async {
      await tester.pumpWidget(_host(EmptyState(
        animate: false,
        secondaryActionText: 'Skip',
        onSecondaryAction: () {},
      )));

      expect(find.byType(FilledButton), findsNothing);
      expect(find.widgetWithText(TextButton, 'Skip'), findsOneWidget);
    });
  });

  group('Pull to refresh', () {
    testWidgets('onRefresh makes the state pull-to-refreshable',
        (tester) async {
      var refreshed = false;
      await tester.pumpWidget(_host(EmptyState(
        animate: false,
        onRefresh: () async => refreshed = true,
      )));

      await tester.fling(
          find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(refreshed, isTrue);
    });

    testWidgets('content stays centered inside the refresh scrollable',
        (tester) async {
      // Icon and message off, so the title is the whole content block and
      // its center should land on the screen center.
      await tester.pumpWidget(_host(EmptyState(
        animate: false,
        icon: null,
        title: 'Centered',
        onRefresh: () async {},
      )));

      final box = tester.getCenter(find.text('Centered'));
      final screen = tester.getCenter(find.byType(Scaffold));
      expect(box.dy, moreOrLessEquals(screen.dy, epsilon: 1));
    });
  });

  group('ErrorState details', () {
    testWidgets('details stay collapsed until tapped', (tester) async {
      await tester.pumpWidget(_host(const ErrorState(
        animate: false,
        details: 'HTTP 500 — internal server error',
      )));

      expect(find.text('HTTP 500 — internal server error'), findsNothing);
      expect(find.text('Details'), findsOneWidget);

      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();

      expect(find.text('HTTP 500 — internal server error'), findsOneWidget);
    });
  });

  group('StateView extras', () {
    testWidgets('onRetry wires the default error state button', (tester) async {
      var retried = false;
      await tester.pumpWidget(_host(StateView(
        state: ViewState.error,
        animate: false,
        onRetry: () => retried = true,
        child: const Text('content'),
      )));

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('onRetry wires the default no-internet state button',
        (tester) async {
      var retried = false;
      await tester.pumpWidget(_host(StateView(
        state: ViewState.noInternet,
        animate: false,
        onRetry: () => retried = true,
        child: const Text('content'),
      )));

      await tester.tap(find.text('Retry'));
      expect(retried, isTrue);
    });

    testWidgets('transitionBuilder customises the switch animation',
        (tester) async {
      await tester.pumpWidget(_host(StateView(
        state: ViewState.empty,
        empty: const EmptyState(animate: false),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: const Text('content'),
      )));

      expect(find.byType(ScaleTransition), findsWidgets);
      await tester.pumpAndSettle();
    });
  });

  group('Skeletons', () {
    testWidgets('SkeletonList survives an unbounded-height parent',
        (tester) async {
      await tester.pumpWidget(_host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SingleChildScrollView(child: SkeletonList(itemCount: 2)),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(Skeleton), findsWidgets);
    });

    testWidgets('SkeletonParagraph renders the requested lines',
        (tester) async {
      await tester.pumpWidget(_host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SkeletonParagraph(lines: 3),
        ),
      ));

      expect(find.byType(Skeleton), findsNWidgets(3));
    });

    testWidgets('skeleton colours come from the EmptyStateTheme',
        (tester) async {
      final theme = ThemeData(
        extensions: const [
          EmptyStateTheme(skeletonBaseColor: Color(0xFF123456)),
        ],
      );
      await tester.pumpWidget(_host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Skeleton(width: 100),
        ),
        theme: theme,
      ));

      final container = tester.widget<Container>(find.descendant(
        of: find.byType(Skeleton),
        matching: find.byType(Container),
      ));
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.color, const Color(0xFF123456));
    });

    testWidgets('shimmer renders under RTL without issues', (tester) async {
      await tester.pumpWidget(_host(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Shimmer(child: Skeleton(width: 100)),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });

    testWidgets('SkeletonGrid survives an unbounded-height parent',
        (tester) async {
      await tester.pumpWidget(_host(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SingleChildScrollView(child: SkeletonGrid(itemCount: 4)),
        ),
      ));

      expect(tester.takeException(), isNull);
      expect(find.byType(SkeletonCard), findsNWidgets(4));
    });
  });

  group('Localization', () {
    testWidgets('falls back to English with no delegate', (tester) async {
      await tester.pumpWidget(_host(const ErrorState(animate: false)));
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('uses Uzbek copy under an uz locale', (tester) async {
      await tester.pumpWidget(_localizedHost(
        // onAction so the retry button (and its localized label) renders.
        ErrorState(animate: false, onAction: () {}),
        locale: const Locale('uz'),
      ));
      expect(find.text('Nimadir xato ketdi'), findsOneWidget);
      expect(find.text('Qayta urinish'), findsOneWidget);
    });

    testWidgets('uses Russian copy under a ru locale', (tester) async {
      await tester.pumpWidget(_localizedHost(
        const NoInternetState(animate: false),
        locale: const Locale('ru'),
      ));
      expect(find.text('Нет подключения к интернету'), findsOneWidget);
    });

    testWidgets('an unsupported locale falls back to English', (tester) async {
      await tester.pumpWidget(_localizedHost(
        const EmptyState(animate: false),
        locale: const Locale('ja'),
      ));
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('an explicit string still beats the localization',
        (tester) async {
      await tester.pumpWidget(_localizedHost(
        const ErrorState(animate: false, title: 'Custom'),
        locale: const Locale('uz'),
      ));
      expect(find.text('Custom'), findsOneWidget);
      expect(find.text('Nimadir xato ketdi'), findsNothing);
    });

    testWidgets('a null title hides it even with localization', (tester) async {
      await tester.pumpWidget(_localizedHost(
        const ErrorState(animate: false, title: null),
        locale: const Locale('uz'),
      ));
      expect(find.text('Nimadir xato ketdi'), findsNothing);
    });
  });

  group('SuccessState', () {
    testWidgets('renders with a primary-coloured icon by default',
        (tester) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      );
      await tester.pumpWidget(_host(
        const SuccessState(animate: false, title: 'Order placed'),
        theme: theme,
      ));

      expect(find.text('Order placed'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, theme.colorScheme.primary);
    });
  });

  group('AsyncStateView', () {
    testWidgets('shows loading while waiting', (tester) async {
      await tester.pumpWidget(_host(AsyncStateView<int>(
        snapshot: const AsyncSnapshot<int>.waiting(),
        animate: false,
        loading: const LoadingState(animate: false),
        builder: (context, data) => Text('$data'),
      )));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows content when data is present', (tester) async {
      await tester.pumpWidget(_host(AsyncStateView<String>(
        snapshot:
            const AsyncSnapshot<String>.withData(ConnectionState.done, 'hello'),
        animate: false,
        builder: (context, data) => Text(data),
      )));
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('shows empty when isEmpty returns true', (tester) async {
      await tester.pumpWidget(_host(AsyncStateView<List<int>>(
        snapshot: const AsyncSnapshot<List<int>>.withData(
            ConnectionState.done, <int>[]),
        animate: false,
        isEmpty: (list) => list.isEmpty,
        empty: const EmptyState(animate: false, title: 'Empty!'),
        builder: (context, data) => Text('${data.length} items'),
      )));
      expect(find.text('Empty!'), findsOneWidget);
    });

    testWidgets('shows error on hasError', (tester) async {
      await tester.pumpWidget(_host(AsyncStateView<int>(
        snapshot:
            const AsyncSnapshot<int>.withError(ConnectionState.done, 'boom'),
        animate: false,
        builder: (context, data) => Text('$data'),
      )));
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('routes to no-internet when noInternetWhen matches',
        (tester) async {
      await tester.pumpWidget(_host(AsyncStateView<int>(
        snapshot:
            const AsyncSnapshot<int>.withError(ConnectionState.done, 'offline'),
        animate: false,
        noInternetWhen: (error) => error == 'offline',
        builder: (context, data) => Text('$data'),
      )));
      expect(find.byType(NoInternetState), findsOneWidget);
    });

    testWidgets('FutureStateView resolves to content', (tester) async {
      await tester.pumpWidget(_host(FutureStateView<String>(
        future: Future<String>.value('done'),
        animate: false,
        builder: (context, data) => Text(data),
      )));
      await tester.pumpAndSettle();
      expect(find.text('done'), findsOneWidget);
    });

    testWidgets('StreamStateView renders the latest value', (tester) async {
      final controller = StreamController<int>();
      addTearDown(controller.close);
      await tester.pumpWidget(_host(StreamStateView<int>(
        stream: controller.stream,
        animate: false,
        builder: (context, data) => Text('value $data'),
      )));

      controller.add(42);
      await tester.pump();
      expect(find.text('value 42'), findsOneWidget);
    });
  });
}
