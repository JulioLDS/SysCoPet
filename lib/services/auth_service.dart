import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  //Registro
  Future<String?> register({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );

    if (response.statusCode == 201) {
      return null;
    }

    final data = jsonDecode(response.body);

    return data['error'];
  }
  
  //Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/usuarios/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': senha}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        'sucesso': false, 
        'erro': data['erro'] ?? 'Erro desconhecido',
        };
    }

    return {
      'sucesso': true,
      'user': UserModel(
        id: int.parse(data['user']['id'].toString()),
        nome: data['user']['nome'],
        email: data['user']['email'],
      ),
    };
  }

  //Login com google
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _googleInicializado = false;

  Future<void> _inicializarGoogle() async {
    if (_googleInicializado) return;

    await _googleSignIn.initialize(
      serverClientId: '357380729178-ro75lhale3r65l1kecmmtvujim4qietq.apps.googleusercontent.com',
    );

    _googleInicializado = true;
  }

  Future<Map<String, dynamic>> loginComGoogle() async {
    try {
      await _inicializarGoogle();

      if (!_googleSignIn.supportsAuthenticate()) {
        throw Exception(
          'Esta plataforma não suporta authenticate(). No Flutter Web, use o botão oficial do Google.',
        );
      }

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Falha ao obter ID Token do Google');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/login-google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'sucesso': true,
          'mensagem': data['mensagem'],
          'token': data['token'],
          'usuario': data['usuario'],
        };
      }

      return {
        'sucesso': false,
        'erro': data['erro'] ?? data['mensagem'] ?? 'Erro ao fazer login com Google',
      };
    } catch (e) {
      return {
        'sucesso': false,
        'erro': 'Erro no login com Google: $e',
      };
    }
  }

  //Esqueci a senha
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/usuarios/esqueceu-senha',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        'sucesso': false,
        'erro': data['erro'] ?? 'Erro ao enviar código',
      };
    }

    return {
      'sucesso': true,
      'mensagem': data['mensagem'],
    };
}

//Resetar senha
Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/usuarios/reset-senha',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'codigo': codigo,
        'novaSenha': novaSenha,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return {
        'sucesso': false,
        'erro': data['erro'] ?? 'Erro ao redefinir senha',
      };
    }

    return {
      'sucesso': true,
      'mensagem': data['mensagem'],
    };
}


}
