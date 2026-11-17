import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({UserService? userService})
    : _userService = userService ?? UserService();

  final AuthService _authService = AuthService();
  final UserService _userService;
  bool _disposed = false;
  bool isUpdatingPhoto = false;

  UserModel? currentUser;

  bool isLoading = false;
  bool isInitialized = false;

  Future<String?> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      nome: nome,
      email: email,
      senha: senha,
    );

    isLoading = false;
    notifyListeners();

    return result;
  }

  //salvar sessao
  Future<void> _saveUserSession() async {
    final user = currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();

    if (!identical(currentUser, user)) return;
    await prefs.setString('user_session', jsonEncode(user.toJson()));
  }

  //carregar sessão
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    final session = prefs.getString('user_session');

    if (session != null) {
      final data = jsonDecode(session);

      currentUser = UserModel.fromJson(data);
    }

    isInitialized = true;

    notifyListeners();
  }

  //login
  Future<String?> login({required String email, required String senha}) async {
    isLoading = true;
    notifyListeners();

    final user = await _authService.login(email: email, senha: senha);

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

  //login com google
  Future<void> inicializarGoogle() {
    return _authService.inicializarGoogle();
  }

  Future<String?> loginComGoogleIdToken(String idToken) async {
    try {
      isLoading = true;
      notifyListeners();

      final resposta = await _authService.loginGoogleNoBackend(idToken);

      if (resposta['sucesso'] != true) {
        return resposta['erro'] ?? 'Erro ao fazer login com Google';
      }

      final usuarioJson = resposta['usuario'];

      if (usuarioJson == null) {
        return 'Erro: usuário não retornado pela API';
      }

      currentUser = UserModel.fromJson(usuarioJson);

      await _saveUserSession();

      return null;
    } catch (e) {
      return 'Erro ao fazer login com Google: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Login com google mobile
  Future<String?> loginComGoogleMobile() async {
    try {
      isLoading = true;
      notifyListeners();

      final resposta = await _authService.loginComGoogleMobile();

      if (resposta['sucesso'] != true) {
        return resposta['erro'] ?? 'Erro ao fazer login com Google';
      }

      final usuarioJson = resposta['usuario'];

      if (usuarioJson == null) {
        return 'Erro: usuário não retornado pela API';
      }

      currentUser = UserModel.fromJson(usuarioJson);

      await _saveUserSession();

      return null;
    } catch (e) {
      return 'Erro ao fazer login com Google: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // null representa a remoção confirmada pelo backend.
  Future<void> atualizarFotoPerfil(String? urlFoto) async {
    if (currentUser == null || _disposed) return;

    currentUser = currentUser!.copyWith(
      urlFoto: urlFoto,
      removerFoto: urlFoto == null,
    );
    try {
      await _saveUserSession();
    } catch (_) {
      throw const UserPhotoException(
        'A foto foi alterada, mas não foi possível salvar a sessão neste dispositivo.',
      );
    } finally {
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> enviarFotoPerfil({
    required List<int> bytes,
    required String nomeArquivo,
    String? mimeType,
  }) => _alterarFoto((user) => _userService.uploadFotoUsuario(
    idUsuario: user.id,
    bytes: bytes,
    nomeArquivo: nomeArquivo,
    mimeType: mimeType,
  ));

  Future<void> removerFotoPerfil() => _alterarFoto((user) async {
    await _userService.removerFotoUsuario(user.id);
    return null;
  });

  Future<void> _alterarFoto(
    Future<String?> Function(UserModel user) operation,
  ) async {
    final user = currentUser;
    if (user == null || _disposed) {
      throw const UserPhotoException('Entre na sua conta para alterar a foto.');
    }
    if (isUpdatingPhoto) {
      throw const UserPhotoException('Aguarde a alteração da foto terminar.');
    }

    isUpdatingPhoto = true;

    notifyListeners();

    try {
      final url = await operation(user);
      // Não aplicar uma resposta antiga após logout ou troca de sessão.
      if (_disposed || !identical(currentUser, user)) {
        throw const UserPhotoException('Sua sessão mudou. Tente novamente.');
      }
      await atualizarFotoPerfil(url);
    } finally {
      isUpdatingPhoto = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _userService.dispose();
    super.dispose();
  }

  //Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_session');

    currentUser = null;

    notifyListeners();
  }
}
