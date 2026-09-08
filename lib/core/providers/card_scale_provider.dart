import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CardScaleTarget {
  menu,
  collection,
}

/// Scale controller for Menu, Catalog, Search Grid and Trending cards
class MenuCardScaleNotifier extends Notifier<double> {
  @override
  double build() {
    // Default generous scale for Menu and Catalog: 1.15 (clear and prominent)
    return 1.15;
  }

  void setScale(double value) {
    state = double.parse(value.clamp(0.70, 1.50).toStringAsFixed(2));
  }

  void zoomIn() {
    setScale(state + 0.05);
  }

  void zoomOut() {
    setScale(state - 0.05);
  }

  void reset() {
    state = 1.15;
  }
}

/// Scale controller for User Collections: Folder Grid and Virtual Binder
class CollectionCardScaleNotifier extends Notifier<double> {
  @override
  double build() {
    // Default balanced scale for 3x3 Virtual Binder and folder grid: 0.85
    return 0.85;
  }

  void setScale(double value) {
    state = double.parse(value.clamp(0.50, 1.30).toStringAsFixed(2));
  }

  void zoomIn() {
    setScale(state + 0.05);
  }

  void zoomOut() {
    setScale(state - 0.05);
  }

  void reset() {
    state = 0.85;
  }
}

final menuCardScaleProvider = NotifierProvider<MenuCardScaleNotifier, double>(MenuCardScaleNotifier.new);

final collectionCardScaleProvider = NotifierProvider<CollectionCardScaleNotifier, double>(CollectionCardScaleNotifier.new);

// Backward-compatibility alias pointing to collection scale
final cardScaleProvider = collectionCardScaleProvider;

/// Reusable helper to calculate dynamic grid columns according to viewport width and scale factor.
int calculateScaledCrossAxisCount({
  required double width,
  required double cardScale,
  double baseCardWidth = 210.0,
  double minBaseWidth = 130.0,
  double maxBaseWidth = 380.0,
  int minColumns = 2,
  int maxColumns = 14,
}) {
  final baseWidth = (baseCardWidth * cardScale).clamp(minBaseWidth, maxBaseWidth);
  return (width / baseWidth).floor().clamp(minColumns, maxColumns);
}
