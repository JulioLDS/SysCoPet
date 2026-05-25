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

print("4 - Entrou no service");

    final url =
        Uri.parse('${ApiConfig.baseUrl}/usuarios');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
      }),
    );

    print("5 - Recebeu resposta");
    print(response.statusCode);
  print(response.body);
  
    if (response.statusCode == 201) {
      return null;
    }

    final data = jsonDecode(response.body);

    return data['error'];
  }

  Future<UserModel?> login({
    required String email,
    required String senha,
  }) async {

/* Salvar token após login

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
    'token',
    data['token'],
    );
*/
    final url =
        Uri.parse('${ApiConfig.baseUrl}/usuarios/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'senha': senha,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    return UserModel(
      nome: data['user']['nome'],
      email: data['user']['email'],
    );
  }

  
}