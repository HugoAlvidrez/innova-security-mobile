import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class EvidenceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<EventModel> _events = List.from(MockData.events);
  final List<EvidenceModel> _evidences = List.from(MockData.evidences);
  bool _isLoading = false;

  List<EventModel> get events => _events;
  List<EvidenceModel> get evidences => _evidences;
  bool get isLoading => _isLoading;

  List<EvidenceModel> getEvidenceForEvent(String eventId) =>
      _evidences.where((e) => e.eventId == eventId).toList();

  EvidenceModel? getEvidenceById(String id) {
    try {
      return _evidences.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  EventModel? getEventById(String id) {
    try {
      return _events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  EventModel? getEventForEvidence(String evidenceId) {
    final evidence = getEvidenceById(evidenceId);
    if (evidence == null) return null;
    return getEventById(evidence.eventId);
  }

  /// En producción: fetch /api/events desde backend.
  Future<void> refreshEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      final backendEvents = await _apiService.getEvents();
      if (backendEvents != null && backendEvents.isNotEmpty) {
        _events = backendEvents.map(_mapEvent).toList();
      } else {
        _events = List.from(MockData.events);
      }
    } catch (e) {
      if (kDebugMode) {
        print('EvidenceProvider.refreshEvents error: $e');
      }
      _events = List.from(MockData.events);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  EventModel _mapEvent(Map<String, dynamic> data) {
    final locationData = data['location'];
    String? location;
    double? latitude;
    double? longitude;

    if (locationData is String) {
      location = locationData;
    } else if (locationData is Map<String, dynamic>) {
      location = locationData['address']?.toString();
      latitude = (locationData['latitude'] is num)
          ? (locationData['latitude'] as num).toDouble()
          : null;
      longitude = (locationData['longitude'] is num)
          ? (locationData['longitude'] as num).toDouble()
          : null;
    }

    final createdAt = DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now();
    final resolvedAt = DateTime.tryParse(data['resolvedAt']?.toString() ?? '');
    final durationSeconds = resolvedAt != null
        ? resolvedAt.difference(createdAt).inSeconds
        : 0;

    return EventModel(
      id: data['id']?.toString() ?? 'evt_unknown',
      userId: data['userId']?.toString() ?? '',
      timestamp: createdAt,
      status: _mapStatus(data['status']?.toString()),
      type: _mapType(data['eventType']?.toString()),
      location: location,
      latitude: latitude,
      longitude: longitude,
      stressLevel: (data['stressLevel'] is num)
          ? (data['stressLevel'] as num).toDouble()
          : 0.0,
      evidenceIds: const [],
      notes: data['description']?.toString(),
      durationSeconds: durationSeconds > 0 ? durationSeconds : 0,
    );
  }

  EventStatus _mapStatus(String? status) {
    switch (status) {
      case 'active':
        return EventStatus.active;
      case 'resolved':
        return EventStatus.resolved;
      case 'pending':
      default:
        return EventStatus.pending;
    }
  }

  EventType _mapType(String? eventType) {
    switch (eventType) {
      case 'emergency':
        return EventType.emergency;
      case 'test':
        return EventType.test;
      case 'scheduled':
        return EventType.scheduled;
      default:
        return EventType.emergency;
    }
  }
}
