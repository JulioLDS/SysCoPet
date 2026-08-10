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

  //Buscar lembrete por ID
  Future<ReminderModel?> buscarLembretePorId(int idPet, int idLembrete,) async {
    print('Buscando lembrete completo');
    print('ID PET: $idPet');
    print('ID LEMBRETE: $idLembrete');

    final lembretes = await buscarLembretesDoPet(idPet);

    print('Quantidade encontrada para o pet: ${lembretes.length}',);

    for (final lembrete in lembretes) {
      print(
        'Lembrete encontrado -> '
        'id: ${lembrete.idLembrete}, '
        'titulo: ${lembrete.titulo}',
      );
    }

    try {
      return lembretes.firstWhere(
        (lembrete) => lembrete.idLembrete == idLembrete,
      );
    } catch (_) {
      print(
        'Não encontrei o lembrete $idLembrete '
        'entre os lembretes do pet $idPet',
      );
      return null;
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

  //Atualizar lembrete
  Future<String?> atualizarLembrete( ReminderModel lembrete,) async {
    final response = await http.put(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/lembretes/${lembrete.idLembrete}',
      ),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        lembrete.toJson(),
      ),
    );

    final data = jsonDecode(
      response.body,
    );

    if (response.statusCode != 200) {
      if (data['erros'] != null) {
        return (data['erros'] as List)
            .join('\n');
      }

      return data['erro'] ??
          data['error'] ??
          'Erro ao atualizar lembrete';
    }

    return null;
  }

  //Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets/lembretes/$idLembrete',);

    print('DELETE lembrete: $url');
    print('ID enviado para exclusão: $idLembrete');

    final response = await http.delete(url);

    print('Status DELETE: ${response.statusCode}');
    print('Body DELETE: ${response.body}');

    Map<String, dynamic>? data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      return 'Resposta inválida da API';
    }

    if (response.statusCode != 200) {
      return data?['erro'] ??
          data?['error'] ??
          'Erro ao excluir lembrete';
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