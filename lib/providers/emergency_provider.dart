import 'dart:async';
import 'package:flutter/foundation.dart';

enum EmergencyState { idle, activating, active, cancelling }

class EmergencyProvider extends ChangeNotifier {
  EmergencyState _state = EmergencyState.idle;
  int _elapsedSeconds = 0;
  double _stressLevel = 0.0;
  Timer? _cronTimer;
  Timer? _stressTimer;

  EmergencyState get state => _state;
  int get elapsedSeconds => _elapsedSeconds;
  double get stressLevel => _stressLevel;
  bool get isActive => _state == EmergencyState.active;

  String get elapsedLabel {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  String get stressLabel {
    if (_stressLevel < 0.4) return 'BAJO';
    if (_stressLevel < 0.7) return 'MEDIO';
    return 'ALTO';
  }

  /// Activa el protocolo de emergencia. En producción: emitir evento al backend WebSocket.
  Future<void> activateEmergency() async {
    if (_state != EmergencyState.idle) return;
    _state = EmergencyState.activating;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _state = EmergencyState.active;
    _elapsedSeconds = 0;
    _stressLevel = 0.45;

    _cronTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsedSeconds++;
      notifyListeners();
    });

    // Simula fluctuación del nivel de estrés (IA de análisis de voz)
    _stressTimer = Timer.periodic(const Duration(milliseconds: 1800), (_) {
      final jitter = (DateTime.now().millisecond % 10 - 5) * 0.015;
      _stressLevel = (_stressLevel + jitter).clamp(0.30, 0.96);
      notifyListeners();
    });

    notifyListeners();
  }

  /// Cancela la emergencia activa. En producción: notificar al backend.
  Future<void> cancelEmergency() async {
    if (_state != EmergencyState.active) return;
    _state = EmergencyState.cancelling;
    notifyListeners();

    _cronTimer?.cancel();
    _stressTimer?.cancel();

    await Future.delayed(const Duration(seconds: 1));

    _state = EmergencyState.idle;
    _elapsedSeconds = 0;
    _stressLevel = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _cronTimer?.cancel();
    _stressTimer?.cancel();
    super.dispose();
  }
}
