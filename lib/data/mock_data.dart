import '../models/models.dart';

class MockData {
  // ─── Current User ──────────────────────────────────────────────────────────
  static final UserModel currentUser = UserModel(
    id: 'usr_001',
    name: 'María',
    lastName: 'González Pérez',
    email: 'maria.gonzalez@innova.mx',
    phone: '+52 55 1234 5678',
    address: 'Av. Insurgentes Sur 1234, CDMX',
    isActive: true,
    wearableId: 'wear_001',
    createdAt: DateTime(2025, 1, 15),
  );

  // ─── Wearable ──────────────────────────────────────────────────────────────
  static final WearableModel wearable = WearableModel(
    id: 'wear_001',
    name: 'InnovaWatch Pro',
    modelName: 'IW-2025',
    status: WearableStatus.connected,
    batteryLevel: 78,
    lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
    firmwareVersion: 'v2.4.1',
  );

  // ─── Events ────────────────────────────────────────────────────────────────
  static final List<EventModel> events = [
    EventModel(
      id: 'evt_001',
      userId: 'usr_001',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: EventStatus.resolved,
      type: EventType.emergency,
      location: 'Av. Insurgentes Sur 1523, CDMX',
      latitude: 19.3910,
      longitude: -99.1738,
      stressLevel: 0.82,
      evidenceIds: ['ev_001', 'ev_002'],
      notes: 'Situación resuelta por patrulla 247. Tiempo de respuesta: 4 min.',
      durationSeconds: 423,
    ),
    EventModel(
      id: 'evt_002',
      userId: 'usr_001',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      status: EventStatus.resolved,
      type: EventType.emergency,
      location: 'Centro Comercial Perisur, CDMX',
      latitude: 19.2972,
      longitude: -99.1889,
      stressLevel: 0.61,
      evidenceIds: ['ev_003'],
      notes: 'Falsa alarma confirmada por el usuario.',
      durationSeconds: 178,
    ),
    EventModel(
      id: 'evt_003',
      userId: 'usr_001',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: EventStatus.resolved,
      type: EventType.test,
      location: 'Domicilio registrado',
      latitude: 19.3830,
      longitude: -99.1700,
      stressLevel: 0.15,
      evidenceIds: ['ev_004', 'ev_005'],
      notes: 'Prueba del sistema. Todo operando correctamente.',
      durationSeconds: 62,
    ),
    EventModel(
      id: 'evt_004',
      userId: 'usr_001',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      status: EventStatus.resolved,
      type: EventType.emergency,
      location: 'Metro Copilco, CDMX',
      latitude: 19.3327,
      longitude: -99.1698,
      stressLevel: 0.74,
      evidenceIds: ['ev_006'],
      notes: 'Respuesta del centro de monitoreo en 4 minutos.',
      durationSeconds: 312,
    ),
    EventModel(
      id: 'evt_005',
      userId: 'usr_001',
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      status: EventStatus.resolved,
      type: EventType.emergency,
      location: 'Parque Lincoln, Miguel Hidalgo, CDMX',
      latitude: 19.4284,
      longitude: -99.1955,
      stressLevel: 0.55,
      evidenceIds: ['ev_007', 'ev_008'],
      notes: null,
      durationSeconds: 245,
    ),
  ];

  // ─── Evidence ──────────────────────────────────────────────────────────────
  static final List<EvidenceModel> evidences = [
    EvidenceModel(
      id: 'ev_001',
      eventId: 'evt_001',
      type: EvidenceType.video,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      durationSeconds: 423,
      streamUrl: 'mock://stream/ev_001',
      isLive: false,
      stressLevel: 0.82,
      transcription:
          'Activación de protocolo de emergencia. Nivel de estrés detectado: ALTO (82%). Ubicación transmitida al centro de monitoreo.',
    ),
    EvidenceModel(
      id: 'ev_002',
      eventId: 'evt_001',
      type: EvidenceType.audio,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      durationSeconds: 423,
      streamUrl: 'mock://stream/ev_002',
      isLive: false,
      stressLevel: 0.78,
      transcription:
          'Análisis de voz: estrés elevado detectado. Protocolo de emergencia confirmado automáticamente.',
    ),
    EvidenceModel(
      id: 'ev_003',
      eventId: 'evt_002',
      type: EvidenceType.video,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      durationSeconds: 178,
      streamUrl: 'mock://stream/ev_003',
      isLive: false,
      stressLevel: 0.61,
    ),
    EvidenceModel(
      id: 'ev_004',
      eventId: 'evt_003',
      type: EvidenceType.video,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      durationSeconds: 62,
      streamUrl: 'mock://stream/ev_004',
      isLive: false,
      stressLevel: 0.15,
    ),
    EvidenceModel(
      id: 'ev_005',
      eventId: 'evt_003',
      type: EvidenceType.audio,
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      durationSeconds: 62,
      streamUrl: 'mock://stream/ev_005',
      isLive: false,
      stressLevel: 0.12,
      transcription: 'Prueba del sistema. Nivel de estrés: BAJO.',
    ),
    EvidenceModel(
      id: 'ev_006',
      eventId: 'evt_004',
      type: EvidenceType.video,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      durationSeconds: 312,
      streamUrl: 'mock://stream/ev_006',
      isLive: false,
      stressLevel: 0.74,
      transcription:
          'Nivel de estrés: ALTO (74%). Contacto con centro de control establecido a los 38 segundos.',
    ),
    EvidenceModel(
      id: 'ev_007',
      eventId: 'evt_005',
      type: EvidenceType.video,
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      durationSeconds: 245,
      streamUrl: 'mock://stream/ev_007',
      isLive: false,
      stressLevel: 0.55,
    ),
    EvidenceModel(
      id: 'ev_008',
      eventId: 'evt_005',
      type: EvidenceType.audio,
      timestamp: DateTime.now().subtract(const Duration(days: 14)),
      durationSeconds: 245,
      streamUrl: 'mock://stream/ev_008',
      isLive: false,
      stressLevel: 0.50,
    ),
  ];

