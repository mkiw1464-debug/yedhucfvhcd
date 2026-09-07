import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/inject_service.dart';
import '../widgets/theme.dart';

class FeatureTile extends StatelessWidget {
  final FeatureKey feature;
  final bool available;
  final bool injected;
  final VoidCallback? onInject;
  final VoidCallback? onRestore;
  final int index;

  const FeatureTile({
    super.key,
    required this.feature,
    required this.available,
    this.injected = false,
    this.onInject,
    this.onRestore,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: FFTheme.glass,
          border: Border.all(
            color: injected
                ? FFTheme.green.withOpacity(0.5)
                : FFTheme.glassBorder,
            width: injected ? 1.5 : 1,
          ),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: available
                    ? (injected
                        ? FFTheme.green.withOpacity(0.15)
                        : FFTheme.accent.withOpacity(0.12))
                    : FFTheme.textMuted.withOpacity(0.08),
              ),
              child: Icon(
                _iconFor(feature),
                color: available
                    ? (injected ? FFTheme.green : FFTheme.accent)
                    : FFTheme.textMuted,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // Name + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.displayName,
                    style: TextStyle(
                      color: available
                          ? FFTheme.textPrimary
                          : FFTheme.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: injected
                              ? FFTheme.green
                              : available
                                  ? FFTheme.accent
                                  : FFTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        injected
                            ? 'Injected'
                            : available
                                ? 'Available'
                                : 'Unavailable',
                        style: TextStyle(
                          color: injected
                              ? FFTheme.green
                              : available
                                  ? FFTheme.textSecondary
                                  : FFTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Button
            if (!available)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: FFTheme.textMuted.withOpacity(0.1),
                ),
                child: const Text(
                  'N/A',
                  style: TextStyle(
                    color: FFTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (injected)
              GestureDetector(
                onTap: onRestore,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: FFTheme.red.withOpacity(0.12),
                    border: Border.all(
                        color: FFTheme.red.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'Restore',
                    style: TextStyle(
                      color: FFTheme.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: onInject,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        FFTheme.accent,
                        FFTheme.accent.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: FFTheme.accent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'INJECT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: index * 70), duration: 350.ms)
          .slideX(begin: 0.06),
    );
  }

  IconData _iconFor(FeatureKey f) {
    switch (f) {
      case FeatureKey.aimBody:
        return Icons.person_pin_rounded;
      case FeatureKey.aimNeck:
        return Icons.accessibility_new_rounded;
      case FeatureKey.aimDrag:
        return Icons.gps_fixed_rounded;
      case FeatureKey.magicBullet:
        return Icons.auto_fix_high_rounded;
      case FeatureKey.antena:
        return Icons.settings_input_antenna_rounded;
      case FeatureKey.hologram:
        return Icons.view_in_ar_rounded;
    }
  }
}
