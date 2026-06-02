import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
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
      'success': true,
      'user': UserModel(
        nome: data['user']['nome'],
        email: data['user']['email'],
      ),
    };
  }
}
