import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Autenticación híbrida: conecta al backend API y usa fallback si está offline.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // 1. Intentar llamar a la API Backend
    final apiData = await ApiService().login(email, password);
    if (apiData != null) {
      final userData = apiData['user'] is Map<String, dynamic>
          ? apiData['user'] as Map<String, dynamic>
          : apiData;
      final fullName = userData['fullName']?.toString() ??
          userData['full_name']?.toString() ??
          email.split('@')[0];
      final nameParts = fullName.split(' ');
      _isAuthenticated = true;
      _currentUser = UserModel(
        id: userData['id']?.toString() ?? 'u1',
        name: nameParts.isNotEmpty ? nameParts[0] : fullName,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
        email: userData['email']?.toString() ?? email,
        phone: userData['phoneNumber']?.toString() ??
            userData['phone_number']?.toString() ??
            '+52 555 123 4567',
        address: 'Ciudad de México, MX',
        isActive: true,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return true;
    }

    // 2. Fallback a datos locales de prueba
    await Future.delayed(const Duration(milliseconds: 600));

    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _currentUser = MockData.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    ApiService().clearAuthToken();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}
