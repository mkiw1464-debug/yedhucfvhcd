import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'theme.dart';

class InjectTerminalSheet extends StatefulWidget {
  final String featureName;
  final String gameName;
  final VoidCallback onComplete;
  final bool isRestore;

  const InjectTerminalSheet({
    super.key,
    required this.featureName,
    required this.gameName,
    required this.onComplete,
    this.isRestore = false,
  });

  @override
  State<InjectTerminalSheet> createState() => _InjectTerminalSheetState();
}

class _InjectTerminalSheetState extends State<InjectTerminalSheet> {
  final List<String> _lines = [];
  bool _done = false;
  bool _success = false;

  late final List<String> _logLines;

  @override
  void initState() {
    super.initState();
    if (widget.isRestore) {
      _logLines = [
        '> initializing restore sequence...',
        '> locating backup: ${widget.gameName}/${widget.featureName}',
        '> checking backup integrity... OK',
        '> acquiring container access...',
        '> sandbox token: granted',
        '> reading original file... ${(50 + widget.featureName.length * 3)}KB',
        '> writing to gameassetbundles/...',
        '> verifying checksum... match',
        '> cleanup: removing cheat payload',
        '> flush complete.',
        '> RESTORE SUCCESSFUL ✓',
      ];
    } else {
      _logLines = [
        '> initializing inject engine...',
        '> target: ${widget.gameName}',
        '> feature: ${widget.featureName}',
        '> resolving container path...',
        '> MCM: com.dts.${widget.gameName.contains("Max") ? "freefiremax" : "freefireth"}',
        '> backup: saving original assets...',
        '> downloading payload: ${widget.featureName}.bundle',
        '> verifying signature... OK',
        '> writing to Documents/contentcache/...',
        '> gameassetbundles: patched',
        '> flush + sync... done',
        '> INJECTION SUCCESSFUL ✓',
      ];
    }
    _startSequence();
  }

  Future<void> _startSequence() async {
    for (var i = 0; i < _logLines.length; i++) {
      await Future.delayed(Duration(milliseconds: 220 + i * 30));
      if (!mounted) return;
      setState(() => _lines.add(_logLines[i]));
    }
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _done = true;
      _success = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: FFTheme.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FFTheme.red,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FFTheme.orange,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: FFTheme.green,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                widget.isRestore ? 'restore.sh' : 'inject.sh',
                style: const TextStyle(
                  color: FFTheme.textSecondary,
                  fontSize: 13,
                  fontFamily: 'Menlo',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: FFTheme.divider, height: 1),
          const SizedBox(height: 12),

          // Terminal log
          Container(
            constraints: const BoxConstraints(maxHeight: 280),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines
                    .map((line) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            line,
                            style: TextStyle(
                              color: line.contains('SUCCESSFUL') ||
                                      line.contains('✓')
                                  ? FFTheme.green
                                  : line.startsWith('> ')
                                      ? FFTheme.textSecondary
                                      : FFTheme.textPrimary,
                              fontSize: 12,
                              fontFamily: 'Menlo',
                            ),
                          ).animate().fadeIn(duration: 150.ms),
                        ))
                    .toList(),
              ),
            ),
          ),

          // Blinking cursor
          if (!_done)
            const Text(
              '█',
              style: TextStyle(
                color: FFTheme.accent,
                fontSize: 14,
                fontFamily: 'Menlo',
              ),
            ).animate(onPlay: (c) => c.repeat()).fadeIn().then().fadeOut(),

          // Success state
          if (_success) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: FFTheme.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: FFTheme.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    widget.isRestore
                        ? Icons.restore_rounded
                        : Icons.check_circle_rounded,
                    color: FFTheme.green,
                    size: 40,
                  )
                      .animate()
                      .scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 400.ms,
                          curve: Curves.elasticOut),
                  const SizedBox(height: 8),
                  Text(
                    widget.isRestore
                        ? 'Restored to Default'
                        : 'Injection Successful!',
                    style: const TextStyle(
                      color: FFTheme.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
