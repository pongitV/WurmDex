import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wurmdex/core/widgets/app_filter_modal.dart';
import 'package:wurmdex/core/widgets/app_sort_button.dart';
import 'package:wurmdex/features/news/models/news_filter_state.dart';
import 'package:wurmdex/main.dart';

void main() {
  testWidgets('Menu screen displays News filters and News sorts, NOT Pokemon card types', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WurmDexApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    // Verify AppFilterButton and AppSortButton<NewsSortOption> are present in AppBar
    expect(find.byType(AppFilterButton), findsOneWidget);
    expect(find.byType(AppSortButton<NewsSortOption>), findsOneWidget);

    // Tap the filter button in news mode
    await tester.tap(find.byType(AppFilterButton));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify News Filter Dialog opened with news sources and categories
    expect(find.text('News Sources'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Expansions & Products'), findsOneWidget);
    expect(find.text('Competitive & Scene'), findsOneWidget);

    // Verify NO Pokémon card energy types are present in the news filter!
    expect(find.text('Grass'), findsNothing);
    expect(find.text('Fire'), findsNothing);
    expect(find.text('Water'), findsNothing);
    expect(find.text('Lightning'), findsNothing);

    // Close the filter dialog
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 500));

    // Tap sort button in news mode
    await tester.tap(find.byType(AppSortButton<NewsSortOption>));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify News Sort Options are shown
    expect(find.text('Newest First'), findsOneWidget);
    expect(find.text('Oldest First'), findsOneWidget);
    expect(find.text('Title (A → Z)'), findsOneWidget);
    expect(find.text('By Source'), findsOneWidget);
  });
}
