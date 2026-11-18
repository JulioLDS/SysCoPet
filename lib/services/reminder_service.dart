import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;

import '../config/api_config.dart';
import '../models/reminder_model.dart';
import '../models/reminder_ocurrence_model.dart';

class ReminderCompletionException implements Exception {
  const ReminderCompletionException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ReminderService {
  ReminderService({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  Future<ReminderModel> concluirLembrete(int idLembrete) async {
    if (idLembrete <= 0) {
      throw const ReminderCompletionException('ID do lembrete inválido.');
    }
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pets/lembretes/$idLembrete/concluir',
    );
    final tempo = Stopwatch()..start();
    _logConclusao('PATCH $url; plataforma=${kIsWeb ? 'web' : 'nativa'}');
    late http.Response response;
    try {
      response = await _client
          .patch(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 60));
    } on TimeoutException catch (error) {
      _logConclusao('Sem resposta após ${tempo.elapsedMilliseconds}ms: $error');
      throw const ReminderCompletionException(
        'O servidor demorou para responder. Verifique o estado do lembrete antes de tentar novamente.',
      );
    } on http.ClientException catch (error) {
      _logConclusao(
        'Falha de transporte após ${tempo.elapsedMilliseconds}ms; '
        '${error.runtimeType}: ${error.message}',
      );
      if (kIsWeb) {
        _logConclusao(
          'No Chrome, confira Console e Network: a resposta ao OPTIONS '
          'deve permitir PATCH em Access-Control-Allow-Methods. '
          'CORS, rede e TLS podem impedir o acesso à resposta HTTP.',
        );
      }
      throw ReminderCompletionException(
        kIsWeb
            ? 'O navegador não conseguiu acessar a API. Verifique a conexão e a liberação de PATCH no CORS do servidor.'
            : 'Não foi possível conectar ao servidor. Verifique a conexão e tente novamente.',
      );
    }
    _logConclusao(
      'HTTP ${response.statusCode}; ${tempo.elapsedMilliseconds}ms; '
      'content-type=${response.headers['content-type'] ?? 'não informado'}',
    );
    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) data = decoded;
    } on FormatException {
      // Mostrar um erro utilizável mesmo quando o servidor responde HTML.
    }
    if (response.statusCode != 200) {
      final error = data?['erro'];
      throw ReminderCompletionException(
        error is String && error.isNotEmpty
            ? error
            : 'Não foi possível concluir o lembrete (HTTP ${response.statusCode}).',
      );
    }
    final json = data?['lembrete'];
    if (json is! Map<String, dynamic>) {
      throw const ReminderCompletionException(
        'A API não confirmou a conclusão do lembrete.',
      );
    }
    try {
      final updated = ReminderModel.fromJson(json);
      if (updated.idLembrete != idLembrete ||
          !updated.concluido ||
          updated.recorrencia != 'unica') {
        throw const FormatException();
      }
      return updated;
    } on FormatException {
      throw const ReminderCompletionException(
        'A API retornou uma conclusão incompatível com o lembrete.',
      );
    } on TypeError {
      throw const ReminderCompletionException(
        'A API retornou dados inválidos do lembrete.',
      );
    }
  }

  static void _logConclusao(String mensagem) {
    if (kDebugMode) debugPrint('[Lembrete/concluir] $mensagem');
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }

  //Buscar lembretes
  Future<List<ReminderModel>> buscarLembretesDoPet(int idPet) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/pets/lembretes/$idPet'),
      );

      if (response.statusCode != 200) {
        throw Exception('Erro ao buscar lembretes');
      }

      final List data = jsonDecode(response.body);

      return data.map((json) => ReminderModel.fromJson(json)).toList();
    } catch (e) {
      print('Erro: $e');
      throw Exception('Erro ao buscar lembretes');
    }
  }

  //Buscar lembrete por ID
  Future<ReminderModel?> buscarLembretePorId(int idPet, int idLembrete) async {
    print('Buscando lembrete completo');
    print('ID PET: $idPet');
    print('ID LEMBRETE: $idLembrete');

    final lembretes = await buscarLembretesDoPet(idPet);

    print('Quantidade encontrada para o pet: ${lembretes.length}');

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
    final url = Uri.parse('${ApiConfig.baseUrl}/pets/lembretes');

    final bodyJson = jsonEncode(lembrete.toJson()..remove('concluido'));

    print('POST lembrete: $url');
    print('Body enviado: $bodyJson');

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
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
  Future<String?> atualizarLembrete(ReminderModel lembrete) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/pets/lembretes/${lembrete.idLembrete}',
    );

    final bodyJson = jsonEncode({
      'id_pet': lembrete.idPet,
      'titulo': lembrete.titulo,
      'descricao': lembrete.descricao,
      'data_hora': lembrete.dataHora.toUtc().toIso8601String(),
      'tipo': lembrete.tipo,
      'recorrencia': lembrete.recorrencia,
    });

    print('PUT lembrete: $url');
    print('Body enviado: $bodyJson');

    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    print('Status UPDATE: ${response.statusCode}');
    print('Body UPDATE: ${response.body}');

    Map<String, dynamic>? data;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {
      return 'A API retornou uma resposta inválida.';
    }

    if (response.statusCode != 200) {
      if (data?['erros'] != null) {
        return (data!['erros'] as List).join('\n');
      }

      return data?['erro'] ?? data?['error'] ?? 'Erro ao atualizar lembrete';
    }

    return null;
  }

  //Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/pets/lembretes/$idLembrete');

    print('DELETE lembrete: $url');
    print('ID enviado para exclusão: $idLembrete');

    final response = await _client.delete(url);

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
      return data?['erro'] ?? data?['error'] ?? 'Erro ao excluir lembrete';
    }

    return null;
  }

  //Buscar ocorrência
  Future<List<ReminderOccurrenceModel>> buscarOcorrencias(int idPet) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/lembretes/ocorrencias/$idPet?quantidade=5',
      ),
    );

    final List data = jsonDecode(response.body);

    return data.map((e) => ReminderOccurrenceModel.fromJson(e)).toList();
  }
}
