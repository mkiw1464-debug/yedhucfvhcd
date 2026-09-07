import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/theme.dart';
import '../widgets/glass_card.dart';

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

const List<LanguageOption> kLanguages = [
  LanguageOption(
      code: 'en', name: 'English', nativeName: 'English', flag: '🇺🇸'),
  LanguageOption(
      code: 'id',
      name: 'Indonesian',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩'),
  LanguageOption(
      code: 'pt',
      name: 'Brazilian',
      nativeName: 'Português (BR)',
      flag: '🇧🇷'),
  LanguageOption(
      code: 'vi', name: 'Vietnamese', nativeName: 'Tiếng Việt', flag: '🇻🇳'),
  LanguageOption(
      code: 'zh',
      name: 'Taiwan',
      nativeName: '繁體中文 (台灣)',
      flag: '🇹🇼'),
];

class LanguageScreen extends StatefulWidget {
  final ValueChanged<String> onLanguageSelected;

  const LanguageScreen({super.key, required this.onLanguageSelected});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FFTheme.bg,
      body: Stack(
        children: [
          // Background glow blobs
          Positioned(
            top: -100,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  FFTheme.accent.withOpacity(0.15),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  FFTheme.accentGlow.withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                FFTheme.accent,
                                FFTheme.accent.withOpacity(0.6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: FFTheme.accent.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.games_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.7, 0.7)),
                        const SizedBox(height: 16),
                        const Text(
                          'FF External',
                          style: TextStyle(
                            color: FFTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideX(begin: -0.1),

                  const SizedBox(height: 4),
                  Text(
                    'Choose your preferred language',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView.separated(
                      itemCount: kLanguages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lang = kLanguages[index];
                        final isSelected = _selected == lang.code;
                        return _LanguageTile(
                          lang: lang,
                          selected: isSelected,
                          onTap: () => setState(() => _selected = lang.code),
                        )
                            .animate()
                            .fadeIn(
                                delay: Duration(milliseconds: 400 + index * 60),
                                duration: 350.ms)
                            .slideY(begin: 0.15);
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      label: 'Continue',
                      onPressed: () =>
                          widget.onLanguageSelected(_selected),
                    ),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final LanguageOption lang;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? FFTheme.accent : FFTheme.glassBorder,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? FFTheme.accent.withOpacity(0.12)
              : FFTheme.glass,
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      color: selected
                          ? FFTheme.textPrimary
                          : FFTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    lang.name,
                    style: const TextStyle(
                      color: FFTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: selected ? 1.0 : 0.0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: FFTheme.accent,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
