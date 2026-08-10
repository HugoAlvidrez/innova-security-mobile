import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../models/models.dart';
import '../../providers/evidence_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class EvidenceViewerScreen extends StatefulWidget {
  final String evidenceId;
  const EvidenceViewerScreen({super.key, required this.evidenceId});

  @override
  State<EvidenceViewerScreen> createState() => _EvidenceViewerScreenState();
}

class _EvidenceViewerScreenState extends State<EvidenceViewerScreen>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isLoadingMedia = false;
  bool _isVideoReady = false;
  double _playbackPosition = 0.0; // 0–1
  String? _mediaUrl;
  VideoPlayerController? _videoController;
  late final AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMediaMetadata();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMediaMetadata() async {
    final provider = context.read<EvidenceProvider>();
    final evidence = provider.getEvidenceById(widget.evidenceId);
    if (evidence == null) return;

    final event = provider.getEventForEvidence(evidence.id);
    if (event == null) return;

    setState(() => _isLoadingMedia = true);
    final mediaResult = await ApiService().getEventMedia(event.id);
    if (mediaResult != null) {
      final mediaUrl = mediaResult['videoUrl']?.toString() ??
          mediaResult['audioUrl']?.toString();
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        setState(() {
          _mediaUrl = mediaUrl;
        });
        if (evidence.type == EvidenceType.video) {
          await _initializeVideo(mediaUrl);
        }
      }
    }
    setState(() => _isLoadingMedia = false);
  }

  Future<void> _initializeVideo(String url) async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.setVolume(0.8);
      setState(() {
        _isVideoReady = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Video initialization failed: $e');
      }
    }
  }

  void _togglePlay() {
    if (_videoController != null && _isVideoReady) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      setState(() {
        _isPlaying = _videoController!.value.isPlaying;
      });
    } else {
      setState(() => _isPlaying = !_isPlaying);
      if (_isPlaying) {
        _waveCtrl.repeat();
      } else {
        _waveCtrl.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<EvidenceProvider>();
    final evidence = provider.getEvidenceById(widget.evidenceId);
    final event = evidence != null
        ? provider.getEventForEvidence(evidence.id)
        : null;

    if (evidence == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Evidencia')),
        body: const Center(child: Text('Evidencia no encontrada')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        title: Text(
          evidence.type == EvidenceType.video ? 'Video' : 'Audio',
        ),
        actions: [
          // NO download button per spec – read-only viewer
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context, evidence, event),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Player area ──────────────────────────────────────────────────
          Expanded(
            flex: evidence.type == EvidenceType.video ? 5 : 3,
            child: evidence.type == EvidenceType.video
                ? (_mediaUrl != null && _isVideoReady && _videoController != null
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController!),
                            if (!_videoController!.value.isPlaying)
                              const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white54,
                                size: 72,
                              ),
                          ],
                        ),
                      )
                    : _VideoPlayerMock(
                        isPlaying: _isPlaying,
                        position: _playbackPosition,
                      ))
                : _AudioPlayerMock(
                    isPlaying: _isPlaying,
                    waveCtrl: _waveCtrl,
                    evidence: evidence,
                  ),
          ),

          // ── Controls ─────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                // Seek bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _playbackPosition,
                    onChanged: (v) =>
                        setState(() => _playbackPosition = v),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _positionLabel(evidence.durationSeconds),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                      Text(
                        evidence.durationLabel,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Playback controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white70),
                      iconSize: 28,
                      onPressed: () => setState(() =>
                          _playbackPosition =
                              (_playbackPosition - 0.05).clamp(0, 1)),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white70),
                      iconSize: 28,
                      onPressed: () => setState(() =>
                          _playbackPosition =
                              (_playbackPosition + 0.05).clamp(0, 1)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Metadata & AI Analysis ─────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              color: AppColors.background,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metadata
                    _MetaChips(evidence: evidence, event: event),
                    const SizedBox(height: 16),

                    // AI Analysis
                    if (evidence.stressLevel != null) ...[
                      _SectionTitle(
                        icon: Icons.psychology_outlined,
                        title: 'Análisis de IA – Nivel de estrés',
                      ),
                      const SizedBox(height: 8),
                      _StressBar(level: evidence.stressLevel!),
                      const SizedBox(height: 16),
                    ],

                    // Transcription
                    if (evidence.transcription != null) ...[
                      _SectionTitle(
                        icon: Icons.subtitles_outlined,
                        title: 'Transcripción automática',
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          evidence.transcription!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    if (_isLoadingMedia)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white10,
                          color: AppColors.primary,
                        ),
                      ),
                    if (!_isLoadingMedia && _mediaUrl != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Media backend disponible',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Text(
                              _mediaUrl!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Read-only notice
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline,
                              size: 14, color: AppColors.primary),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Evidencia inmutable. Solo lectura — sin descarga ni edición.',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _positionLabel(int totalSeconds) {
    final elapsed = (totalSeconds * _playbackPosition).round();
    final m = elapsed ~/ 60;
    final s = elapsed % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _showInfo(BuildContext ctx, EvidenceModel e, EventModel? ev) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información del archivo',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _InfoRow('ID', e.id),
            _InfoRow('Tipo',
                e.type == EvidenceType.video ? 'Video MP4' : 'Audio AAC'),
            _InfoRow('Duración', e.durationLabel),
            _InfoRow(
                'Fecha',
                DateFormat('dd/MM/yyyy HH:mm:ss').format(e.timestamp)),
            if (ev != null) _InfoRow('Evento', ev.typeLabel),
            const SizedBox(height: 12),
            const Text(
              '⚠ Este archivo es evidencia digital inmutable y parte de la cadena de custodia.',
              style:
                  TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Video Player Mock ─────────────────────────────────────────────────────────

class _VideoPlayerMock extends StatelessWidget {
  final bool isPlaying;
  final double position;
  const _VideoPlayerMock({required this.isPlaying, required this.position});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: const Color(0xFF0D0D0D),
          child: CustomPaint(
            painter: _GridPainter(),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPlaying ? Icons.videocam : Icons.videocam_outlined,
                    color: Colors.white24,
                    size: 56,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'VIDEO – SIMULACIÓN MOCKUP',
                    style: TextStyle(color: Colors.white24, fontSize: 11, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isPlaying)
          const Center(
            child: Icon(Icons.play_circle_outline,
                color: Colors.white38, size: 72),
          ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
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

// ─── Audio Player Mock ─────────────────────────────────────────────────────────

class _AudioPlayerMock extends StatelessWidget {
  final bool isPlaying;
  final AnimationController waveCtrl;
  final EvidenceModel evidence;

  const _AudioPlayerMock({
    required this.isPlaying,
    required this.waveCtrl,
    required this.evidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0A1A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryAccent, width: 2),
            ),
            child: const Icon(Icons.graphic_eq, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: AnimatedBuilder(
              animation: waveCtrl,
              builder: (_, __) => CustomPaint(
                size: const Size(double.infinity, 50),
                painter: _AudioWaveformPainter(
                  progress: isPlaying ? waveCtrl.value : 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AudioWaveformPainter extends CustomPainter {
  final double progress;
  _AudioWaveformPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryAccent.withOpacity(0.8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const bars = 40;
    final barWidth = size.width / bars;

    for (int i = 0; i < bars; i++) {
      final h = 4 +
          (math.sin(i * 0.5 + progress * math.pi * 2) * 0.5 + 0.5) *
              (size.height - 8);
      final x = i * barWidth + barWidth / 2;
      canvas.drawLine(
        Offset(x, size.height / 2 - h / 2),
        Offset(x, size.height / 2 + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AudioWaveformPainter old) => old.progress != progress;
}

// ─── Supporting Widgets ────────────────────────────────────────────────────────

class _MetaChips extends StatelessWidget {
  final EvidenceModel evidence;
  final EventModel? event;
  const _MetaChips({required this.evidence, this.event});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: Icon(
            evidence.type == EvidenceType.video
                ? Icons.videocam
                : Icons.mic,
            size: 14,
            color: AppColors.primary,
          ),
          label: Text(evidence.type == EvidenceType.video ? 'Video' : 'Audio'),
        ),
        Chip(
          avatar: const Icon(Icons.timer_outlined, size: 14, color: AppColors.primary),
          label: Text(evidence.durationLabel),
        ),
        Chip(
          avatar: const Icon(Icons.calendar_today_outlined,
              size: 14, color: AppColors.primary),
          label: Text(DateFormat('dd/MM/yy').format(evidence.timestamp)),
        ),
        if (event != null)
          Chip(
            avatar: const Icon(Icons.event_outlined,
                size: 14, color: AppColors.primary),
            label: Text(event!.typeLabel),
          ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _StressBar extends StatelessWidget {
  final double level;
  const _StressBar({required this.level});

  Color get _color {
    if (level >= 0.7) return AppColors.stressHigh;
    if (level >= 0.4) return AppColors.stressMedium;
    return AppColors.stressLow;
  }

  String get _label {
    if (level >= 0.7) return 'ALTO';
    if (level >= 0.4) return 'MEDIO';
    return 'BAJO';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: level,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(_color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(level * 100).toInt()}% – $_label',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: _color,
          ),
        ),
      ],
    );
  }
}
