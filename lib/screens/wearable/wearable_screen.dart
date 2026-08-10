import 'dart:async';
import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';

class WearableScreen extends StatefulWidget {
  const WearableScreen({super.key});

  @override
  State<WearableScreen> createState() => _WearableScreenState();
}

class _WearableScreenState extends State<WearableScreen>
    with TickerProviderStateMixin {
  late WearableModel _wearable;
  bool _isPairing = false;
  late AnimationController _pairingCtrl;
  late Animation<double> _pairingAnim;

  @override
  void initState() {
    super.initState();
    _wearable = MockData.wearable;
    _pairingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pairingAnim =
        Tween(begin: 0.7, end: 1.0).animate(_pairingCtrl);
  }

  @override
  void dispose() {
    _pairingCtrl.dispose();
    super.dispose();
  }

  void _simulatePairing() async {
    setState(() {
      _isPairing = true;
      _wearable.status = WearableStatus.pairing;
    });
    _pairingCtrl.repeat(reverse: true);
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isPairing = false;
        _wearable.status = WearableStatus.connected;
      });
      _pairingCtrl.stop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Wearable emparejado exitosamente'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _wearable.status == WearableStatus.connected;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Wearable')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Device hero card ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isConnected
                      ? [const Color(0xFF4A006A), const Color(0xFF8B2FC0)]
                      : [const Color(0xFF37474F), const Color(0xFF546E7A)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Watch icon with pulse
                  ScaleTransition(
                    scale: _isPairing ? _pairingAnim : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.watch, color: Colors.white, size: 52),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _wearable.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _wearable.modelName,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: isConnected
                              ? Colors.greenAccent
                              : Colors.orangeAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _wearable.statusLabel,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Stats row ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.battery_full,
                    label: 'Batería',
                    value: '${_wearable.batteryLevel}%',
                    color: _wearable.batteryLevel > 30
                        ? AppColors.success
                        : AppColors.emergency,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.sync,
                    label: 'Último sync',
                    value: '${DateTime.now().difference(_wearable.lastSync!).inMinutes} min',
                    color: AppColors.brandOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.system_update_outlined,
                    label: 'Firmware',
                    value: _wearable.firmwareVersion,
                    color: AppColors.primaryAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Battery bar ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.battery_charging_full_outlined,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text('Nivel de batería',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _wearable.batteryLevel / 100,
                        backgroundColor: AppColors.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _wearable.batteryLevel > 30
                              ? AppColors.success
                              : _wearable.batteryLevel > 15
                                  ? AppColors.warning
                                  : AppColors.emergency,
                        ),
                        minHeight: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _wearable.batteryLevel > 30
                          ? 'Batería suficiente'
                          : 'Batería baja — conecta tu dispositivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: _wearable.batteryLevel > 30
                            ? AppColors.textSecondary
                            : AppColors.emergency,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Actions ─────────────────────────────────────────────────
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bluetooth_searching,
                          color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      _isPairing ? 'Emparejando…' : 'Emparejar dispositivo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Vincula o reemplaza tu wearable',
                        style: TextStyle(fontSize: 12)),
                    trailing: _isPairing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.chevron_right),
                    onTap: _isPairing ? null : _simulatePairing,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.system_update_outlined,
                          color: AppColors.info, size: 20),
                    ),
                    title: const Text('Actualizar firmware',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Versión actual: v2.4.1',
                        style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Firmware actualizado a v2.4.2'),
                        backgroundColor: AppColors.info,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emergencyLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.link_off,
                          color: AppColors.emergency, size: 20),
                    ),
                    title: const Text('Desvincular dispositivo',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.emergency)),
                    subtitle: const Text('Elimina la asociación del wearable',
                        style: TextStyle(fontSize: 12)),
                    trailing:
                        const Icon(Icons.chevron_right, color: AppColors.emergency),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('¿Desvincular wearable?'),
                        content: const Text(
                            'Se eliminará la asociación. Podrás vincular un nuevo dispositivo después.'),
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
                              setState(() =>
                                  _wearable.status = WearableStatus.disconnected);
                            },
                            child: const Text('Desvincular'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
