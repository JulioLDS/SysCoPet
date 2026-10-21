import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chatbot_response_model.dart';

class ChatbotService {
  // TROCAR QUANDO SUBIR API <---------------------------------
  static const String baseUrl = 'https://URL-DO-CHATBOT.onrender.com';

  //Temporario para teste de interface (pode apagar depois)
  Future<ChatbotResponseModel> enviarMensagem(
    String mensagem, ) async {

    await Future.delayed(
      const Duration(
        seconds: 1,
      ),
    );

    return ChatbotResponseModel(
      contextoSuficiente: true,

      resposta:
          'Esta é uma resposta temporária do assistente 4UPet para testar a interface.',

      fontes: const [
        'Fonte de teste',
      ],
    );
  }

  //Ativar quando subir api
  /*Future<ChatbotResponseModel> enviarMensagem(
    String mensagem,
  ) async {
    final url = Uri.parse('$baseUrl/chat',);

    print('POST chatbot: $url');
    print('Pergunta: $mensagem');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mensagem': mensagem,
      }),
    );

    print('Status chatbot: ${response.statusCode}',);
    print('Body chatbot: ${response.body}',);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar chatbot',);
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Resposta inválida do chatbot',);
    }

    return ChatbotResponseModel.fromJson(decoded,);
  }*/
}