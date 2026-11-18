import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';
import '../../services/chatbot_service.dart';
import 'package:provider/provider.dart';
import '../../controllers/chat_session_controller.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_history_service.dart';
import '../../widgets/chatbot/chat_history_actions.dart';

class ChatbotScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final ChatbotService? chatbotService;
  final ChatHistoryService? historyService;

  const ChatbotScreen({
    super.key,
    this.onClose,
    this.chatbotService,
    this.historyService,
  });

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  ChatSessionController? _chat;
  int? _usuarioChat;
  List<ChatMessageModel> get _mensagens => _chat?.mensagens ?? const [];
  bool get _carregando => _chat?.enviandoMensagem ?? false;
  bool get _carregandoHistorico => _chat?.carregandoHistorico ?? false;
  bool get _ocupado => _chat?.ocupado ?? false;
  bool get _podeLimpar =>
      _chat?.idUsuario != null && _mensagens.isNotEmpty && !_ocupado;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_chat != null) return;
    final chat = ChatSessionController(
      authProvider: context.read<AuthProvider>(),
      chatbotService: widget.chatbotService,
      historyService: widget.historyService,
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
      _messageController.clear();
    }
    setState(() {});
    _scrollParaFinal();
  }

  Future<void> _enviarMensagem() async {
    final texto = _messageController.text.trim();
    if (texto.isEmpty || _ocupado || _chat == null) return;
    _messageController.clear();
    await _chat!.enviarMensagem(texto);
  }

  void _scrollParaFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _chat?.removeListener(_atualizarChat);
    _chat?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        toolbarHeight: 56,
        leading: widget.onClose != null
          ? Transform.translate(
              offset: const Offset(0, -12),
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
                tooltip: 'Fechar chat',
              ),
            )
          : null,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: const Text(
            'Assistente 4UPet',
            style: TextStyle(fontSize: 22),
          ),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _podeLimpar
                ? () => confirmarLimparHistorico(context, _chat!)
                : null,
            tooltip: 'Limpar conversa',
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _carregandoHistorico
                ? const Center(child: CircularProgressIndicator())
                : _mensagens.isEmpty
                ? _buildInicio()
                : ListView.builder(
                    controller: _scrollController,

                    padding: const EdgeInsets.all(16),

                    itemCount: _mensagens.length,

                    itemBuilder: (context, index) {
                      return _buildMensagem(_mensagens[index]);
                    },
                  ),
          ),

          if (_carregando)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),

              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,

                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),

                  SizedBox(width: 10),

                  Text('Assistente está pensando...'),
                ],
              ),
            ),

          _buildCampoMensagem(),
        ],
      ),
    );
  }

  Widget _buildInicio() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.pets,
                      size: 48,
                      color: Color(0xFF0D9488),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Olá! Sou o assistente do 4UPet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Envie uma pergunta sobre saúde e cuidados com seu pet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMensagem(ChatMessageModel mensagem) {
    return Align(
      alignment: mensagem.usuario
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),

        margin: const EdgeInsets.only(bottom: 12),

        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: mensagem.usuario ? const Color(0xFF0D9488) : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: mensagem.usuario
              ? null
              : Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              mensagem.texto,

              style: TextStyle(
                color: mensagem.usuario
                    ? Colors.white
                    : const Color(0xFF1E293B),

                fontSize: 15,
              ),
            ),

            if (!mensagem.usuario && mensagem.fontes.isNotEmpty) ...[
              const SizedBox(height: 12),

              const Divider(),

              const Text(
                'Fontes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),

              const SizedBox(height: 5),

              ...mensagem.fontes.map(
                (fonte) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),

                  child: Text(
                    '• $fonte',

                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCampoMensagem() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),

      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,

                enabled: !_ocupado,

                minLines: 1,
                maxLines: 4,

                textInputAction: TextInputAction.send,

                onSubmitted: (_) {
                  _enviarMensagem();
                },

                decoration: InputDecoration(
                  hintText: 'Pergunte ao 4UPet...',

                  filled: true,

                  fillColor: const Color(0xFFF8FAFC),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),

                    borderSide: BorderSide.none,
                  ),

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                shape: BoxShape.circle,
              ),

              child: IconButton(
                onPressed: _ocupado ? null : _enviarMensagem,

                color: Colors.white,

                icon: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
