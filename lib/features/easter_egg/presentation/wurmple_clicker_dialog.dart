import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/app_preferences_service.dart';
import '../../../../core/theme/theme_constants.dart';
import '../../../../core/theme/theme_provider.dart';

enum ClickerCharacter {
  wurmple,
  wurmpleShiny,
  lugia,
  lugiaShiny,
  darkLugia,
}

class ClickerUpgrade {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int baseCost;
  final double wpsGain;
  final int wpcGain;
  int count;

  ClickerUpgrade({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.baseCost,
    this.wpsGain = 0,
    this.wpcGain = 0,
    this.count = 0,
  });

  int get cost => (baseCost * math.pow(1.15, count)).round();
}

class WurmpleClickerDialog extends ConsumerStatefulWidget {
  final ClickerCharacter initialCharacter;

  const WurmpleClickerDialog({
    super.key,
    this.initialCharacter = ClickerCharacter.wurmple,
  });

  static Future<void> show(
    BuildContext context, {
    ClickerCharacter character = ClickerCharacter.wurmple,
  }) {
    return showDialog(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (ctx) => WurmpleClickerDialog(initialCharacter: character),
    );
  }

  @override
  ConsumerState<WurmpleClickerDialog> createState() => _WurmpleClickerDialogState();
}

class _FloatingNumber {
  final Key key;
  final Offset position;
  final String text;
  final DateTime createdAt;

  _FloatingNumber({
    required this.key,
    required this.position,
    required this.text,
    required this.createdAt,
  });
}

class _BurstParticle {
  final double angle;
  final double speed;
  final double initialScale;
  final double rotation;

  _BurstParticle({
    required this.angle,
    required this.speed,
    required this.initialScale,
    required this.rotation,
  });
}

