import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/reminder_service.dart';
import '../common/custom_snackbar.dart';

Future<ReminderCompletionResult?> confirmarConclusaoLembrete(
  BuildContext context, {
  required int idLembrete,
  required int idPet,
  required String titulo,
  required String recorrencia,
}) async {
  final provider = context.read<ReminderProvider>();
  final auth = context.read<AuthProvider>();
  final userId = auth.currentUser?.id;
  if (userId == null || provider.estaConcluindo(idLembrete)) return null;
  if (recorrencia != 'unica') {
    CustomSnackbar.showWarning(
      context,
      'A conclusão de uma ocorrência recorrente ainda não está disponível.',
    );
    return null;
  }
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Concluir lembrete'),
      content: Text(
        'Marcar "$titulo" como concluído? Ele deixará de aparecer nas pendências.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Concluir'),
        ),
      ],
    ),
  );
  if (confirmar != true || !context.mounted || auth.currentUser?.id != userId)
    return null;
  try {
    final result = await provider.concluirLembrete(
      idLembrete: idLembrete,
      idPet: idPet,
      recorrencia: recorrencia,
    );
    if (!context.mounted || auth.currentUser?.id != userId) return result;
    if (result.aviso != null) {
      CustomSnackbar.showWarning(context, result.aviso!);
    } else {
      CustomSnackbar.showSuccess(
        context,
        'Lembrete concluído!',
        color: const Color(0xFF047857),
      );
    }
    return result;
  } on ReminderCompletionException catch (error) {
    if (context.mounted) CustomSnackbar.showError(context, error.message);
  } catch (_) {
    if (context.mounted)
      CustomSnackbar.showError(
        context,
        'Não foi possível concluir o lembrete. Tente novamente.',
      );
  }
  return null;
}
