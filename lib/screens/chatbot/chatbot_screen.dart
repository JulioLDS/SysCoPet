import 'package:flutter/material.dart';

import '../../models/chat_message_model.dart';
import '../../services/chatbot_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({
    super.key,
  });

  @override
  State<ChatbotScreen> createState() =>
      _ChatbotScreenState();
}

class _ChatbotScreenState
    extends State<ChatbotScreen> {

  final TextEditingController
      _messageController =  TextEditingController();

  final ScrollController
      _scrollController = ScrollController();

  final ChatbotService _service =  ChatbotService();

  final List<ChatMessageModel>
      _mensagens = [];

  bool _carregando = false;

  Future<void> _enviarMensagem() async {
    final texto =
        _messageController.text.trim();

    if (
        texto.isEmpty || _carregando) {
      return;
    }

    setState(() {
      _mensagens.add(
        ChatMessageModel(
          texto: texto,
          usuario: true,
        ),
      );

      _carregando = true;
    });

    _messageController.clear();

    _scrollParaFinal();

    try {
      final resposta =
          await _service.enviarMensagem(
        texto,
      );

      if (!mounted) return;

      setState(() {
        _mensagens.add(
          ChatMessageModel(
            texto: resposta.resposta,
            usuario: false,
            fontes: resposta.fontes,
          ),
        );
      });

    } catch (e) {
      print(
        'Erro chatbot: $e',
      );

      if (!mounted) return;

      setState(() {
        _mensagens.add(
          ChatMessageModel(
            texto:
                'Não foi possível consultar o assistente no momento.',
            usuario: false,
          ),
        );
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      _scrollParaFinal();
    }
  }

  void _scrollParaFinal() {
    Future.delayed(
      const Duration(
        milliseconds: 100,
      ),
      () {
        if (!_scrollController.hasClients) {
          return;
        }

        _scrollController.animateTo(
          _scrollController
              .position
              .maxScrollExtent,

          duration: const Duration(
            milliseconds: 300,
          ),

          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Assistente 4UPet',
        ),

        backgroundColor:
            const Color(0xFF0D9488),

        foregroundColor:
            Colors.white,
      ),

      body: Column(
        children: [
          Expanded(
            child: _mensagens.isEmpty
                ? _buildInicio()
                : ListView.builder(
                    controller: _scrollController,

                    padding: const EdgeInsets.all(16),

                    itemCount: _mensagens.length,

                    itemBuilder:
                        (context, index) {
                      return _buildMensagem(
                        _mensagens[index],
                      );
                    },
                  ),
          ),

          if (_carregando)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),

              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,

                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),

                  SizedBox(width: 10),

                  Text(
                    'Assistente está pensando...',
                  ),
                ],
              ),
            ),

          _buildCampoMensagem(),
        ],
      ),
    );
  }

  Widget _buildInicio() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.pets,
              size: 64,
              color:
                  Color(0xFF0D9488),
            ),

            SizedBox(height: 18),

            Text(
              'Olá! Sou o assistente do 4UPet',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Envie uma pergunta sobre saúde e cuidados com seu pet.',
              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMensagem(
    ChatMessageModel mensagem,
  ) {
    return Align(
      alignment: mensagem.usuario
          ? Alignment.centerRight
          : Alignment.centerLeft,

      child: Container(
        constraints:
            const BoxConstraints(
          maxWidth: 650,
        ),

        margin:
            const EdgeInsets.only(
          bottom: 12,
        ),

        padding:
            const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: mensagem.usuario
              ? const Color(
                  0xFF0D9488,
                )
              : Colors.white,

          borderRadius:
              BorderRadius.circular(
            16,
          ),

          border: mensagem.usuario
              ? null
              : Border.all(
                  color:
                      Colors.grey.shade200,
                ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Text(
              mensagem.texto,

              style: TextStyle(
                color:
                    mensagem.usuario
                        ? Colors.white
                        : const Color(
                            0xFF1E293B,
                          ),

                fontSize: 15,
              ),
            ),

            if (
                !mensagem.usuario &&
                mensagem.fontes.isNotEmpty) ...[
              const SizedBox(
                height: 12,
              ),

              const Divider(),

              const Text(
                'Fontes',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              ...mensagem.fontes.map(
                (fonte) => Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 3,
                  ),

                  child: Text(
                    '• $fonte',

                    style:
                        const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
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
      padding:
          const EdgeInsets.all(14),

      decoration: const BoxDecoration(
        color: Colors.white,

        border: Border(
          top: BorderSide(
            color:
                Color(0xFFE2E8F0),
          ),
        ),
      ),

      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller:
                    _messageController,

                enabled:
                    !_carregando,

                minLines: 1,
                maxLines: 4,

                textInputAction:
                    TextInputAction.send,

                onSubmitted: (_) {
                  _enviarMensagem();
                },

                decoration:
                    InputDecoration(
                  hintText:
                      'Pergunte ao 4UPet...',

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF8FAFC,
                  ),

                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),

                    borderSide:
                        BorderSide.none,
                  ),

                  contentPadding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Container(
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFF0D9488),
                shape: BoxShape.circle,
              ),

              child: IconButton(
                onPressed:
                    _carregando
                        ? null
                        : _enviarMensagem,

                color: Colors.white,

                icon:
                    const Icon(
                  Icons.send,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}