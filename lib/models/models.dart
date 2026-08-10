// ─── Models ──────────────────────────────────────────────────────────────────

class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final bool isActive;
  final String? wearableId;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.isActive,
    this.wearableId,
    required this.createdAt,
  });

  String get fullName => '$name $lastName';
  String get initials =>
      '${name.isNotEmpty ? name[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}

// ─── Event ───────────────────────────────────────────────────────────────────

enum EventStatus { active, resolved, pending }

enum EventType { emergency, test, scheduled }

class EventModel {
  final String id;
  final String userId;
  final DateTime timestamp;
  final EventStatus status;
  final EventType type;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double stressLevel; // 0.0–1.0
  final List<String> evidenceIds;
  final String? notes;
  final int durationSeconds;

  const EventModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.status,
    required this.type,
    this.location,
    this.latitude,
    this.longitude,
    required this.stressLevel,
    required this.evidenceIds,
    this.notes,
    required this.durationSeconds,
  });

  String get statusLabel {
    switch (status) {
      case EventStatus.active:
        return 'Activo';
      case EventStatus.resolved:
        return 'Resuelto';
      case EventStatus.pending:
        return 'Pendiente';
    }
  }

  String get typeLabel {
    switch (type) {
      case EventType.emergency:
        return 'Emergencia';
      case EventType.test:
        return 'Prueba';
      case EventType.scheduled:
        return 'Programado';
    }
  }

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Evidence ────────────────────────────────────────────────────────────────

enum EvidenceType { video, audio }

class EvidenceModel {
  final String id;
  final String eventId;
  final EvidenceType type;
  final DateTime timestamp;
  final int durationSeconds;
  final String streamUrl;
  final bool isLive;
  final String? transcription;
  final double? stressLevel;

  const EvidenceModel({
    required this.id,
    required this.eventId,
    required this.type,
    required this.timestamp,
    required this.durationSeconds,
    required this.streamUrl,
    required this.isLive,
    this.transcription,
    this.stressLevel,
  });

  String get durationLabel {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Chat ────────────────────────────────────────────────────────────────────

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isFromAgent;
  bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isFromAgent,
    required this.isRead,
  });
}

// ─── Notes ───────────────────────────────────────────────────────────────────

class NoteModel {
  final String id;
  String title;
  String content;
  final DateTime createdAt;
  DateTime updatedAt;
  final String colorHex;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.colorHex,
  });
}

// ─── Appointments ─────────────────────────────────────────────────────────────

class AppointmentModel {
  final String id;
  final String title;
  final String description;
  final DateTime dateTime;
  final String agentName;
  final bool isConfirmed;
  final bool isReminder;

  const AppointmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.agentName,
    required this.isConfirmed,
    required this.isReminder,
  });
}

// ─── Wearable ────────────────────────────────────────────────────────────────

enum WearableStatus { connected, disconnected, pairing, lowBattery }

class WearableModel {
  final String id;
  final String name;
  final String modelName;
  WearableStatus status;
  final int batteryLevel;
  final DateTime? lastSync;
  final String firmwareVersion;

  WearableModel({
    required this.id,
    required this.name,
    required this.modelName,
    required this.status,
    required this.batteryLevel,
    this.lastSync,
    required this.firmwareVersion,
  });

  String get statusLabel {
    switch (status) {
      case WearableStatus.connected:
        return 'Conectado';
      case WearableStatus.disconnected:
        return 'Desconectado';
      case WearableStatus.pairing:
        return 'Emparejando…';
      case WearableStatus.lowBattery:
        return 'Batería baja';
    }
  }
}
