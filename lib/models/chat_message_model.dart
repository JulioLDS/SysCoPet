class ChatMessageModel {
  final String texto;
  final bool usuario;
  final List<String> fontes;

  ChatMessageModel({
    required this.texto,
    required this.usuario,
    this.fontes = const [],
  });
}