class ChatbotResponseModel {
  final bool contextoSuficiente;
  final String resposta;
  final List<String> fontes;

  ChatbotResponseModel({
    required this.contextoSuficiente,
    required this.resposta,
    required this.fontes,
  });

  factory ChatbotResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ChatbotResponseModel(
      contextoSuficiente:
          json['contexto_suficiente'] ?? false,

      resposta:
          json['resposta']?.toString() ??
          'Não foi possível obter uma resposta.',

      fontes:
          (json['fontes'] as List? ?? [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}