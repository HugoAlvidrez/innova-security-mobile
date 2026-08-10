import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../providers/emergency_provider.dart';
import '../../theme/app_theme.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _waveCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
    _pulseAnim = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Activate immediately on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ep = context.read<EmergencyProvider>();
      if (!ep.isActive) ep.activateEmergency();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  void _confirmCancel() {
    HapticFeedback.mediumImpact();
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cancelar emergencia?'),
        content: const Text(
          'El centro de monitoreo será notificado de la cancelación. Esta acción quedará registrada en el sistema.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('NO, MANTENER'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emergency,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SÍ, CANCELAR'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed == true && mounted) {
        await context.read<EmergencyProvider>().cancelEmergency();
        if (mounted) Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EmergencyProvider>(
      builder: (context, ep, _) {
        final isActivating = ep.state == EmergencyState.activating;
        final isActive = ep.state == EmergencyState.active;
        final isCancelling = ep.state == EmergencyState.cancelling;

        return PopScope(
          canPop: false, // Prevent accidental back
          child: Scaffold(
            backgroundColor: const Color(0xFF1A0030),
            body: SafeArea(
              child: Column(
                children: [
                  // ── Top bar ─────────────────────────────────────────────
                  _TopBar(
                    isActive: isActive,
                    elapsedLabel: ep.elapsedLabel,
                    onCancel: !isActivating && !isCancelling ? _confirmCancel : null,
                  ),

                  // ── "Live Camera" simulation ─────────────────────────────
                  Expanded(
                    flex: 5,
                    child: _LiveStreamMock(
                      isActive: isActive,
                      waveCtrl: _waveCtrl,
                    ),
                  ),

                  // ── Status & Stress ──────────────────────────────────────
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          // Status row
                          _StatusRow(
                            isActivating: isActivating,
                            isActive: isActive,
                            isCancelling: isCancelling,
                          ),
                          const SizedBox(height: 20),

                          // Stress level
                          if (isActive) ...[
                            _StressGauge(
                              stressLevel: ep.stressLevel,
                              stressLabel: ep.stressLabel,
                              pulseAnim: _pulseAnim,
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Audio waveform
                          if (isActive)
                            _AudioWaveform(waveCtrl: _waveCtrl),

                          const Spacer(),

                          // Cancel button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: (isActivating || isCancelling)
                                  ? null
                                  : _confirmCancel,
                              icon: isCancelling
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : const Icon(Icons.cancel_outlined),
                              label: Text(isCancelling
                                  ? 'Cancelando…'
                                  : 'Cancelar emergencia'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool isActive;
  final String elapsedLabel;
  final VoidCallback? onCancel;

  const _TopBar({
    required this.isActive,
    required this.elapsedLabel,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: onCancel,
          ),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'EMERGENCIA ACTIVA',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                if (isActive) ...[
                  const SizedBox(height: 2),
                  Text(
                    elapsedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

// ── Live Stream Mock ───────────────────────────────────────────────────────────

class _LiveStreamMock extends StatelessWidget {
  final bool isActive;
  final AnimationController waveCtrl;

  const _LiveStreamMock({required this.isActive, required this.waveCtrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // "Camera feed" placeholder
        Container(
          color: const Color(0xFF0D0D0D),
          child: isActive
              ? _CameraGridOverlay()
              : const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text(
                        'Iniciando transmisión…',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                ),
        ),

        // Overlay badges
        if (isActive) ...[
          Positioned(
            top: 12,
            left: 12,
            child: _Badge(
              icon: Icons.fiber_manual_record,
              label: 'EN VIVO',
              color: Colors.red,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _Badge(
              icon: Icons.cloud_upload_outlined,
              label: 'Transmitiendo',
              color: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: _Badge(
              icon: Icons.location_on,
              label: 'GPS Activo',
              color: Colors.green,
            ),
          ),
        ],
      ],
    );
  }
}

class _CameraGridOverlay extends StatefulWidget {
  const _CameraGridOverlay();

  @override
  State<_CameraGridOverlay> createState() => _CameraGridOverlayState();
}

class _CameraGridOverlayState extends State<_CameraGridOverlay> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
      );
      await _controller!.initialize();
      await _controller!.setLooping(true);
      await _controller!.setVolume(0.0);
      await _controller!.play();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
          CustomPaint(painter: _GridPainter()),
        ],
      );
    }
    return CustomPaint(
      painter: _GridPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFF1A1A2E), Color(0xFF050505)],
          ),
        ),
        child: const Center(
          child: Text(
            'TRANSMISIÓN DE CÁMARA EN VIVO\n(Video Stock de Emergencia)',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Status Row ─────────────────────────────────────────────────────────────────

class _StatusRow extends StatelessWidget {
  final bool isActivating, isActive, isCancelling;
  const _StatusRow(
      {required this.isActivating,
      required this.isActive,
      required this.isCancelling});

  @override
  Widget build(BuildContext context) {
    final indicators = [
      _StatusDot(
          label: 'Grabación',
          active: isActive,
          icon: Icons.mic,
          color: Colors.red),
      _StatusDot(
          label: 'Video',
          active: isActive,
          icon: Icons.videocam,
          color: Colors.red),
      _StatusDot(
          label: 'GPS',
          active: isActive,
          icon: Icons.location_on,
          color: Colors.green),
      _StatusDot(
          label: 'Centro',
          active: isActive,
          icon: Icons.cell_tower,
          color: Colors.blue),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: indicators,
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final Color color;

  const _StatusDot(
      {required this.label,
      required this.active,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? color.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: active ? color : Colors.white24,
              width: 1.5,
            ),
          ),
          child: Icon(icon,
              color: active ? color : Colors.white38, size: 18),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// ── Stress Gauge ───────────────────────────────────────────────────────────────

class _StressGauge extends StatelessWidget {
  final double stressLevel;
  final String stressLabel;
  final Animation<double> pulseAnim;

  const _StressGauge({
    required this.stressLevel,
    required this.stressLabel,
    required this.pulseAnim,
  });

  Color get _color {
    if (stressLevel >= 0.7) return Colors.red;
    if (stressLevel >= 0.4) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              const Text(
                'IA · Análisis de voz – Nivel de estrés',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Spacer(),
              ScaleTransition(
                scale: pulseAnim,
                child: Text(
                  stressLabel,
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: stressLevel,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(stressLevel * 100).toInt()}% detectado en tiempo real',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Audio Waveform ─────────────────────────────────────────────────────────────

class _AudioWaveform extends StatelessWidget {
  final AnimationController waveCtrl;
  const _AudioWaveform({required this.waveCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: waveCtrl,
      builder: (_, __) {
        return CustomPaint(
          size: const Size(double.infinity, 40),
          painter: _WaveformPainter(progress: waveCtrl.value),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  _WaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.redAccent.withOpacity(0.8)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const barCount = 30;
    final barWidth = size.width / barCount;

    for (int i = 0; i < barCount; i++) {
      final seed = (i * 7 + (progress * barCount).toInt()) % barCount;
      final height = 4 +
          (math.sin(seed * 0.7 + progress * math.pi * 2) * 0.5 + 0.5) *
              (size.height - 8);
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - height / 2),
        Offset(x, size.height / 2 + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.progress != progress;
}
