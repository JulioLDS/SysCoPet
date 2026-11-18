import 'package:flutter/material.dart';
import 'package:syscopet/models/pet_model.dart';

import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../models/reminder_ocurrence_model.dart';
import '../services/notification_service.dart';

class ReminderCompletionResult {
  const ReminderCompletionResult(this.lembrete, {this.aviso});
  final ReminderModel lembrete;
  final String? aviso;
}

class ReminderProvider extends ChangeNotifier {
  ReminderProvider({
    ReminderService? service,
    Future<void> Function(ReminderModel lembrete)? cancelarNotificacao,
    Future<void> Function(ReminderModel lembrete)? agendarNotificacao,
  }) : _service = service ?? ReminderService(),
       _ownsService = service == null,
       _agendarNotificacao = agendarNotificacao ?? _agendarPadrao,
       _cancelarNotificacao =
           cancelarNotificacao ??
           NotificationService.cancelarNotificacaoDoLembrete;

  final ReminderService _service;
  final bool _ownsService;
  final Future<void> Function(ReminderModel lembrete) _agendarNotificacao;
  String? avisoCriacao;
  final Future<void> Function(ReminderModel lembrete) _cancelarNotificacao;
  final Set<int> _concluindo = {};
  final Set<int> _concluidosConfirmados = {};
  bool _disposed = false;

  static Future<void> _agendarPadrao(ReminderModel lembrete) =>
      NotificationService.agendarNotificacao(
        id: NotificationService.gerarIdNotificacao(lembrete),
        titulo: lembrete.titulo,
        descricao: lembrete.descricao,
        dataHora: lembrete.dataHora,
      );

  bool estaConcluindo(int id) => _concluindo.contains(id);

