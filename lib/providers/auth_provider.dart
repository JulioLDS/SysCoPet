import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;

  bool isLoading = false;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {

    isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {

    isLoading = true;
    notifyListeners();

    final user = await _authService.login(
      email: email,
      password: password,
    );

    isLoading = false;
    notifyListeners();

    if (user == null) {
      return false;
    }

    currentUser = user;

    notifyListeners();

    return true;
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }
}