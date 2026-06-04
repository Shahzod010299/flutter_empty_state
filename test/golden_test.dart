@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_empty_state/flutter_empty_state.dart';

// Golden (pixel) tests. They're tagged so CI can skip them with
// `--exclude-tags golden`, because golden files are tied to the platform that
// generated them. Regenerate locally with:
//
//   flutter test --update-goldens --tags golden
void main() {
  Future<void> pumpFixed(
    WidgetTester tester,
    Widget child, {
    Brightness brightness = Brightness.light,
    bool reduceMotion = false,
  }) async {
    tester.view.physicalSize = const Size(400, 720);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    Widget body = child;
    if (reduceMotion) {
      body = MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: child,
      );
    }

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: Scaffold(body: body),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('EmptyState — light', (tester) async {
    await pumpFixed(
      tester,
      const EmptyState(
        animate: false,
        title: 'No products yet',
        message: 'When you add products, they show up here.',
        actionText: 'Add product',
        onAction: _noop,
      ),
    );
    await expectLater(
      find.byType(EmptyState),
      matchesGoldenFile('goldens/empty_state_light.png'),
    );
  });

  testWidgets('EmptyState — dark', (tester) async {
    await pumpFixed(
      tester,
      const EmptyState(
        animate: false,
        title: 'No products yet',
        message: 'When you add products, they show up here.',
        actionText: 'Add product',
        onAction: _noop,
      ),
      brightness: Brightness.dark,
    );
    await expectLater(
      find.byType(EmptyState),
      matchesGoldenFile('goldens/empty_state_dark.png'),
    );
  });

  testWidgets('ErrorState — light', (tester) async {
    await pumpFixed(
      tester,
      const ErrorState(animate: false, onAction: _noop),
    );
    await expectLater(
      find.byType(ErrorState),
      matchesGoldenFile('goldens/error_state_light.png'),
    );
  });

  testWidgets('SearchEmptyState — light', (tester) async {
    await pumpFixed(
      tester,
      const SearchEmptyState(animate: false, query: 'iPhone', onClear: _noop),
    );
    await expectLater(
      find.byType(SearchEmptyState),
      matchesGoldenFile('goldens/search_empty_state_light.png'),
    );
  });

  testWidgets('SkeletonList — light (static)', (tester) async {
    // Reduce-motion freezes the shimmer, which keeps the golden deterministic.
    await pumpFixed(
      tester,
      const SkeletonList(itemCount: 4),
      reduceMotion: true,
    );
    await expectLater(
      find.byType(SkeletonList),
      matchesGoldenFile('goldens/skeleton_list_light.png'),
    );
  });
}

void _noop() {}
