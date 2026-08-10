import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/evidence_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final eventsCount = context.watch<EvidenceProvider>().events.length;
    final wearable = MockData.wearable;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Profile header ─────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A006A), AppColors.primary],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user,
                                  color: Colors.greenAccent, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Usuario Activo',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            title: const Text('Mi Perfil'),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Stats row ──────────────────────────────────────────
                Row(
                  children: [
                    _StatTile(
                      label: 'Eventos',
                      value: '$eventsCount',
                      icon: Icons.shield_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      label: 'Miembro desde',
                      value: DateFormat('MMM yyyy', 'es_MX')
                          .format(user.createdAt),
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.primaryAccent,
                    ),
                    const SizedBox(width: 12),
                    _StatTile(
                      label: 'Dispositivo',
                      value: wearable.statusLabel,
                      icon: Icons.watch_outlined,
                      color: AppColors.wearableConnected,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Personal info ──────────────────────────────────────
                _SectionCard(
                  title: 'Información personal',
                  icon: Icons.person_outline,
                  children: [
                    _InfoTile(
                        icon: Icons.badge_outlined,
                        label: 'Nombre completo',
                        value: user.fullName),
                    _InfoTile(
                        icon: Icons.email_outlined,
                        label: 'Correo',
                        value: user.email),
                    _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: user.phone),
                    _InfoTile(
                        icon: Icons.home_outlined,
                        label: 'Domicilio',
                        value: user.address),
                  ],
                ),
                const SizedBox(height: 12),

                // ── Account settings ───────────────────────────────────
                _SectionCard(
                  title: 'Cuenta',
                  icon: Icons.settings_outlined,
                  children: [
                    _ActionTile(
                      icon: Icons.lock_outline,
                      label: 'Cambiar contraseña',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Solicitud enviada al administrador del sistema.'),
                        ),
                      ),
                    ),
                    _ActionTile(
                      icon: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Política de privacidad',
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.help_outline,
                      label: 'Soporte técnico',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ── App info ───────────────────────────────────────────
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SecurityIA Fem',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Versión 1.0.0 · Mockup',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Logout ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.emergency,
                      side: const BorderSide(color: AppColors.emergency),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    onPressed: () => _confirmLogout(context),
                  ),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text(
            'Serás redirigido a la pantalla de inicio de sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emergency),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (_) => false);
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

// ─── Supporting widgets ────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: AppColors.textSecondary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: AppColors.textSecondary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }
}
