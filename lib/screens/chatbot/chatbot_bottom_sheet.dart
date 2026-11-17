import 'package:flutter/material.dart';
import '../../models/chat_message_model.dart';
import '../../services/chatbot_service.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_session_controller.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_history_service.dart';
import '../../widgets/chatbot/chat_history_actions.dart';

class ChatbotBottomSheet extends StatefulWidget {
  // ✅ Callback para fechar (ao invés de Navigator.pop)
  final VoidCallback onClose;

  const ChatbotBottomSheet({
    super.key,
    required this.onClose,
    this.chatbotService,
    this.historyService,
  });
  final ChatbotService? chatbotService;
  final ChatHistoryService? historyService;

  @override
  State<ChatbotBottomSheet> createState() => _ChatbotBottomSheetState();
}

class _ChatbotBottomSheetState extends State<ChatbotBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ChatSessionController? _chat;
  int? _usuarioChat;
  int _expandedMessageIndex = -1;

  List<ChatMessageModel> get _messages => [
    if (_chat?.mensagens.isEmpty ?? true)
      const ChatMessageModel(
        texto:
            'Olá! Sou o assistente 4UPet. Como posso ajudar com a saúde do seu pet hoje?',
        usuario: false,
      ),
    ...?_chat?.mensagens,
    if (_chat?.enviandoMensagem == true)
      const ChatMessageModel(texto: '...', usuario: false),
  ];
  bool get _isTyping => _chat?.ocupado ?? false;
  bool get _carregandoHistorico => _chat?.carregandoHistorico ?? false;
  bool get _podeLimpar =>
      _chat?.idUsuario != null &&
      (_chat?.mensagens.isNotEmpty ?? false) &&
      !_isTyping;

  // ✅ Sugestões rápidas
  final List<Map<String, dynamic>> _sugestoesRapidas = [
    {'icone': Icons.pets, 'texto': 'Quais são as vacinas?'},
    {'icone': Icons.calendar_today, 'texto': 'Quando aplicar?'},
    {'icone': Icons.vaccines, 'texto': 'Agendar vacina'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_chat != null) return;
    final chat = ChatSessionController(
      authProvider: context.read<AuthProvider>(),
      chatbotService: widget.chatbotService,
      historyService: widget.historyService,
      mensagemErro:
          'Ops! Tive um problema de conexão. Verifique sua internet e tente novamente.',
    );
    _chat = chat;
    _usuarioChat = chat.idUsuario;
    chat.addListener(_atualizarChat);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) chat.carregarHistorico();
    });
  }

  void _atualizarChat() {
    if (!mounted) return;
    if (_usuarioChat != _chat?.idUsuario) {
      _usuarioChat = _chat?.idUsuario;
      _controller.clear();
      _expandedMessageIndex = -1;
    }
    setState(() {});
    _scrollToBottom();
  }

  @override
  void dispose() {
    _chat?.removeListener(_atualizarChat);
    _chat?.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviarMensagem(String texto) async {
    if (texto.trim().isEmpty || _isTyping || _chat == null) return;
    _expandedMessageIndex = -1;
    _controller.clear();
    await _chat!.enviarMensagem(texto);
  }

  void _enviarSugestao(String sugestao) {
    _enviarMensagem(sugestao);
  }

  // ✅ Método para fechar usando a callback
  void _fecharChat() {
    widget.onClose();
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Widget flutuante: tamanho fixo, não tela inteira
      width: 600,
      height: 1050,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ✅ HEADER: avatar + título + pata branca + X
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: const BoxDecoration(color: Color(0xFF0D9488)),
              child: Row(
                children: [
                  // Avatar do robô
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      color: Color(0xFF0D9488),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Título + subtítulo com pata branca
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Assistente 4UPet',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Text(
                              'Sempre aqui para ajudar!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // ✅ Pata branca única
                            const Icon(
                              Icons.pets,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _podeLimpar
                        ? () => confirmarLimparHistorico(context, _chat!)
                        : null,
                    tooltip: 'Limpar conversa',
                    icon: const Icon(
                      Icons.delete_sweep_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  // ✅ Apenas o X (minimizar removido)
                  Material(
                    color: Colors.white.withOpacity(0.15),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _fecharChat,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ LISTA DE MENSAGENS
            Expanded(
              child: _carregandoHistorico
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isUser = msg.usuario;
                        final isLast = index == _messages.length - 1;

                        return Column(
                          children: [
                            if (isUser)
                              _buildUserMessage(msg)
                            else if (msg.ehErro)
                              _buildErrorMessage(msg) // ✅ sem patinha azul
                            else
                              _buildBotMessage(msg, index),

                            if (isLast && !isUser && !msg.ehErro && !_isTyping)
                              _buildSugestoesRapidas(),
                          ],
                        );
                      },
                    ),
            ),

            // ✅ BARRA DE INPUT
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      enabled: !_isTyping,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _enviarMensagem,
                      decoration: InputDecoration(
                        hintText: 'Digite sua dúvida...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: const Color(0xFF0D9488),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _isTyping
                          ? null
                          : () => _enviarMensagem(_controller.text),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0D9488),
                          shape: BoxShape.circle,
                        ),
                        child: _isTyping
                            ? const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ WIDGETS DE MENSAGEM ============

  Widget _buildUserMessage(ChatMessageModel msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.texto,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
            ),
            child: const Icon(Icons.person, color: Color(0xFF0D9488), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBotMessage(ChatMessageModel msg, int index) {
    final temFontes = msg.fontes.isNotEmpty;
    final expanded = _expandedMessageIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFF0D9488),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    msg.texto,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (temFontes) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _expandedMessageIndex = expanded ? -1 : index;
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.description_outlined,
                            color: Color(0xFF0D9488),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            expanded ? 'Ocultar detalhes' : 'Ver mais detalhes',
                            style: const TextStyle(
                              color: Color(0xFF0D9488),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            expanded ? Icons.expand_less : Icons.chevron_right,
                            color: const Color(0xFF0D9488),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                    if (expanded) ...[
                      const SizedBox(height: 8),
                      ...msg.fontes.map(
                        (fonte) => Padding(
                          padding: const EdgeInsets.only(left: 22, bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.link,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fonte,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Mensagem de erro SEM patinha azul — apenas balão branco
  Widget _buildErrorMessage(ChatMessageModel msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Avatar do robô (mesmo padrão das mensagens normais)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488).withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Color(0xFF0D9488),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.texto,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSugestoesRapidas() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _sugestoesRapidas.map((sugestao) {
          return Material(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () => _enviarSugestao(sugestao['texto'] as String),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      sugestao['icone'] as IconData,
                      color: const Color(0xFF0D9488),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sugestao['texto'] as String,
                      style: const TextStyle(
                        color: Color(0xFF0D9488),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
