import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/reminder_model.dart';

class ReminderService {

  //Buscar lembretes
  Future<List<ReminderModel>> buscarLembretesDoPet(int idPet) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/lembretes/pet/$idPet'),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar lembretes');
    }

    final List data = jsonDecode(response.body);

    return data
        .map((json) => ReminderModel.fromJson(json))
        .toList();
  }

  //Criar lembrete
  Future<String?> criarLembrete(ReminderModel lembrete) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/lembretes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(lembrete.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 201) {
      if (data['erros'] != null) {
        return (data['erros'] as List).join('\n');
      }

      return data['erro'] ?? data['error'] ?? 'Erro ao criar lembrete';
    }

    return null;
  }

  //Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/lembretes/$idLembrete'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['erro'] ?? data['error'] ?? 'Erro ao excluir lembrete';
    }

    return null;
  }
}