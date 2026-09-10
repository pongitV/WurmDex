import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/providers/card_scale_provider.dart';
import '../../../../core/providers/currency_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/card_condition_helper.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/card_scale_button.dart';
import '../../../../core/widgets/card_shimmer_glow.dart';
import 'binder/binder_pocket_card.dart';
import 'binder/binder_spine_rings.dart';
import 'binder/binder_sticker_tape.dart';

class VirtualBinderView extends ConsumerStatefulWidget {
  final List<UserCard> cards;
  final VoidCallback onAddCard;
  final String? highlightedCardId;
  final String? folderName;

  const VirtualBinderView({
    super.key,
    required this.cards,
    required this.onAddCard,
    this.highlightedCardId,
    this.folderName,
  });

  @override
  ConsumerState<VirtualBinderView> createState() => VirtualBinderViewState();
}

class VirtualBinderViewState extends ConsumerState<VirtualBinderView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _turnAnimationController;
  final FocusNode _focusNode = FocusNode();
  int _currentPage = 0;
  double _pageScrollProgress = 0.0;
  double _turnStartProgress = 0.0;
  double _turnTargetProgress = 0.0;
  double _dragStartProgress = 0.0;
  double _dragStartX = 0.0;
  DateTime _lastScrollTime = DateTime.now();
  late AppStrings _strings;
  static const int _pageSize = 9; // 3x3 slots per page

  String? _activeHighlightId;

  @override
  void initState() {
    super.initState();
    _turnAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    )..addListener(() {
        setState(() {
          final t = Curves.easeInOutCubic.transform(_turnAnimationController.value);
          _pageScrollProgress = _turnStartProgress + (_turnTargetProgress - _turnStartProgress) * t;
          _currentPage = _pageScrollProgress.round().clamp(0, _totalPages - 1);
        });
      });

    _activeHighlightId = widget.highlightedCardId;

    if (_activeHighlightId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        revealCard(_activeHighlightId!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant VirtualBinderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlightedCardId != null &&
        widget.highlightedCardId != oldWidget.highlightedCardId) {
      revealCard(widget.highlightedCardId!);
    }
  }

  @override
  void dispose() {
    _turnAnimationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalPages {
    final totalCards = widget.cards.length;
    return math.max(1, (totalCards / _pageSize).ceil());
  }

  /// Smoothly animates the page turn pivoting strictly around the 6 rings.
  Future<void> _animateToPage(int targetPage, {Duration? duration}) async {
    final target = targetPage.clamp(0, _totalPages - 1);
    if (target == _currentPage && (_pageScrollProgress - target).abs() < 0.005) {
      return;
    }

    _turnStartProgress = _pageScrollProgress;
    _turnTargetProgress = target.toDouble();
    _turnAnimationController.duration = duration ?? const Duration(milliseconds: 380);
    _turnAnimationController.reset();
    await _turnAnimationController.forward();
    if (mounted) {
      setState(() {
        _currentPage = target;
        _pageScrollProgress = target.toDouble();
      });
    }
  }

  /// Reveals a card by sequentially flipping pages over the rings until reaching it,
  /// and activates a 2-second glowing holographic shimmer effect.
  Future<void> revealCard(String cardId) async {
    final index = widget.cards.indexWhere(
      (c) => c.id == cardId || c.cardApiId == cardId,
    );
    if (index < 0) return;

    final targetPage = index ~/ _pageSize;

    if (targetPage != _currentPage) {
      final diff = (targetPage - _currentPage).abs();
      if (diff > 1) {
        // Sequentially flip pages over the rings
        final step = targetPage > _currentPage ? 1 : -1;
        for (int p = _currentPage + step; p != targetPage; p += step) {
          if (!mounted) return;
          await _animateToPage(p, duration: const Duration(milliseconds: 230));
          await Future.delayed(const Duration(milliseconds: 40));
        }
      }

      if (!mounted) return;
      await _animateToPage(targetPage, duration: const Duration(milliseconds: 380));
    }

    if (mounted) {
      setState(() {
        _activeHighlightId = cardId;
        _currentPage = targetPage;
      });

      // Clear the highlight after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted && _activeHighlightId == cardId) {
          setState(() {
            _activeHighlightId = null;
          });
        }
      });
    }
  }

  void _goToPage(int page) {
    final target = page.clamp(0, _totalPages - 1);
    if (target != _currentPage) {
      _animateToPage(target);
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (_turnAnimationController.isAnimating) {
      _turnAnimationController.stop();
    }
    _dragStartProgress = _pageScrollProgress;
    _dragStartX = details.localPosition.dx;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double sheetW) {
    if (_totalPages <= 1) return;
    final deltaX = details.localPosition.dx - _dragStartX;
    // Dragging left (negative deltaX) flips forward; dragging right flips backward
    final progressDelta = -deltaX / (sheetW * 0.85);
    final newProgress = (_dragStartProgress + progressDelta).clamp(0.0, (_totalPages - 1).toDouble());
    setState(() {
      _pageScrollProgress = newProgress;
      _currentPage = _pageScrollProgress.round().clamp(0, _totalPages - 1);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double sheetW) {
    if (_totalPages <= 1) return;
    final velocityX = details.primaryVelocity ?? 0.0;
    int target;
    if (velocityX < -250) {
      // Fast flick left -> next page
      target = _pageScrollProgress.floor() + 1;
    } else if (velocityX > 250) {
      // Fast flick right -> previous page
      target = _pageScrollProgress.ceil() - 1;
    } else {
      // Snap to nearest page
      target = _pageScrollProgress.round();
    }
    _animateToPage(target.clamp(0, _totalPages - 1));
  }

  void _handlePointerScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final now = DateTime.now();
      // Debounce rapid wheel events to flip one page at a time cleanly
      if (now.difference(_lastScrollTime).inMilliseconds < 250) {
        return;
      }

      final delta = event.scrollDelta.dy != 0 ? event.scrollDelta.dy : event.scrollDelta.dx;
      if (delta > 15 && _currentPage < _totalPages - 1) {
        _lastScrollTime = now;
        _goToPage(_currentPage + 1);
      } else if (delta < -15 && _currentPage > 0) {
        _lastScrollTime = now;
        _goToPage(_currentPage - 1);
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.pageDown) {
        if (_currentPage < _totalPages - 1) {
          _goToPage(_currentPage + 1);
          return KeyEventResult.handled;
        }
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.pageUp) {
        if (_currentPage > 0) {
          _goToPage(_currentPage - 1);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPages = _totalPages;
    final cardScale = ref.watch(collectionCardScaleProvider);
    final language = ref.watch(languageProvider);
    _strings = getStrings(language);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Listener(
        onPointerSignal: _handlePointerScroll,
        child: Column(
          children: [
            // 3D Binder Viewport
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const targetRatio = AppConstants.binderSheetAspectRatio; // 0.755
                  final bool isSinglePage = constraints.maxWidth < 650;

                  if (isSinglePage) {
                    // Mobile/Android Single Page Layout (1 página por vez, economiza espaço e maximiza bolsos)
                    const double spineW = 20.0;
                    const double paddingH = 16.0;
                    const double paddingV = 20.0;

                    final availableW = (constraints.maxWidth - paddingH) * cardScale;
                    final availableH = (constraints.maxHeight - paddingV) * cardScale;

                    double sheetW = availableW - spineW;
                    double sheetH = sheetW / targetRatio;

                    if (sheetH > availableH) {
                      sheetH = availableH;
                      sheetW = sheetH * targetRatio;
                    }

                    final binderW = sheetW + spineW + paddingH;
                    final binderH = sheetH + paddingV;

                    return Center(
                      child: Container(
                        width: binderW,
                        height: binderH,
                        padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: theme.brightness == Brightness.dark
                                ? [
                                    const Color(0xFF1E1E24),
                                    const Color(0xFF141418),
                                    const Color(0xFF0D0D10),
                                  ]
                                : [
                                    const Color(0xFF3B2F2F),
                                    const Color(0xFF2B2222),
                                    const Color(0xFF1F1717),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.65),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // 3D Volumetric Page Stack Depth - Right Outer Edge
                            Positioned(
                              right: 2,
                              top: 10,
                              bottom: 10,
                              width: 5,
                              child: _buildPageStackEdgeRight(),
                            ),

                            // Layer 1: Spine Rings on Left - Back Ring Segment
                            Positioned(
                              left: 2,
                              top: 0,
                              bottom: 0,
                              width: 22,
                              child: IgnorePointer(
                                child: _buildSpineRings(theme, backOnly: true),
                              ),
                            ),

                            // Layer 2: 3D Single Binder Page Spread
                            Positioned.fill(
                              left: spineW,
                              top: 6,
                              bottom: 6,
                              right: 6,
                              child: _buildSinglePageSpread(
                                context: context,
                                sheetW: sheetW,
                                sheetH: sheetH,
                                spineW: spineW,
                                totalPages: totalPages,
                              ),
                            ),

                            // Layer 3: Spine Rings on Left - Front Ring Arches
                            Positioned(
                              left: 2,
                              top: 0,
                              bottom: 0,
                              width: 22,
                              child: IgnorePointer(
                                child: _buildSpineRings(theme, frontOnly: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Dual-page open binder layout (Desktop / Wide screen)
                  const double spineW = 28.0;
                  const double paddingH = 32.0;
                  const double paddingV = AppConstants.binderLeatherMarginV;

                  final availableW = (constraints.maxWidth - paddingH) * cardScale;
                  final availableH = (constraints.maxHeight - paddingV) * cardScale;

                  double sheetW = (availableW - spineW) / 2;
                  double sheetH = sheetW / targetRatio;

                  if (sheetH > availableH) {
                    sheetH = availableH;
                    sheetW = sheetH * targetRatio;
                  }

                  final maxSheetH = 680.0 * cardScale;
                  if (sheetH > maxSheetH) {
                    sheetH = maxSheetH;
                    sheetW = sheetH * targetRatio;
                  }

                  final binderW = sheetW * 2 + spineW + paddingH;
                  final binderH = sheetH + paddingV;

                  return Center(
                    child: Container(
                      width: binderW,
                      height: binderH,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: theme.brightness == Brightness.dark
                              ? [
                                  const Color(0xFF1E1E24),
                                  const Color(0xFF141418),
                                  const Color(0xFF0D0D10),
                                ]
                              : [
                                  const Color(0xFF3B2F2F),
                                  const Color(0xFF2B2222),
                                  const Color(0xFF1F1717),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.28),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.65),
                            blurRadius: 28,
                            spreadRadius: 4,
                            offset: const Offset(0, 14),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: -2,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Container(
                              width: spineW + 4,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.45),
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.15),
                                    Colors.black.withValues(alpha: 0.45),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 2,
                            top: 14,
                            bottom: 14,
                            width: 6,
                            child: _buildPageStackEdgeLeft(),
                          ),
                          Positioned(
                            right: 2,
                            top: 14,
                            bottom: 14,
                            width: 6,
                            child: _buildPageStackEdgeRight(),
                          ),
                          Center(
                            child: SizedBox(
                              width: 24,
                              child: IgnorePointer(
                                child: _buildSpineRings(theme, backOnly: true),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: 12,
                            bottom: 12,
                            child: _build3DBinderPagesSpread(
                              context: context,
                              sheetW: sheetW,
                              sheetH: sheetH,
                              spineW: spineW,
                              totalPages: totalPages,
                            ),
                          ),
                          Center(
                            child: SizedBox(
                              width: 24,
                              child: IgnorePointer(
                                child: _buildSpineRings(theme, frontOnly: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Binder Pagination and Action Bar (Compact & Overflow-proof on Android)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: Text(_strings.previous),
                    onPressed: _currentPage > 0 ? () => _goToPage(_currentPage - 1) : null,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _strings.pageOfTotal(_currentPage + 1, totalPages),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 6),
                      CardScaleButton(
                        target: CardScaleTarget.collection,
                        iconSize: 18,
                        tooltip: '${_strings.adjustScale} (${(cardScale * 100).round()}%)',
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: Text(_strings.next),
                    onPressed: _currentPage < totalPages - 1 ? () => _goToPage(_currentPage + 1) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3D Volumetric Page Depth (Paper edge layers on right)
  Widget _buildPageStackEdgeRight() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE8E5DD),
            Color(0xFFF7F5F0),
            Color(0xFFD6D1C4),
            Color(0xFFEDE9DF),
            Color(0xFFB0A999),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(1, 0),
          ),
        ],
      ),
    );
  }

  /// 3D Volumetric Page Depth (Paper edge layers on left)
  Widget _buildPageStackEdgeLeft() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          bottomLeft: Radius.circular(6),
        ),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0xFFE8E5DD),
            Color(0xFFF7F5F0),
            Color(0xFFD6D1C4),
            Color(0xFFEDE9DF),
            Color(0xFFB0A999),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(-1, 0),
          ),
        ],
      ),
    );
  }

  /// Builds realistic 3D binder mechanism with 6 compact matte D-rings (non-metallic, without center metal rail or rivets).
  /// [frontOnly]: if true, renders only the front half of the rings (in front of the pages/holes).
  /// [backOnly]: if true, renders the back half of the rings (behind the pages/holes).
  Widget _buildSpineRings(ThemeData theme, {bool frontOnly = false, bool backOnly = false}) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // 6 matte D-rings passing through the page holes (clean, non-metallic)
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) => _buildSingleDring(frontOnly: frontOnly, backOnly: backOnly)),
        ),
      ],
    );
  }

  /// Single D-ring with realistic 3D torus arch.
  /// Rings pass directly through the sheet holes:
  /// - Back curve goes under the paper sheets.
  /// - Front curve arches over the top of the sheets and through the holes.
  Widget _buildSingleDring({bool frontOnly = false, bool backOnly = false}) {
    return BinderSingleRing(frontOnly: frontOnly, backOnly: backOnly);
  }

  /// Double-page 3D Binder Pages Spread (Shows both sides of the binder: Left & Right)
  Widget _build3DBinderPagesSpread({
    required BuildContext context,
    required double sheetW,
    required double sheetH,
    required double spineW,
    required int totalPages,
  }) {
    final progress = _pageScrollProgress.clamp(0.0, (totalPages - 1).toDouble());
    final floorPage = progress.floor();
    final fraction = progress - floorPage;

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, sheetW),
      onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, sheetW),
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT SIDE SPREAD
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Base Left Sheet: Inside cover on page 0, or previous page on page > 0
                Positioned.fill(
                  child: floorPage == 0
                      ? _buildInsideCoverSheet(context, sheetW, sheetH)
                      : _buildBinderSheet(
                          context: context,
                          pageIndex: floorPage - 1,
                          isRightPage: false,
                          sheetW: sheetW,
                          sheetH: sheetH,
                        ),
                ),

                // Soft shadow on left sheet when a page is turning over onto it
                if (fraction > 0.001)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: [
                              Colors.black.withValues(alpha: 0.40 * fraction),
                              Colors.black.withValues(alpha: 0.12 * fraction),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // CENTER SPINE CLEARANCE (Spine & 6 rings mechanism area)
          SizedBox(width: spineW),

          // RIGHT SIDE SPREAD
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Underlying sheet revealed when turning forward
                if (fraction > 0.001)
                  Positioned.fill(
                    child: _buildBinderSheet(
                      context: context,
                      pageIndex: floorPage + 1,
                      isRightPage: true,
                      sheetW: sheetW,
                      sheetH: sheetH,
                    ),
                  ),

                // Base right sheet when idle
                if (fraction < 0.001)
                  Positioned.fill(
                    child: _buildBinderSheet(
                      context: context,
                      pageIndex: floorPage,
                      isRightPage: true,
                      sheetW: sheetW,
                      sheetH: sheetH,
                    ),
                  ),

                // Turning sheet: lifts from right, flips across center rings (0° to 180°), lands on left
                if (fraction >= 0.001)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: _turnAnimationController.isAnimating,
                      child: _buildTurningPageOverSpine(
                        context: context,
                        pageIndex: floorPage,
                        turnProgress: fraction,
                        sheetW: sheetW,
                        sheetH: sheetH,
                        spineW: spineW,
                        isTurningToLeft: true,
                      ),
                    ),
                  ),

                // Soft shadow on underlying right sheet when turning
                if (fraction > 0.001 && fraction < 0.5)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.35 * (1.0 - fraction * 2)),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Single-page 3D Binder Spread (Shows 1 page at a time on Android/Mobile screens)
  Widget _buildSinglePageSpread({
    required BuildContext context,
    required double sheetW,
    required double sheetH,
    required double spineW,
    required int totalPages,
  }) {
    final progress = _pageScrollProgress.clamp(0.0, (totalPages - 1).toDouble());
    final floorPage = progress.floor();
    final fraction = progress - floorPage;

    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: (details) => _onHorizontalDragUpdate(details, sheetW),
      onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, sheetW),
      behavior: HitTestBehavior.translucent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Underlying page (revealed as turning sheet flips forward)
          if (fraction > 0.001 && floorPage + 1 < totalPages)
            Positioned.fill(
              child: _buildBinderSheet(
                context: context,
                pageIndex: floorPage + 1,
                isRightPage: true,
                sheetW: sheetW,
                sheetH: sheetH,
              ),
            ),

          // Current base sheet when idle
          if (fraction < 0.001)
            Positioned.fill(
              child: _buildBinderSheet(
                context: context,
                pageIndex: floorPage,
                isRightPage: true,
                sheetW: sheetW,
                sheetH: sheetH,
              ),
            ),

          // Turning sheet (lifts from right, flips around left rings)
          if (fraction >= 0.001)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _turnAnimationController.isAnimating,
                child: _buildTurningPageSingle(
                  context: context,
                  pageIndex: floorPage,
                  turnProgress: fraction,
                  sheetW: sheetW,
                  sheetH: sheetH,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Transforms and renders the turning page pivoting around left rings in single-page mode.
  Widget _buildTurningPageSingle({
    required BuildContext context,
    required int pageIndex,
    required double turnProgress,
    required double sheetW,
    required double sheetH,
  }) {
    final double turnAngle = -turnProgress * (math.pi * 0.55);
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateY(turnAngle);

    final double opacity = (1.0 - turnProgress * 1.15).clamp(0.0, 1.0);

    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: matrix,
        alignment: Alignment.centerLeft,
        child: _buildBinderSheet(
          context: context,
          pageIndex: pageIndex,
          isRightPage: true,
          sheetW: sheetW,
          sheetH: sheetH,
        ),
      ),
    );
  }

  /// Transforms and renders the turning page pivoting over the central 6 metallic spine rings.
  /// The sheet's rotation axis is exactly centered on the metallic rings (x = -spineW / 2 from right sheet edge).
  /// As the user turns to the NEXT page, the paper slides along the ring loop from Right to Left
  /// across the 6 rings (0° to 180°), maintaining the ring curvature and settling onto the left side.
  Widget _buildTurningPageOverSpine({
    required BuildContext context,
    required int pageIndex,
    required double turnProgress,
    required double sheetW,
    required double sheetH,
    required double spineW,
    required bool isTurningToLeft,
  }) {
    final double turnAngle = turnProgress * math.pi; // 0° -> 180° (Flips OUTWARDS out of the screen towards the user)
    // Dynamic 3D arch matching the ring radius (12px radius) plus dynamic page lift
    const double ringRadius = 12.0;
    final double liftZ = -math.sin(turnProgress * math.pi) * (ringRadius + 24.0);
    final double ringSlideX = -math.sin(turnProgress * math.pi) * (ringRadius * 0.5);

    // Pivot axis is at the center of the ring spine: offset by -spineW / 2 from the right sheet's left edge
    final double pivotOffsetX = -spineW / 2;

    // ignore: deprecated_member_use
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.0012) // 3D perspective projection
      // ignore: deprecated_member_use
      ..translate(pivotOffsetX + ringSlideX, 0.0, liftZ)
      ..rotateY(turnAngle)
      // ignore: deprecated_member_use
      ..translate(-pivotOffsetX, 0.0, 0.0);

    final isBackFace = turnProgress >= 0.5;

    return Transform(
      transform: matrix,
      alignment: Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Front or back face of the binder sheet: Cards remain visible throughout the entire flip!
          if (!isBackFace)
            _buildBinderSheet(
              context: context,
              pageIndex: pageIndex,
              isRightPage: true,
              sheetW: sheetW,
              sheetH: sheetH,
            )
          else
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(math.pi),
              child: _buildBinderSheet(
                context: context,
                pageIndex: pageIndex,
                isRightPage: false,
                sheetW: sheetW,
                sheetH: sheetH,
              ),
            ),

          // Dynamic light sheen reflecting off the glossy PVC sleeve pockets during the flip
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment(-1.2 + turnProgress * 2.4, -1.0),
                    end: Alignment(-0.2 + turnProgress * 2.4, 1.0),
                    colors: [
                      Colors.transparent,
                      Colors.white.withValues(alpha: 0.15 * math.sin(turnProgress * math.pi)),
                      Colors.white.withValues(alpha: 0.32 * math.sin(turnProgress * math.pi)),
                      Colors.white.withValues(alpha: 0.05 * math.sin(turnProgress * math.pi)),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Inside Front Cover (Contracapa) of the binder
  /// Displays the felt-tip marker folder sticker tape along with collection statistics:
  /// Preço Total, Coleção Mais Comum, and Qualidade Média.
  Widget _buildInsideCoverSheet(BuildContext context, double sheetW, double sheetH) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);
    final exchangeRate = ref.watch(exchangeRateProvider);

    // 1. Preço Total
    double totalBrl = 0;
    for (final c in widget.cards) {
      final price = c.purchasePriceBrl > 0 ? c.purchasePriceBrl : 0.0;
      final qty = c.quantity > 0 ? c.quantity : 1;
      totalBrl += price * qty;
    }
    final formattedTotal = totalBrl > 0
        ? (currency == AppCurrency.usd
            ? CurrencyFormatter.toUsd(totalBrl / exchangeRate)
            : CurrencyFormatter.toBrl(totalBrl))
        : (currency == AppCurrency.usd ? r'$ 0.00' : 'R\$ 0,00');

    // 2. Coleção Mais Comum
    String mostCommonSet = '-';
    if (widget.cards.isNotEmpty) {
      final setCounts = <String, int>{};
      for (final c in widget.cards) {
        final s = c.setName.trim();
        if (s.isNotEmpty) {
          setCounts[s] = (setCounts[s] ?? 0) + (c.quantity > 0 ? c.quantity : 1);
        }
      }
      if (setCounts.isNotEmpty) {
        mostCommonSet = setCounts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }
    }

    // 3. Qualidade Média
    String avgConditionLabel = 'Near Mint';
    if (widget.cards.isNotEmpty) {
      final conditionScores = <String, double>{
        'MINT': 10.0,
        'NM': 9.0,
        'SP': 7.0,
        'MP': 5.0,
        'HP': 3.0,
        'DMG': 1.0,
      };
      double totalScore = 0;
      int totalCount = 0;
      for (final c in widget.cards) {
        final short = CardConditionHelper.getShortCondition(c.condition).toUpperCase();
        final score = short.contains('GRADUADA') ? 10.0 : (conditionScores[short] ?? 9.0);
        final qty = c.quantity > 0 ? c.quantity : 1;
        totalScore += score * qty;
        totalCount += qty;
      }
      final avg = totalCount > 0 ? totalScore / totalCount : 9.0;
      if (avg >= 9.5) {
        avgConditionLabel = 'Mint';
      } else if (avg >= 8.0) {
        avgConditionLabel = 'Near Mint';
      } else if (avg >= 6.0) {
        avgConditionLabel = 'Slightly Played';
      } else if (avg >= 4.0) {
        avgConditionLabel = 'Moderately Played';
      } else if (avg >= 2.0) {
        avgConditionLabel = 'Played';
      } else {
        avgConditionLabel = 'Damaged';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF191B20)
            : const Color(0xFFEBE8DF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(-2, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 6 reinforced punch hole eyelets on the RIGHT margin matching the 6 central rings
          Positioned(
            right: 3,
            top: 0,
            bottom: 0,
            width: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Hollow punched aperture with background shadow
                    color: Colors.black.withValues(alpha: 0.82),
                    border: Border.all(
                      // Clean punched hole rim (non-metallic)
                      color: Colors.black.withValues(alpha: 0.20),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 1.5,
                        offset: const Offset(0.5, 0.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Contracapa content layout
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Adhesive Marker Sticker Tape with folder name on Contracapa
                Center(
                  child: BinderStickerTape(name: widget.folderName ?? 'WURMDEX'),
                ),

                const SizedBox(height: 10),

                // 2. Collection Information Dashboard (Preço total, Coleção mais comum, Qualidade média)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with card count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_stories, size: 16, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 6),
                              Text(
                                _strings.navCollection.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${widget.cards.length} cartas',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, thickness: 0.6),
                      const SizedBox(height: 8),

                      // Stat 1: Preço Total
                      _buildContracapaStatRow(
                        icon: Icons.payments_outlined,
                        iconColor: AppColors.profitGreen,
                        label: 'Preço Total',
                        value: formattedTotal,
                        valueColor: AppColors.profitGreen,
                      ),
                      const SizedBox(height: 6),

                      // Stat 2: Coleção Mais Comum
                      _buildContracapaStatRow(
                        icon: Icons.style_outlined,
                        iconColor: const Color(0xFFD4AF37),
                        label: 'Mais Comum',
                        value: mostCommonSet,
                      ),
                      const SizedBox(height: 6),

                      // Stat 3: Qualidade Média
                      _buildContracapaStatRow(
                        icon: Icons.verified_outlined,
                        iconColor: Colors.blueAccent,
                        label: 'Qualidade Média',
                        value: avgConditionLabel,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // 3. Stitched Portfolio Sleeve Pocket
                Container(
                  height: sheetH * 0.36,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF141518)
                        : const Color(0xFFDDD9CD),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Diagonal decorative stitch
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 3,
                        child: Container(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.style,
                            size: 34,
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'WURMDEX PORTFOLIO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '9-POCKET ULTRA PRO SLEEVES',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContracapaStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildBinderSheet({
    required BuildContext context,
    required int pageIndex,
    required bool isRightPage,
    required double sheetW,
    required double sheetH,
  }) {
    final theme = Theme.of(context);
    final startIndex = pageIndex * _pageSize;
    final pageCards = pageIndex >= 0 && startIndex < widget.cards.length
        ? widget.cards.skip(startIndex).take(_pageSize).toList()
        : <UserCard>[];

    // Margins depend on whether this is the left sheet or right sheet
    // Punch holes face the central rings (right margin on left sheet, left margin on right sheet)
    final double leftMargin = isRightPage ? 20 : 10;
    final double rightMargin = isRightPage ? 10 : 20;
    const double topMargin = 10;
    const double bottomMargin = 10;
    const double crossSpacing = 6;
    const double mainSpacing = 6;

    final gridW = sheetW - leftMargin - rightMargin;
    final gridH = sheetH - topMargin - bottomMargin;
    final slotW = (gridW - (crossSpacing * 2)) / 3;
    final slotH = (gridH - (mainSpacing * 2)) / 3;
    final calculatedAspectRatio = slotH > 0 ? (slotW / slotH) : AppConstants.pokemonCardAspectRatio;

    return Container(
      decoration: BoxDecoration(
        // Ultra-clean binder leaf background with subtle polymer texture
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF22242B)
            : const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          // Page drop shadow onto underlying folio
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: Offset(isRightPage ? 3 : -3, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 6 reinforced punch hole eyelets facing the central rings
          Positioned(
            left: isRightPage ? 3 : null,
            right: !isRightPage ? 3 : null,
            top: 0,
            bottom: 0,
            width: 14,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Hollow punched aperture with background shadow
                    color: Colors.black.withValues(alpha: 0.82),
                    border: Border.all(
                      // Clean punched hole rim (non-metallic)
                      color: Colors.black.withValues(alpha: 0.20),
                      width: 0.6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 1.5,
                        offset: const Offset(0.5, 0.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 4.5,
                      height: 4.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // 3x3 Card Pockets
          Padding(
            padding: EdgeInsets.only(
              left: leftMargin,
              right: rightMargin,
              top: topMargin,
              bottom: bottomMargin,
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: calculatedAspectRatio,
                crossAxisSpacing: crossSpacing,
                mainAxisSpacing: mainSpacing,
              ),
              itemCount: _pageSize,
              itemBuilder: (context, slotIndex) {
                if (slotIndex < pageCards.length) {
                  final card = pageCards[slotIndex];
                  final isGlowing = _activeHighlightId != null &&
                      (_activeHighlightId == card.id || _activeHighlightId == card.cardApiId);

                  return CardShimmerGlow(
                    isGlowing: isGlowing,
                    child: BinderPocketCard(card: card, strings: _strings),
                  );
                } else {
                  return BinderEmptyPocket(
                    onAdd: widget.onAddCard,
                    label: _strings.emptySlot,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