class _WurmpleClickerDialogState extends ConsumerState<WurmpleClickerDialog>
    with TickerProviderStateMixin {
  late ClickerCharacter _character;
  double _totalPoints = 0;
  int _clickCount = 0;
  Timer? _ticker;
  DateTime _lastTick = DateTime.now();

  late AnimationController _characterSquashController;
  late Animation<double> _characterScaleAnimation;

  // 10-click Milestone Burst Animation Controller
  late AnimationController _burstController;
  bool _showBurst = false;
  final List<_BurstParticle> _particles = [];
  final List<_FloatingNumber> _floatingNumbers = [];

  List<ClickerUpgrade> _upgrades = [];

  bool get _isLugiaFamily =>
      _character == ClickerCharacter.lugia ||
      _character == ClickerCharacter.lugiaShiny ||
      _character == ClickerCharacter.darkLugia;

  String get _characterTitle {
    switch (_character) {
      case ClickerCharacter.wurmple:
        return 'Wurmple Clicker';
      case ClickerCharacter.wurmpleShiny:
        return 'Shiny Wurmple Clicker';
      case ClickerCharacter.lugia:
        return 'Lugia Clicker';
      case ClickerCharacter.lugiaShiny:
        return 'Shiny Lugia Clicker';
      case ClickerCharacter.darkLugia:
        return 'Dark Lugia Clicker';
    }
  }

  String get _pointsLabel {
    switch (_character) {
      case ClickerCharacter.wurmple:
      case ClickerCharacter.wurmpleShiny:
        return 'Wurmples';
      case ClickerCharacter.lugia:
      case ClickerCharacter.lugiaShiny:
        return 'Lugia Power';
      case ClickerCharacter.darkLugia:
        return 'Shadow Energy';
    }
  }

  String get _mainArtworkAsset {
    switch (_character) {
      case ClickerCharacter.wurmple:
        return 'assets/images/characters/265.png';
      case ClickerCharacter.wurmpleShiny:
        return 'assets/images/characters/265_shiny.png';
      case ClickerCharacter.lugia:
        return 'assets/images/characters/249.png';
      case ClickerCharacter.lugiaShiny:
        return 'assets/images/characters/249_shiny.png';
      case ClickerCharacter.darkLugia:
        return 'assets/images/characters/dark_lugia.png';
    }
  }

  String get _burstAsset {
    switch (_character) {
      case ClickerCharacter.wurmple:
        return 'assets/images/clicker/wurmple_burst.png';
      case ClickerCharacter.wurmpleShiny:
        return 'assets/images/menu/wurmple_shiny_menu.png';
      case ClickerCharacter.lugia:
      case ClickerCharacter.lugiaShiny:
      case ClickerCharacter.darkLugia:
        return 'assets/images/clicker/lugiaboon.png';
    }
  }

  int get _pointsPerClick {
    int wpc = 1;
    for (final up in _upgrades) {
      wpc += up.wpcGain * up.count;
    }
    return wpc;
  }

  double get _pointsPerSecond {
    double wps = 0;
    for (final up in _upgrades) {
      wps += up.wpsGain * up.count;
    }
    return wps;
  }

  @override
  void initState() {
    super.initState();
    _character = widget.initialCharacter;
    _initUpgrades();
    _loadState();

    _characterSquashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );
    _characterScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.88), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.88, end: 1.06), weight: 35),
      TweenSequenceItem(tween: Tween<double>(begin: 1.06, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _characterSquashController,
      curve: Curves.easeOut,
    ));

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _burstController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _showBurst = false);
      }
    });

    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
      _lastTick = now;

      if (_pointsPerSecond > 0 && mounted) {
        setState(() {
          _totalPoints += _pointsPerSecond * dt;
        });
      }

      if (_floatingNumbers.isNotEmpty) {
        final cutOff = now.subtract(const Duration(milliseconds: 1200));
        _floatingNumbers.removeWhere((f) => f.createdAt.isBefore(cutOff));
      }
    });
  }

  void _initUpgrades() {
    if (_isLugiaFamily) {
      _upgrades = [
        ClickerUpgrade(
          id: 'whirlpool',
          name: 'Redemoinho (Whirlpool)',
          description: '+0.5 por segundo',
          icon: Icons.waves,
          baseCost: 15,
          wpsGain: 0.5,
        ),
        ClickerUpgrade(
          id: 'silver_wing',
          name: 'Asa de Prata (Silver Wing)',
          description: '+1 por clique',
          icon: Icons.flight,
          baseCost: 40,
          wpcGain: 1,
        ),
        ClickerUpgrade(
          id: 'diving_bell',
          name: 'Sino dos Mares',
          description: '+4 por segundo',
          icon: Icons.notifications_active,
          baseCost: 120,
          wpsGain: 4.0,
        ),
        ClickerUpgrade(
          id: 'aeroblast',
          name: 'Rajada de Vento (Aeroblast)',
          description: '+5 por clique',
          icon: Icons.air,
          baseCost: 350,
          wpcGain: 5,
        ),
        ClickerUpgrade(
          id: 'ocean_current',
          name: 'Correnteza Abissal',
          description: '+16 por segundo',
          icon: Icons.water,
          baseCost: 1000,
          wpsGain: 16.0,
        ),
        ClickerUpgrade(
          id: 'guardian_sanctuary',
          name: 'Santuário do Guardião',
          description: '+45 por segundo',
          icon: Icons.temple_buddhist,
          baseCost: 3500,
          wpsGain: 45.0,
        ),
        ClickerUpgrade(
          id: 'deep_trench',
          name: 'Fossa Oceânica Profunda',
          description: '+150 por segundo',
          icon: Icons.south,
          baseCost: 12000,
          wpsGain: 150.0,
        ),
        ClickerUpgrade(
          id: 'psychic_storm',
          name: 'Tempestade Psíquica',
          description: '+500 por segundo',
          icon: Icons.bolt,
          baseCost: 40000,
          wpsGain: 500.0,
        ),
        ClickerUpgrade(
          id: 'whirl_islands_temple',
          name: 'Templo das Ilhas dos Redemoinhos',
          description: '+2.000 por segundo',
          icon: Icons.castle,
          baseCost: 150000,
          wpsGain: 2000.0,
        ),
      ];
    } else {
      _upgrades = [
        ClickerUpgrade(
          id: 'string_shot',
          name: 'Tiro de Seda (String Shot)',
          description: '+0.5 por segundo',
          icon: Icons.gesture,
          baseCost: 15,
          wpsGain: 0.5,
        ),
        ClickerUpgrade(
          id: 'pecha_berry',
          name: 'Fruta Pêssego (Pecha Berry)',
          description: '+1 por clique',
          icon: Icons.eco,
          baseCost: 40,
          wpcGain: 1,
        ),
        ClickerUpgrade(
          id: 'bug_catcher',
          name: 'Caçador de Insetos (Bug Catcher)',
          description: '+4 por segundo',
          icon: Icons.catching_pokemon,
          baseCost: 120,
          wpsGain: 4.0,
        ),
        ClickerUpgrade(
          id: 'poison_barb',
          name: 'Ferrão Venenoso (Poison Barb)',
          description: '+5 por clique',
          icon: Icons.colorize,
          baseCost: 350,
          wpcGain: 5,
        ),
        ClickerUpgrade(
          id: 'silcoon_cocoon',
          name: 'Casulo Silcoon',
          description: '+16 por segundo',
          icon: Icons.shield_outlined,
          baseCost: 1000,
          wpsGain: 16.0,
        ),
        ClickerUpgrade(
          id: 'cascoon_cocoon',
          name: 'Casulo Cascoon',
          description: '+45 por segundo',
          icon: Icons.lens,
          baseCost: 3500,
          wpsGain: 45.0,
        ),
        ClickerUpgrade(
          id: 'beautifly_garden',
          name: 'Jardim de Beautifly',
          description: '+150 por segundo',
          icon: Icons.flutter_dash,
          baseCost: 12000,
          wpsGain: 150.0,
        ),
        ClickerUpgrade(
          id: 'dustox_swarm',
          name: 'Enxame Noturno Dustox',
          description: '+500 por segundo',
          icon: Icons.nights_stay,
          baseCost: 40000,
          wpsGain: 500.0,
        ),
        ClickerUpgrade(
          id: 'shiny_shrine',
          name: 'Santuário Wurmple',
          description: '+2.000 por segundo',
          icon: Icons.stars,
          baseCost: 150000,
          wpsGain: 2000.0,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _characterSquashController.dispose();
    _burstController.dispose();
    _saveState();
    super.dispose();
  }

  void _loadState() {
    final data = _isLugiaFamily
        ? AppPreferencesService.getLugiaClickerData()
        : AppPreferencesService.getWurmpleClickerData();

    if (data != null) {
      _totalPoints = (data['total'] as num?)?.toDouble() ?? 0.0;
      _clickCount = (data['clicks'] as num?)?.toInt() ?? 0;
      final upMap = data['upgrades'];
      if (upMap is Map<String, dynamic>) {
        for (final up in _upgrades) {
          if (upMap.containsKey(up.id)) {
            up.count = (upMap[up.id] as num?)?.toInt() ?? 0;
          }
        }
      }
    }
  }

  void _saveState() {
    final upMap = <String, int>{};
    for (final up in _upgrades) {
      upMap[up.id] = up.count;
    }
    final map = {
      'total': _totalPoints,
      'clicks': _clickCount,
      'upgrades': upMap,
    };
    if (_isLugiaFamily) {
      AppPreferencesService.saveLugiaClickerData(map);
    } else {
      AppPreferencesService.saveWurmpleClickerData(map);
    }
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetar Progresso?'),
        content: const Text(
          'Deseja realmente resetar o minigame? Sua pontuação e upgrades retornarão ao início.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.heavyImpact();
              setState(() {
                _totalPoints = 0;
                _clickCount = 0;
                for (final up in _upgrades) {
                  up.count = 0;
                }
              });
              _saveState();
            },
            child: const Text('Sim, Resetar'),
          ),
        ],
      ),
    );
  }

  void _buyShinyTheme() {
    const cost = 1000000;
    if (_totalPoints < cost) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _totalPoints -= cost;
      if (_isLugiaFamily) {
        AppPreferencesService.setLugiaShinyUnlocked(true);
        ref.read(themeProvider.notifier).setTheme(AppThemeMode.lugiaShiny);
        _character = ClickerCharacter.lugiaShiny;
      } else {
        AppPreferencesService.setWurmpleShinyUnlocked(true);
        ref.read(themeProvider.notifier).setTheme(AppThemeMode.wurmpleShiny);
        _character = ClickerCharacter.wurmpleShiny;
      }
    });
    _saveState();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.purple.shade900,
        content: Row(
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isLugiaFamily
                    ? 'Parabéns! Tema Shiny Lugia desbloqueado e ativado!'
                    : 'Parabéns! Tema Shiny Wurmple desbloqueado e ativado!',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleClick(TapDownDetails details) {
    HapticFeedback.lightImpact();
    _characterSquashController.forward(from: 0.0);

    final wpc = _pointsPerClick;
    setState(() {
      _totalPoints += wpc;
      _clickCount++;

      // Floating number
      _floatingNumbers.add(
        _FloatingNumber(
          key: UniqueKey(),
          position: details.localPosition,
          text: '+$wpc',
          createdAt: DateTime.now(),
        ),
      );

      // Check 10-click milestone
      if (_clickCount % 10 == 0) {
        _triggerMilestoneBurst();
      }
    });
  }

  void _triggerMilestoneBurst() {
    HapticFeedback.heavyImpact();
    _particles.clear();
    final rng = math.Random();
    const particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final baseAngle = (i / particleCount) * 2 * math.pi;
      final jitter = (rng.nextDouble() - 0.5) * 0.3;
      _particles.add(
        _BurstParticle(
          angle: baseAngle + jitter,
          speed: 130 + rng.nextDouble() * 90,
          initialScale: 0.8 + rng.nextDouble() * 0.5,
          rotation: (rng.nextDouble() - 0.5) * 4 * math.pi,
        ),
      );
    }

    setState(() => _showBurst = true);
    _burstController.forward(from: 0.0);
  }

  void _buyUpgrade(ClickerUpgrade upgrade) {
    if (_totalPoints >= upgrade.cost) {
      HapticFeedback.mediumImpact();
      setState(() {
        _totalPoints -= upgrade.cost;
        upgrade.count++;
      });
      _saveState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canBuyShiny = _totalPoints >= 1000000;
    final isShinyUnlocked = _isLugiaFamily
        ? AppPreferencesService.isLugiaShinyUnlocked()
        : AppPreferencesService.isWurmpleShinyUnlocked();

    return Dialog.fullscreen(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar (Fullscreen Header without icon in corner)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _characterTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Resetar progresso',
                    onPressed: _resetProgress,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Score Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        _totalPoints.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        _pointsLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 36, width: 1, color: theme.dividerColor),
                  Column(
                    children: [
                      Text(
                        '+${_pointsPerSecond.toStringAsFixed(1)}/s',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      Text(
                        'Por Segundo',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(height: 36, width: 1, color: theme.dividerColor),
                  Column(
                    children: [
                      Text(
                        '+$_pointsPerClick',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      Text(
                        'Por Clique',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Clicker Stage with Character Artwork & Burst Animation
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Radial Glow Behind Character
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          theme.colorScheme.primary.withValues(alpha: 0.28),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Clickable Character
                  Center(
                    child: GestureDetector(
                      onTapDown: _handleClick,
                      child: ScaleTransition(
                        scale: _characterScaleAnimation,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 230, maxWidth: 230),
                          child: Image.asset(
                            _mainArtworkAsset,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, size: 100),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Floating "+1" Numbers
                  for (final fn in _floatingNumbers)
                    Positioned(
                      left: fn.position.dx,
                      top: fn.position.dy,
                      child: _FloatingNumberWidget(
                        text: fn.text,
                        createdAt: fn.createdAt,
                      ),
                    ),

                  // 10-Click Milestone Burst Overlay
                  if (_showBurst)
                    AnimatedBuilder(
                      animation: _burstController,
                      builder: (context, child) {
                        final t = _burstController.value;
                        if (t <= 0.35) {
                          final p1 = t / 0.35;
                          final scale = (0.2 + (p1 * 1.1)).clamp(0.0, 1.4);
                          final opacity = p1.clamp(0.0, 1.0);
                          return Opacity(
                            opacity: opacity,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.amber.withValues(alpha: 0.6),
                                      blurRadius: 20,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  _burstAsset,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        } else {
                          final p2 = (t - 0.35) / 0.65;
                          final opacity = (1.0 - p2).clamp(0.0, 1.0);

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              for (final p in _particles) ...[
                                Transform.translate(
                                  offset: Offset(
                                    math.cos(p.angle) * p.speed * p2,
                                    math.sin(p.angle) * p.speed * p2,
                                  ),
                                  child: Transform.rotate(
                                    angle: p.rotation * p2,
                                    child: Transform.scale(
                                      scale: (p.initialScale * (1.0 - (p2 * 0.4))).clamp(0.1, 1.5),
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Image.asset(
                                          _burstAsset,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        }
                      },
                    ),

                  // Total clicks badge (WITHOUT "(explosao a cada 10)")
                  Positioned(
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        'Total de cliques: $_clickCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Shiny Unlock Banner (1 Million Points Unlock)
            if (!isShinyUnlocked)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade900.withValues(alpha: 0.7),
                      Colors.indigo.shade900.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: canBuyShiny ? Colors.amber : Colors.purple.shade400,
                    width: canBuyShiny ? 2 : 1,
                  ),
                  boxShadow: canBuyShiny
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isLugiaFamily ? 'Desbloquear Tema Shiny Lugia' : 'Desbloquear Tema Shiny Wurmple',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Custa 1.000.000 pontos. Mantém upgrades e pontuação!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: canBuyShiny ? Colors.amber : Colors.white24,
                        foregroundColor: canBuyShiny ? Colors.black : Colors.white60,
                      ),
                      onPressed: canBuyShiny ? _buyShinyTheme : null,
                      child: const Text('1.000.000', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

            // Upgrades Header (WITHOUT "Compre melhorias com seus wurmples")
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'UPGRADES & EVOLUÇÃO',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),

            // Upgrades List
            Expanded(
              flex: 5,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: _upgrades.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final up = _upgrades[index];
                  final canAfford = _totalPoints >= up.cost;

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: canAfford ? 0.6 : 0.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canAfford
                            ? theme.colorScheme.primary.withValues(alpha: 0.5)
                            : theme.dividerColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(up.icon, color: theme.colorScheme.primary, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      up.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (up.count > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Nv. ${up.count}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                up.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: canAfford
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: canAfford
                                ? Colors.white
                                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: canAfford ? () => _buyUpgrade(up) : null,
                          child: Text(
                            '${up.cost}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNumberWidget extends StatefulWidget {
  final String text;
  final DateTime createdAt;

  const _FloatingNumberWidget({
    required this.text,
    required this.createdAt,
  });

  @override
  State<_FloatingNumberWidget> createState() => _FloatingNumberWidgetState();
}

class _FloatingNumberWidgetState extends State<_FloatingNumberWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateY;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _translateY = Tween<double>(begin: 0, end: -50).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateY.value),
          child: Opacity(
            opacity: _opacity.value,
            child: child,
          ),
        );
      },
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: Colors.amberAccent,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
