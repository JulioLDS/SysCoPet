import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/chatbot_response_model.dart';

class ChatbotService {
  ChatbotService({
    http.Client? client,
    String? baseUrl,
    this.timeout = const Duration(seconds: 60),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null,
       baseUrl = (baseUrl ?? ApiConfig.chatbotUrl).replaceFirst(
         RegExp(r'/+$'),
         '',
       );

  final http.Client _client;
  final bool _ownsClient;
  final String baseUrl;
  final Duration timeout;

  Future<ChatbotResponseModel> enviarMensagem(String mensagem) async {
    late http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            // O Python continua recebendo somente a pergunta atual.
            body: jsonEncode({'mensagem': mensagem}),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw Exception('O assistente demorou para responder.');
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao assistente.');
    }
    if (response.statusCode != 200)
      throw Exception('Erro ao consultar chatbot.');
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic> ||
        decoded['resposta'] is! String ||
        (decoded['resposta'] as String).trim().isEmpty ||
        (decoded['fontes'] != null && decoded['fontes'] is! List) ||
        (decoded['contexto_suficiente'] != null &&
            decoded['contexto_suficiente'] is! bool)) {
      throw const FormatException('Resposta inválida do chatbot.');
    }
    return ChatbotResponseModel.fromJson(decoded);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
