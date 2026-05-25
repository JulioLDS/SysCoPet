import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;

  bool isLoading = false;

  Future<String?> register({
    required String nome,
    required String email,
    required String senha,
  }) async {

    print("1 - Entrou no provider");

    isLoading = true;
    notifyListeners();

    print("2 - Chamando authService");

    final result = await _authService.register(
      nome: nome,
      email: email,
      senha: senha,
    );

    print("3 - Voltou do authService");
    
    isLoading = false;
    notifyListeners();

    return result;
  }

  Future<bool> login({
    required String email,
    required String senha,
  }) async {

    isLoading = true;
    notifyListeners();

    final user = await _authService.login(
      email: email,
      senha: senha,
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