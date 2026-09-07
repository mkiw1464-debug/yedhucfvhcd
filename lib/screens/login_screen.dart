import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/theme.dart';
import '../widgets/glass_card.dart';
import '../services/license_service.dart';
import '../models/license_model.dart';

class LoginScreen extends StatefulWidget {
  final String languageCode;
  final String deviceId;
  final ValueChanged<({String key, LicenseResponse license})> onSuccess;

  const LoginScreen({
    super.key,
    required this.languageCode,
    required this.deviceId,
    required this.onSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _keyCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscure = true;

  @override
  void dispose() {
    _keyCtrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await LicenseService.validate(
        key: key,
        deviceId: widget.deviceId,
      );

      if (result.isActive && !result.isExpired) {
        await LicenseService.saveKey(key);
        widget.onSuccess((key: key, license: result));
      } else if (result.isExpired) {
        setState(() => _error = 'License expired');
      } else {
        setState(() => _error = 'Invalid license key');
      }
    } catch (e) {
      setState(() => _error = 'Network error. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FFTheme.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  FFTheme.accent.withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [FFTheme.accent, Color(0xFF3B6FDB)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: FFTheme.accent.withOpacity(0.45),
                              blurRadius: 32,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.key_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.7, 0.7)),
                      const SizedBox(height: 20),
                      const Text(
                        'FF External',
                        style: TextStyle(
                          color: FFTheme.textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.6,
                        ),
                      ).animate().fadeIn(delay: 150.ms),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter your license key to continue',
                        style: TextStyle(
                          color: FFTheme.textSecondary,
                          fontSize: 15,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Card
                  GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'License Key',
                          style: TextStyle(
                            color: FFTheme.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _keyCtrl,
                          obscureText: _obscure,
                          style: const TextStyle(
                            color: FFTheme.textPrimary,
                            fontSize: 15,
                            fontFamily: 'Menlo',
                            letterSpacing: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: 'FFEX-XXXX-XXXX-XXXX',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: FFTheme.textMuted,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          onSubmitted: (_) => _validate(),
                        ),

                        // Error
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: FFTheme.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: FFTheme.red.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: FFTheme.red, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      color: FFTheme.red,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().shake(),
                        ],

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: GlassButton(
                            label: _loading ? 'Validating...' : 'Validate',
                            loading: _loading,
                            onPressed: _loading ? null : _validate,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Telegram
                  GestureDetector(
                    onTap: () => launchUrl(
                        Uri.parse('https://t.me/ffexternal'),
                        mode: LaunchMode.externalApplication),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF229ED9).withOpacity(0.2),
                            ),
                            child: const Icon(Icons.send_rounded,
                                color: Color(0xFF229ED9), size: 18),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Join Telegram for Updates',
                                  style: TextStyle(
                                    color: FFTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  't.me/ffexternal',
                                  style: TextStyle(
                                    color: FFTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: FFTheme.textMuted, size: 14),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 450.ms, duration: 400.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
