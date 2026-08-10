import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/evidence_provider.dart';
import '../../providers/notes_provider.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final events = context.watch<EvidenceProvider>().events;
    final upcoming = context.watch<NotesProvider>().upcomingAppointments;
    final wearable = MockData.wearable;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A006A), AppColors.primary],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        user?.initials ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, ${user?.name ?? 'Usuario'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            DateFormat('EEEE d MMMM', 'es_MX').format(DateTime.now()),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Inicio'),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Wearable Card ──────────────────────────────────────────
                _WearableCard(wearable: wearable),
                const SizedBox(height: 16),

                // ── Acciones rápidas ───────────────────────────────────────
                const Text(
                  'Acciones rápidas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _QuickActionsGrid(),
                const SizedBox(height: 24),

                // ── Último evento ──────────────────────────────────────────
                if (events.isNotEmpty) ...[
                  const Text(
                    'Último evento',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _EventSummaryCard(event: events.first),
                  const SizedBox(height: 24),
                ],

                // ── Próximas citas ─────────────────────────────────────────
                if (upcoming.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximas citas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...upcoming
                      .take(2)
                      .map((a) => _AppointmentTile(appointment: a)),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wearable Status Card ──────────────────────────────────────────────────────

class _WearableCard extends StatelessWidget {
  final WearableModel wearable;
  const _WearableCard({required this.wearable});

  @override
  Widget build(BuildContext context) {
    final isConnected = wearable.status == WearableStatus.connected;
    final color =
        isConnected ? AppColors.wearableConnected : AppColors.wearableDisconnected;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/wearable'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isConnected
                ? [const Color(0xFF6B008E), const Color(0xFF8B2FC0)]
                : [const Color(0xFF424242), const Color(0xFF616161)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.watch, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wearable.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isConnected ? Colors.greenAccent : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        wearable.statusLabel,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(
                      wearable.batteryLevel > 20
                          ? Icons.battery_full
                          : Icons.battery_alert,
                      color: wearable.batteryLevel > 20
                          ? Colors.greenAccent
                          : Colors.orangeAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${wearable.batteryLevel}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Ver detalles',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Actions Grid ────────────────────────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.video_library_outlined,
        label: 'Mis\nEvidencias',
        color: AppColors.primary,
        onTap: () {}, // Handled by BottomNavBar tab 1
      ),
      _QuickAction(
        icon: Icons.chat_bubble_outline,
        label: 'Chat con\nAgente',
        color: AppColors.primaryLight,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.event_note_outlined,
        label: 'Bloc de\nNotas',
        color: AppColors.brandOrange,
        onTap: () {},
      ),
      _QuickAction(
        icon: Icons.watch_outlined,
        label: 'Mi\nWearable',
        color: AppColors.primaryAccent,
        onTap: () => Navigator.pushNamed(context, '/wearable'),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: actions.map((a) => _QuickActionTile(action: a)).toList(),
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _QuickActionTile extends StatelessWidget {
  final _QuickAction action;
  const _QuickActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action.icon, color: action.color, size: 26),
            const SizedBox(height: 6),
            Text(
              action.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: action.color,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Last Event Summary ────────────────────────────────────────────────────────

class _EventSummaryCard extends StatelessWidget {
  final EventModel event;
  const _EventSummaryCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final stressColor = event.stressLevel >= 0.7
        ? AppColors.stressHigh
        : event.stressLevel >= 0.4
            ? AppColors.stressMedium
            : AppColors.stressLow;

    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: event.type == EventType.emergency
                          ? AppColors.emergencyLight
                          : AppColors.infoLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.typeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: event.type == EventType.emergency
                            ? AppColors.emergency
                            : AppColors.info,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      event.statusLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd/MM · HH:mm').format(event.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      event.location ?? 'Ubicación no disponible',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stress level bar
              Row(
                children: [
                  const Text(
                    'Nivel de estrés',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: event.stressLevel,
                        backgroundColor: AppColors.divider,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(stressColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(event.stressLevel * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: stressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Duración: ${event.durationLabel}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  const Icon(Icons.video_library_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${event.evidenceIds.length} archivos',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Appointment Tile ──────────────────────────────────────────────────────────

class _AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = appointment.isConfirmed;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isConfirmed
                ? AppColors.primarySurface
                : AppColors.warningLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            appointment.isReminder ? Icons.alarm : Icons.event,
            color: isConfirmed ? AppColors.primary : AppColors.warning,
            size: 20,
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${DateFormat('dd MMM, HH:mm', 'es_MX').format(appointment.dateTime)}  •  ${appointment.agentName}',
          style:
              const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConfirmed ? AppColors.successLight : AppColors.warningLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isConfirmed ? 'Confirmado' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isConfirmed ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
      ),
    );
  }
}
