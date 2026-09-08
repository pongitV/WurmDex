import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available grid compositions across the application.
enum GridComposition {
  auto, // Responsive to viewport width
  two, // 2x2 (2 columns)
  three, // 3x3 (3 columns)
  four, // 4x4 (4 columns)
  five, // 5x5 (5 columns)
  six, // 6x6 (6 columns)
}

/// Controls the global or screen-level grid composition preference.
class GridCompositionNotifier extends Notifier<GridComposition> {
  @override
  GridComposition build() {
    return GridComposition.auto;
  }

  void setComposition(GridComposition composition) {
    state = composition;
  }

  void cycleNext() {
    final nextIndex = (state.index + 1) % GridComposition.values.length;
    state = GridComposition.values[nextIndex];
  }
}

/// Global provider for grid layout composition.
final gridCompositionProvider =
    NotifierProvider<GridCompositionNotifier, GridComposition>(GridCompositionNotifier.new);

/// Universal helper to resolve the exact crossAxisCount for any card grid,
/// taking into account the user's grid composition choice and available width.
int resolveCardGridCrossAxisCount({
  required BuildContext context,
  required WidgetRef ref,
  double? availableWidth,
}) {
  final composition = ref.watch(gridCompositionProvider);
  final width = availableWidth ?? MediaQuery.of(context).size.width;

  switch (composition) {
    case GridComposition.two:
      return 2;
    case GridComposition.three:
      return width < 380 ? 2 : 3;
    case GridComposition.four:
      return width < 480 ? 2 : (width < 680 ? 3 : 4);
    case GridComposition.five:
      return width < 480 ? 2 : (width < 680 ? 3 : (width < 900 ? 4 : 5));
    case GridComposition.six:
      return width < 480 ? 2 : (width < 680 ? 3 : (width < 900 ? 4 : (width < 1150 ? 5 : 6)));
    case GridComposition.auto:
      return width > 1200
          ? 6
          : width > 950
              ? 5
              : width > 750
                  ? 4
                  : width > 520
                      ? 3
                      : 2;
  }
}
