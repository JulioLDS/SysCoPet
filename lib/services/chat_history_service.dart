import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chat_message_model.dart';

class ChatHistoryException implements Exception {
  const ChatHistoryException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Histórico visual na Node. Não envia mensagens anteriores para a IA.
class ChatHistoryService {
  ChatHistoryService({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       baseUrl =
           '${(baseUrl ?? ApiConfig.baseUrl).replaceFirst(RegExp(r'/+$'), '')}/chat';

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;
  final Duration timeout;

  Future<List<ChatMessageModel>> buscarHistorico(int idUsuario) async {
    final response = await _request('GET', '/historico/$idUsuario');
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic> || decoded['mensagens'] is! List) {
        throw const FormatException();
      }
      return (decoded['mensagens'] as List).map((item) {
        if (item is! Map<String, dynamic> ||
            (item['role'] != 'user' && item['role'] != 'assistant') ||
            item['conteudo'] is! String ||
            (item['id_usuario'] != null &&
                item['id_usuario'].toString() != '$idUsuario')) {
          throw const FormatException();
        }
        return ChatMessageModel(
          texto: item['conteudo'] as String,
          usuario: item['role'] == 'user',
        );
      }).toList();
    } on FormatException {
      throw const ChatHistoryException('Formato inválido do histórico.');
    }
  }

  Future<void> salvarMensagens({
    required int idUsuario,
    required String pergunta,
    required String resposta,
  }) async {
    await _request(
      'POST',
      '/historico',
      body: {
        'id_usuario': idUsuario,
        'pergunta': pergunta,
        'resposta': resposta,
      },
    );
  }

  Future<void> limparHistorico(int idUsuario) async {
    await _request('DELETE', '/historico/$idUsuario');
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    late http.Response response;
    try {
      response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
    } on TimeoutException {
      throw const ChatHistoryException('O histórico demorou para responder.');
    } on http.ClientException {
      throw const ChatHistoryException('Não foi possível acessar o histórico.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChatHistoryException(
        'Erro no histórico (HTTP ${response.statusCode}).',
      );
    }
    return response;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
