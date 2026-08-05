import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/reminder_model.dart';
import '../models/reminder_ocurrence_model.dart';

class ReminderService {

  //Buscar lembretes
  Future<List<ReminderModel>> buscarLembretesDoPet(int idPet) async {
    try{
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/pets/lembretes/$idPet'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar lembretes');
      }

      final List data = jsonDecode(response.body);

      return data
          .map((json) => ReminderModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro: $e');
      throw Exception('Erro ao buscar lembretes');
    }
  }

  //Criar lembrete
  Future<String?> criarLembrete(ReminderModel lembrete) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pets/lembretes',
    );

    final bodyJson = jsonEncode(
      lembrete.toJson(),
    );

    print('POST lembrete: $url');
    print('Body enviado: $bodyJson');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: bodyJson,
    );

    print('Status criar lembrete: ${response.statusCode}');
    print('Body criar lembrete: ${response.body}');

    Map<String, dynamic>? data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      return 'A API retornou uma resposta inválida ao criar lembrete.';
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      if (data?['erros'] != null) {
        return (data!['erros'] as List).join('\n');
      }

      return data?['erro'] ??
          data?['error'] ??
          data?['message'] ??
          'Erro ao criar lembrete';
    }

    return null;
  }

  //Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/pets/lembretes/$idLembrete'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['erro'] ?? data['error'] ?? 'Erro ao excluir lembrete';
    }

    return null;
  }

  //Buscar ocorrência
  Future<List<ReminderOccurrenceModel>> buscarOcorrencias(int idPet,) async {

    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/lembretes/ocorrencias/$idPet?quantidade=5',
      ),
    );

    final List data = jsonDecode(response.body);

    return data
        .map(
          (e) => ReminderOccurrenceModel.fromJson(e),
        )
        .toList();
  }

}