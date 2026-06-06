import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? currentUser;

  bool isLoading = false;
  bool isInitialized = false;

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

  //salvar sessao
  Future<void> _saveUserSession() async {
    if (currentUser == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'user_session',
      jsonEncode({
        'nome': currentUser!.nome,
        'email': currentUser!.email,
      }),
    );
  }

  //carregar sessão
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final session = prefs.getString('user_session');

    if (session != null) { 

      final data = jsonDecode(session);

      currentUser = UserModel(
        id: data['id'],
        nome: data['nome'],
        email: data['email'],
      );
    }

    isInitialized = true;

    notifyListeners();
  }

  Future<String?> login({required String email, required String senha}) async {
    isLoading = true;
    notifyListeners();

    final user = await _authService.login(
      email: email, 
      senha: senha
    );

    isLoading = false;
    notifyListeners();

    if (user['sucesso'] != true) {
      return user['erro'];
    }

    currentUser = user['user'];

    await _saveUserSession();

    notifyListeners();

    return null;
  }

  //Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_session');

    currentUser = null;

    notifyListeners();
  }
}