  // ─── Messages ──────────────────────────────────────────────────────────────
  static final List<MessageModel> messages = [
    MessageModel(
      id: 'msg_001',
      senderId: 'agent_001',
      senderName: 'Agente Carlos Ruiz',
      content:
          '¡Hola María! Le confirmo que hemos recibido y procesado su evento de emergencia de ayer. Todo está bajo control.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isFromAgent: true,
      isRead: true,
    ),
    MessageModel(
      id: 'msg_002',
      senderId: 'usr_001',
      senderName: 'María González',
      content: 'Gracias agente Ruiz. ¿Cuándo estará disponible el reporte completo del incidente?',
      timestamp:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 45)),
      isFromAgent: false,
      isRead: true,
    ),
    MessageModel(
      id: 'msg_003',
      senderId: 'agent_001',
      senderName: 'Agente Carlos Ruiz',
      content:
          'El reporte completo estará disponible en 24-48 horas hábiles. Le notificaremos por este medio cuando esté listo para su consulta.',
      timestamp:
          DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 30)),
      isFromAgent: true,
      isRead: true,
    ),
    MessageModel(
      id: 'msg_004',
      senderId: 'usr_001',
      senderName: 'María González',
      content: 'Entendido. Muchas gracias.',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isFromAgent: false,
      isRead: true,
    ),
    MessageModel(
      id: 'msg_005',
      senderId: 'agent_001',
      senderName: 'Agente Carlos Ruiz',
      content:
          'Buenos días María. Le informamos que su reporte de seguimiento ya está disponible para consulta en el panel. ¿Tiene alguna pregunta adicional?',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isFromAgent: true,
      isRead: false,
    ),
  ];

  // ─── Notes ─────────────────────────────────────────────────────────────────
  static List<NoteModel> get notes => [
        NoteModel(
          id: 'note_001',
          title: 'Zona de riesgo identificada',
          content:
              'Evitar la zona de Insurgentes Sur entre las 20:00 y 23:00 h. Señalado por el agente Carlos el martes.',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          colorHex: '#FFE8E8',
        ),
        NoteModel(
          id: 'note_002',
          title: 'Contactos de emergencia',
          content:
              'Policía CDMX: 55 5242-5100\nCentro de Control InnovaMovil: 800 468-8635\nFamiliar de confianza: 55 9876-5432',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
          colorHex: '#E3F2FD',
        ),
        NoteModel(
          id: 'note_003',
          title: 'Protocolo personal de seguridad',
          content:
              '1. Siempre llevar el wearable cargado (> 20%)\n2. Compartir ubicación con familiar al salir de noche\n3. Reportar cualquier situación sospechosa al agente\n4. Mantener actualizado el número de contacto',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          colorHex: '#E8F5E9',
        ),
      ];

  // ─── Appointments ──────────────────────────────────────────────────────────
  static final List<AppointmentModel> appointments = [
    AppointmentModel(
      id: 'apt_001',
      title: 'Seguimiento incidente #evt_001',
      description:
          'Revisión del incidente del martes en Insurgentes. Traer identificación oficial.',
      dateTime: DateTime.now().add(const Duration(days: 2, hours: 10)),
      agentName: 'Agente Carlos Ruiz',
      isConfirmed: true,
      isReminder: false,
    ),
    AppointmentModel(
      id: 'apt_002',
      title: 'Actualización de firmware',
      description:
          'Llevar wearable para actualización de firmware a las oficinas InnovaMovil.',
      dateTime: DateTime.now().add(const Duration(days: 5, hours: 14)),
      agentName: 'Soporte Técnico',
      isConfirmed: false,
      isReminder: false,
    ),
    AppointmentModel(
      id: 'apt_003',
      title: 'Renovación de servicio anual',
      description: 'Vencimiento del contrato anual. Renovar antes del 30 de mayo.',
      dateTime: DateTime.now().add(const Duration(days: 44)),
      agentName: 'Ejecutivo de Cuenta',
      isConfirmed: false,
      isReminder: true,
    ),
  ];
}
