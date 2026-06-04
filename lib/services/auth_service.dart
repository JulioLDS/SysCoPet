import 'dart:convert';

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
        nome: data['user']['nome'],
        email: data['user']['email'],
      ),
    };
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
