import 'package:flutter/material.dart';

import '../../controllers/chat_session_controller.dart';

Future<void> confirmarLimparHistorico(
  BuildContext context,
  ChatSessionController chat,
) async {
  if (chat.ocupado || chat.idUsuario == null || chat.mensagens.isEmpty) return;
  final session = chat.versaoSessao;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Limpar conversa'),
      content: const Text(
        'Deseja apagar todo o histórico de conversa com o Assistente 4UPet?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Limpar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted || session != chat.versaoSessao)
    return;
  if (chat.ocupado) return;
  try {
    await chat.limparHistorico();
    if (!context.mounted || session != chat.versaoSessao) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Histórico excluído.')));
  } catch (_) {
    if (!context.mounted || session != chat.versaoSessao) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Não foi possível limpar o histórico.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
