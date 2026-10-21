import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';
import '../../services/chatbot_service.dart';

class ChatbotBottomSheet extends StatefulWidget {
  const ChatbotBottomSheet({super.key});

  @override
  State<ChatbotBottomSheet> createState() => _ChatbotBottomSheetState();
}

class _ChatbotBottomSheetState extends State<ChatbotBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatbotService _service = ChatbotService();

  final List<ChatMessageModel> _messages = [
    ChatMessageModel(
      texto:
          'Olá! Sou o assistente 4UPet. Como posso ajudar com a saúde do seu pet hoje?',
      usuario: false,
    ),
  ];

  bool _isTyping = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessageModel(texto: text, usuario: true));
      _messages.add(ChatMessageModel(texto: '...', usuario: false));
      _isTyping = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await _service.enviarMensagem(text);

      setState(() {
        _messages.removeLast();

        if (response.contextoSuficiente) {
          _messages.add(
            ChatMessageModel(
              texto: response.resposta,
              usuario: false,
              fontes: response.fontes.isNotEmpty ? response.fontes : [],
            ),
          );
        } else {
          _messages.add(
            ChatMessageModel(
              texto: response.resposta.isEmpty
                  ? 'Desculpe, não encontrei essa informação na minha base de conhecimento veterinária. Tente reformular a pergunta.'
                  : response.resposta,
              usuario: false,
            ),
          );
        }
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(
          ChatMessageModel(
            texto:
                'Ops! Tive um problema de conexão. Verifique sua internet e tente novamente.',
            usuario: false,
          ),
        );
      });
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      // ✅ Ocupa toda a altura disponível
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        // ✅ Sombra apenas à esquerda (para destacar do conteúdo da Home)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ Header do painel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(color: Color(0xFF0D9488)),
            child: Row(
              children: [
                const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Assistente 4UPet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // ✅ Botão X para fechar (chama o Navigator.pop para segurança)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // ✅ Lista de Mensagens
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.usuario;

                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0D9488) : Colors.white,
                      borderRadius: BorderRadius.circular(14).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : null,
                        bottomLeft: !isUser ? const Radius.circular(4) : null,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg.texto,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white
                                : const Color(0xFF1E293B),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        if (msg.fontes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(color: Colors.grey, height: 1),
                          const SizedBox(height: 4),
                          const Text(
                            'Fontes:',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                          const SizedBox(height: 2),
                          ...msg.fontes.map(
                            (fonte) => Padding(
                              padding: const EdgeInsets.only(
                                left: 6,
                                bottom: 2,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.link,
                                    size: 10,
                                    color: Color(0xFF0D9488),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      fonte,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Barra de Input
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 10,
              bottom: 10 + (keyboardHeight > 0 ? 10 : 16),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Digite sua dúvida...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _isTyping
                      ? Colors.grey
                      : const Color(0xFF0D9488),
                  child: _isTyping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: _sendMessage,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