  Future<ReminderCompletionResult> concluirLembrete({
    required int idLembrete,
    required int idPet,
    required String recorrencia,
  }) async {
    // A query atual altera a série inteira; nunca usá-la para uma recorrência.
    if (recorrencia != 'unica') {
      throw const ReminderCompletionException(
        'A conclusão de uma ocorrência recorrente ainda não está disponível.',
      );
    }
    if (_disposed || !_concluindo.add(idLembrete)) {
      throw const ReminderCompletionException(
        'Aguarde a conclusão do lembrete terminar.',
      );
    }
    notifyListeners();
    try {
      final updated = await _service.concluirLembrete(idLembrete);
      if (updated.idPet != idPet) {
        throw const ReminderCompletionException(
          'A API retornou um lembrete de outro pet.',
        );
      }
      _concluidosConfirmados.add(idLembrete);
      if (!_disposed) {
        lembretes = lembretes
            .map(
              (item) => item.idLembrete == idLembrete && item.idPet == idPet
                  ? updated
                  : item,
            )
            .toList();
        ocorrencias.removeWhere(
          (item) => item.id == idLembrete && item.idPet == idPet,
        );
        ocorrenciasPet.removeWhere(
          (item) => item.id == idLembrete && item.idPet == idPet,
        );
        notifyListeners();
      }
      String? aviso;
      try {
        await _cancelarNotificacao(updated);
      } catch (_) {
        aviso =
            'Lembrete concluído, mas não foi possível cancelar a notificação neste dispositivo.';
      }
      return ReminderCompletionResult(updated, aviso: aviso);
    } finally {
      _concluindo.remove(idLembrete);
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  List<ReminderModel> lembretes = [];
  //Usada pela home
  List<ReminderOccurrenceModel> ocorrencias = [];
  //Usada pela petDetails
  List<ReminderOccurrenceModel> ocorrenciasPet = [];

  bool isLoading = false;

  //Carregar lembretes de um pet
  Future<void> carregarLembretesDoPet(int idPet) async {
    isLoading = true;
    notifyListeners();

    try {
      lembretes = await _service.buscarLembretesDoPet(idPet);

      lembretes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //buscar lembrete por id
  Future<ReminderModel?> buscarLembretePorId(int idPet, int idLembrete) async {
    final item = await _service.buscarLembretePorId(idPet, idLembrete);
    if (item != null && _concluidosConfirmados.contains(idLembrete)) {
      return item.copyWith(concluido: true);
    }
    return item;
  }

  //Carregar lembretes DOS pets
  Future<void> carregarLembretesDosPets(List<PetModel> pets) async {
    isLoading = true;
    notifyListeners();

    try {
      final todosLembretes = <ReminderModel>[];

      for (final pet in pets) {
        if (pet.idPet == null) continue;

        final lembretesDoPet = await _service.buscarLembretesDoPet(pet.idPet!);

        todosLembretes.addAll(lembretesDoPet);
      }

      lembretes = todosLembretes
          .where(
            (lembrete) =>
                lembrete.pendente &&
                !_concluidosConfirmados.contains(lembrete.idLembrete),
          )
          .toList();

      lembretes.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Carregar ocorrencia do pet
  Future<void> carregarOcorrenciasDoPet(int idPet) async {
    isLoading = true;
    notifyListeners();

    try {
      ocorrenciasPet = await _service.buscarOcorrencias(idPet);

      ocorrenciasPet = ocorrenciasPet
          .where((o) => o.pendente && !_concluidosConfirmados.contains(o.id))
          .toList();

      ocorrenciasPet.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    } catch (e) {
      print('Erro ao carregar ocorrências do pet: $e');

      ocorrenciasPet = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Carregar ocorrencia DE TODOS os pets
  Future<void> carregarOcorrenciasDosPets(List<PetModel> pets) async {
    isLoading = true;
    notifyListeners();

    try {
      final todasOcorrencias = <ReminderOccurrenceModel>[];

      for (final pet in pets) {
        print("Buscando ocorrências do pet ${pet.idPet}");

        if (pet.idPet == null) continue;

        final ocorrenciasDoPet = await _service.buscarOcorrencias(pet.idPet!);

        print("Pet ${pet.idPet}: ${ocorrenciasDoPet.length} ocorrências");

        todasOcorrencias.addAll(ocorrenciasDoPet);
      }

      print("TOTAL: ${todasOcorrencias.length}");

      ocorrencias = todasOcorrencias
          .where(
            (ocorrencia) =>
                ocorrencia.pendente &&
                !_concluidosConfirmados.contains(ocorrencia.id),
          )
          .toList();

      ocorrencias.sort((a, b) => a.dataHora.compareTo(b.dataHora));
    } catch (e) {
      print('Erro ao carregar ocorrências dos pets: $e');

      ocorrencias = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Criar lembrete
  Future<String?> criarLembrete(ReminderModel lembrete) async {
    isLoading = true;
    avisoCriacao = null;
    notifyListeners();
    try {
      final erro = await _service.criarLembrete(lembrete);
      if (erro != null) return erro;
      // O registro já foi criado: falhas locais não devem induzir outro POST.
      try {
        await _agendarNotificacao(lembrete);
      } catch (_) {
        avisoCriacao =
            'Lembrete criado, mas a notificação não pôde ser agendada neste dispositivo.';
      }
      try {
        await carregarLembretesDoPet(lembrete.idPet);
        await carregarOcorrenciasDoPet(lembrete.idPet);
      } catch (_) {
        avisoCriacao =
            'Lembrete criado, mas não foi possível atualizar a lista. Reabra a agenda.';
      }
      return null;
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  //Atualizar lembrete
  Future<String?> atualizarLembrete(ReminderModel lembrete) async {
    isLoading = true;
    notifyListeners();

    final erro = await _service.atualizarLembrete(lembrete);

    if (erro != null) {
      isLoading = false;
      notifyListeners();
      return erro;
    }

    await carregarOcorrenciasDoPet(lembrete.idPet);

    return null;
  }

  //Deletar lembrete
  // Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete, int idPet) async {
    isLoading = true;
    notifyListeners();

    final erro = await _service.deletarLembrete(idLembrete);

    if (erro == null) {
      // ✅ 1. Remove o lembrete das listas localmente para atualização INSTANTÂNEA em todas as telas
      ocorrenciasPet.removeWhere((ocorrencia) => ocorrencia.id == idLembrete);
      ocorrencias.removeWhere((ocorrencia) => ocorrencia.id == idLembrete);

      // ✅ 2. Recarrega do backend para garantir consistência dos dados
      await carregarOcorrenciasDoPet(idPet);

      // ✅ 3. Notifica todas as telas (Home, PetDetails, etc.) para redesenhar
      notifyListeners();
    } else {
      isLoading = false;
      notifyListeners();
    }

    return erro;
  }
}
