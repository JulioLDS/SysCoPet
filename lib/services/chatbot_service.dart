import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chatbot_response_model.dart';

class ChatbotService {
  // TROCAR QUANDO SUBIR API <---------------------------------
  static const String baseUrl = 'https://chatbot-4upet.onrender.com';

  //Ativar quando subir api
  Future<ChatbotResponseModel> enviarMensagem(String mensagem) async {
    final url = Uri.parse('$baseUrl/chat');

    print('POST chatbot: $url');
    print('Pergunta: $mensagem');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mensagem': mensagem}),
    );

    print('Status chatbot: ${response.statusCode}');
    print('Body chatbot: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar chatbot');
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Resposta inválida do chatbot');
    }

    return ChatbotResponseModel.fromJson(decoded);
  }
}
