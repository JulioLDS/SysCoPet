import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {

    final url =
        Uri.parse('${ApiConfig.baseUrl}/auth/register');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      return null;
    }

    final data = jsonDecode(response.body);

    return data['error'];
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {

/* Salvar token após login

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
    'token',
    data['token'],
    );
*/
    final url =
        Uri.parse('${ApiConfig.baseUrl}/auth/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    return UserModel(
      name: data['user']['name'],
      email: data['user']['email'],
    );
  }

  
}