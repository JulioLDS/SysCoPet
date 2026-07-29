import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  static const String googleClientId ='357380729178-ro75lhale3r65l1kecmmtvujim4qietq.apps.googleusercontent.com';

  static Future<void>? _googleInitFuture;

  Future<void> inicializarGoogle() {
    _googleInitFuture ??= _inicializarGoogleInterno();
    return _googleInitFuture!;
  }

  Future<void> _inicializarGoogleInterno() async {
    if (kIsWeb) {
      await _googleSignIn.initialize(
        clientId: googleClientId,
      );
    } else {
      await _googleSignIn.initialize(
        serverClientId: googleClientId,
      );
    }
  }

  Future<Map<String, dynamic>> loginGoogleNoBackend(String idToken) async {
    try {
      print('ENVIANDO ID TOKEN PARA O BACKEND...');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/usuarios/login-google'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      print('STATUS BACKEND GOOGLE: ${response.statusCode}');
      print('RESPOSTA BACKEND GOOGLE: ${response.body}');

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
        'erro': data['erro'] ??
            data['mensagem'] ??
            'Erro ao fazer login com Google',
      };
    } catch (e) {
      print('ERRO AO COMUNICAR COM BACKEND GOOGLE: $e');

      return {
        'sucesso': false,
        'erro': 'Erro ao comunicar com a API: $e',
      };
    }
  }

  //Login Google mobile
  Future<Map<String, dynamic>> loginComGoogleMobile() async {
    try {
      await inicializarGoogle();

      if (!_googleSignIn.supportsAuthenticate()) {
        return {
          'sucesso': false,
          'erro': 'Esta plataforma não suporta authenticate().',
        };
      }

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return {
          'sucesso': false,
          'erro': 'Falha ao obter ID Token do Google',
        };
      }

      return await loginGoogleNoBackend(idToken);
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
