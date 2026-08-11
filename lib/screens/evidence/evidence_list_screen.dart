import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/evidence_provider.dart';
import '../../theme/app_theme.dart';

class EvidenceListScreen extends StatefulWidget {
  const EvidenceListScreen({super.key});

  @override
  State<EvidenceListScreen> createState() => _EvidenceListScreenState();
}

class _EvidenceListScreenState extends State<EvidenceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EvidenceProvider>().refreshEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.redAccent),
            tooltip: 'Grabar con Webcam',
            onPressed: () => Navigator.pushNamed(context, '/webcam-recorder'),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/webcam-recorder'),
        backgroundColor: Colors.red.shade900,
        icon: const Icon(Icons.videocam, color: Colors.white),
        label: const Text('GRABAR WEBCAM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<EvidenceProvider>(
        builder: (_, provider, __) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.events.isEmpty) {
            return const _EmptyState();
          }
          return RefreshIndicator(
            onRefresh: provider.refreshEvents,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final event = provider.events[i];
                final evidences = provider.getEvidenceForEvent(event.id);
                return _EventCard(
                  event: event,
                  evidences: evidences,
                  onTap: () => _openFirstEvidence(context, evidences),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _openFirstEvidence(BuildContext context, List<EvidenceModel> evidences) {
    if (evidences.isEmpty) return;
    Navigator.pushNamed(
      context,
      '/evidence-viewer',
      arguments: evidences.first.id,
    );
  }
}

// ─── Event Card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  final EventModel event;
  final List<EvidenceModel> evidences;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.evidences,
    required this.onTap,
  });

  Color get _stressColor {
    if (event.stressLevel >= 0.7) return AppColors.stressHigh;
    if (event.stressLevel >= 0.4) return AppColors.stressMedium;
    return AppColors.stressLow;
  }

  @override
  Widget build(BuildContext context) {
    final isEmergency = event.type == EventType.emergency;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isEmergency
                          ? AppColors.emergencyLight
                          : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEmergency
                          ? Icons.warning_rounded
                          : Icons.science_outlined,
                      color: isEmergency ? AppColors.emergency : AppColors.info,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.typeLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy · HH:mm', 'es_MX')
                              .format(event.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(event: event),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // ── Location ────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location ?? 'Ubicación no disponible',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Stress bar ──────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.psychology_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  const Text('Estrés',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: event.stressLevel,
                        backgroundColor: AppColors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(_stressColor),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(event.stressLevel * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _stressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Footer ──────────────────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    event.durationLabel,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  // Evidence chips
                  if (evidences.any((e) => e.type == EvidenceType.video))
                    _EvidenceChip(
                        icon: Icons.videocam_outlined, label: 'Video'),
                  const SizedBox(width: 6),
                  if (evidences.any((e) => e.type == EvidenceType.audio))
                    _EvidenceChip(icon: Icons.mic_outlined, label: 'Audio'),
                ],
              ),

              // ── Notes ───────────────────────────────────────────────────
              if (event.notes != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    event.notes!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final EventModel event;
  const _StatusChip({required this.event});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (event.status) {
      case EventStatus.active:
        bg = AppColors.emergencyLight;
        fg = AppColors.emergency;
        break;
      case EventStatus.resolved:
        bg = AppColors.successLight;
        fg = AppColors.success;
        break;
      case EventStatus.pending:
        bg = AppColors.warningLight;
        fg = AppColors.warning;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        event.statusLabel,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _EvidenceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _EvidenceChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.primary),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined, size: 64, color: AppColors.textHint),
          SizedBox(height: 16),
          Text(
            'Sin eventos registrados',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
          SizedBox(height: 8),
          Text(
            'Los eventos de emergencia aparecerán aquí',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
