class ChatMessageModel {
  final String texto;
  final bool usuario;
  final List<String> fontes;
  final bool ehErro;

  const ChatMessageModel({
    required this.texto,
    required this.usuario,
    this.fontes = const [],
    this.ehErro = false,
  });
}
