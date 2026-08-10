import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<MessageModel> _messages = List.from(MockData.messages);
  bool _isLoading = false;
  bool _isSending = false;
  String? _selectedEventId;
  String? _error;
  Timer? _pollTimer;

  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get selectedEventId => _selectedEventId;
  String? get error => _error;
  int get unreadCount =>
      _messages.where((m) => m.isFromAgent && !m.isRead).length;

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _pollNewMessages();
    });
  }

  Future<void> _pollNewMessages() async {
    if (_selectedEventId == null || _isSending) return;
    try {
      final response = await _apiService.getChatMessages(_selectedEventId!);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          final serverMsgs = data.map((item) => _mapMessage(item)).toList();
          if (serverMsgs.length != _messages.length) {
            _messages
              ..clear()
              ..addAll(serverMsgs);
            notifyListeners();
          }
        }
      }
    } catch (_) {}
  }

  Future<void> loadMessages(String eventId) async {
    if (eventId.isEmpty) return;

    _selectedEventId = eventId;
    _startPolling();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getChatMessages(eventId);
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is List) {
          _messages
            ..clear()
            ..addAll(data.map((item) => _mapMessage(item)));
        }
      } else {
        _error = response?['message']?.toString() ??
            'No se pudieron cargar los mensajes del chat.';
      }
    } catch (e) {
      _error = 'Error al obtener el chat: $e';
      if (kDebugMode) {
        print('ChatProvider.loadMessages error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _selectedEventId == null) return;

    _isSending = true;
    _error = null;
    notifyListeners();

    final localMessage = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'usr_001',
      senderName: 'María González',
      content: content.trim(),
      timestamp: DateTime.now(),
      isFromAgent: false,
      isRead: true,
    );
    _messages.add(localMessage);
    notifyListeners();

    try {
      final response = await _apiService.sendChatMessage(
        _selectedEventId!,
        content.trim(),
      );

      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data is Map<String, dynamic>) {
          final serverMessage = _mapMessage(data);
          final index = _messages.indexWhere((m) => m.id == localMessage.id);
          if (index != -1) {
            _messages[index] = serverMessage;
          } else {
            _messages.add(serverMessage);
          }
        }
      } else {
        _error = response?['message']?.toString() ??
            'No se pudo enviar el mensaje al servidor.';
      }
    } catch (e) {
      _error = 'Error al enviar mensaje: $e';
      if (kDebugMode) {
        print('ChatProvider.sendMessage error: $e');
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (final m in _messages) {
      m.isRead = true;
    }
    notifyListeners();
  }

  MessageModel _mapMessage(dynamic item) {
    final map = item is Map<String, dynamic> ? item : <String, dynamic>{};
    final senderRole = map['senderRole']?.toString() ?? '';
    final isFromAgent = senderRole == 'operador' || senderRole == 'super_admin';
    final senderName = map['senderName']?.toString() ??
        (isFromAgent ? 'Operador' : 'Usuario');

    DateTime timestamp = DateTime.now();
    final createdAt = map['createdAt']?.toString();
    if (createdAt != null) {
      try {
        timestamp = DateTime.parse(createdAt);
      } catch (_) {}
    }

    return MessageModel(
      id: map['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: map['senderId']?.toString() ?? '',
      senderName: senderName,
      content: map['message']?.toString() ?? '',
      timestamp: timestamp,
      isFromAgent: isFromAgent,
      isRead: map['isRead'] == true,
    );
  }
}
