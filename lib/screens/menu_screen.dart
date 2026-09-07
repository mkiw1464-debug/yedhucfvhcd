import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/feature_tile.dart';
import '../widgets/inject_terminal.dart';
import '../services/inject_service.dart';
import '../services/license_service.dart';
import '../models/license_model.dart';

class MenuScreen extends StatefulWidget {
  final String licenseKey;
  final LicenseResponse license;
  final String deviceId;

  const MenuScreen({
    super.key,
    required this.licenseKey,
    required this.license,
    required this.deviceId,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  int _selectedTab = 0;

  // Feature availability + inject state per game
  final Map<GameTarget, Map<FeatureKey, bool>> _availability = {
    GameTarget.freeFire: {},
    GameTarget.freeFireMax: {},
  };
  final Map<GameTarget, Map<FeatureKey, bool>> _injected = {
    GameTarget.freeFire: {},
    GameTarget.freeFireMax: {},
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) return;
      setState(() => _selectedTab = _tabCtrl.index);
    });
    _loadAvailability();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    for (final game in GameTarget.values) {
      for (final feature in FeatureKey.values) {
        final avail =
            await InjectService.isFeatureAvailable(game, feature);
        final inj = await InjectService.isInjected(game, feature);
        if (!mounted) return;
        setState(() {
          _availability[game]![feature] = avail;
          _injected[game]![feature] = inj;
        });
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  void _showTerminal(GameTarget game, FeatureKey feature,
      {bool restore = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => InjectTerminalSheet(
        featureName: feature.displayName,
        gameName: game.displayName,
        isRestore: restore,
        onComplete: () async {
          Navigator.pop(context);
          try {
            if (restore) {
              await InjectService.restore(game, feature);
            } else {
              await InjectService.inject(game, feature);
            }
          } catch (_) {}
          if (!mounted) return;
          setState(() {
            _injected[game]![feature] = !restore;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = _selectedTab == 0
        ? GameTarget.freeFire
        : GameTarget.freeFireMax;

    return Scaffold(
      backgroundColor: FFTheme.bg,
      body: Stack(
        children: [
          // Glow bg
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  FFTheme.accent.withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildKeyInfoBar(),
                const SizedBox(height: 4),
                _buildGameTabs(),
                const SizedBox(height: 8),
                _buildTutorialBanner(),
                const SizedBox(height: 12),
                Expanded(child: _buildFeatureList(game)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              gradient: const LinearGradient(
                colors: [FFTheme.accent, Color(0xFF3B6FDB)],
              ),
            ),
            child: const Icon(Icons.games_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FF External',
                style: TextStyle(
                  color: FFTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Cheat Injector',
                style: TextStyle(
                  color: FFTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => launchUrl(Uri.parse('https://t.me/ffexternal'),
                mode: LaunchMode.externalApplication),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF229ED9).withOpacity(0.12),
                border: Border.all(
                    color: const Color(0xFF229ED9).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.send_rounded,
                      color: Color(0xFF229ED9), size: 14),
                  SizedBox(width: 5),
                  Text(
                    'Updates',
                    style: TextStyle(
                      color: Color(0xFF229ED9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildKeyInfoBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            _infoChip(
              label: 'Key',
              value: LicenseService.maskKey(widget.licenseKey),
              icon: Icons.key_rounded,
              color: FFTheme.accent,
            ),
            const SizedBox(width: 12),
            _infoChip(
              label: 'Device',
              value: widget.deviceId.length > 12
                  ? widget.deviceId.substring(0, 12)
                  : widget.deviceId,
              icon: Icons.phone_iphone_rounded,
              color: const Color(0xFF34C759),
            ),
            const SizedBox(width: 12),
            _infoChip(
              label: 'Expires',
              value: widget.license.formattedExpiry,
              icon: Icons.timer_outlined,
              color: FFTheme.orange,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _infoChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 11),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: FFTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: FFTheme.textPrimary,
              fontSize: 11,
              fontFamily: 'Menlo',
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGameTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: FFTheme.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: FFTheme.glassBorder),
        ),
        child: TabBar(
          controller: _tabCtrl,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            gradient: LinearGradient(
              colors: [FFTheme.accent, FFTheme.accent.withOpacity(0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: FFTheme.accent.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          indicatorPadding: const EdgeInsets.all(4),
          dividerColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: FFTheme.textSecondary,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Free Fire'),
            Tab(text: 'Free Fire Max'),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildTutorialBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: FFTheme.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FFTheme.orange.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded,
                color: FFTheme.orange, size: 15),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Inject features while in lobby and turn off when entering the game',
                style: TextStyle(
                  color: FFTheme.orange,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 280.ms, duration: 400.ms);
  }

  Widget _buildFeatureList(GameTarget game) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: FFTheme.accent,
          strokeWidth: 2,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: FeatureKey.values.length,
      itemBuilder: (context, index) {
        final feature = FeatureKey.values[index];
        final avail = _availability[game]![feature] ?? false;
        final inj = _injected[game]![feature] ?? false;

        return FeatureTile(
          feature: feature,
          available: avail,
          injected: inj,
          index: index,
          onInject: avail && !inj
              ? () => _showTerminal(game, feature)
              : null,
          onRestore: inj
              ? () => _showTerminal(game, feature, restore: true)
              : null,
        );
      },
    );
  }
}
