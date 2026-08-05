import 'package:flutter/material.dart';
import 'package:syscopet/models/pet_model.dart';

import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../models/reminder_ocurrence_model.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _service = ReminderService();

  List<ReminderModel> lembretes = [];
  List<ReminderOccurrenceModel> ocorrencias = [];
  bool isLoading = false;

  //Carregar lembretes de um pet
  Future<void> carregarLembretesDoPet(int idPet) async {
    isLoading = true;
    notifyListeners();

    try {
      lembretes = await _service.buscarLembretesDoPet(idPet);

      lembretes.sort(
        (a, b) => a.dataHora.compareTo(b.dataHora),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Carregar lembretes DOS pets
  Future<void> carregarLembretesDosPets(
    List<PetModel> pets,) async {isLoading = true;notifyListeners();

    try {
      final todosLembretes = <ReminderModel>[];

      for (final pet in pets) {
        if (pet.idPet == null) continue;

        final lembretesDoPet =
            await _service.buscarLembretesDoPet(
          pet.idPet!,
        );

        todosLembretes.addAll(lembretesDoPet);
      }

      lembretes = todosLembretes
          .where((lembrete) => lembrete.ativo)
          .toList();

      lembretes.sort(
        (a, b) => a.dataHora.compareTo(b.dataHora),
      );
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
      ocorrencias = await _service.buscarOcorrencias(idPet);

      ocorrencias.sort(
        (a, b) => a.dataHora.compareTo(b.dataHora),
      );
    } catch (e) {
      print('Erro ao carregar ocorrências do pet: $e');
      ocorrencias = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //Carregar ocorrencia DE TODOS os pets
  Future<void> carregarOcorrenciasDosPets(List<PetModel> pets,) async {
    isLoading = true;
    notifyListeners();

    try {
      final todasOcorrencias = <ReminderOccurrenceModel>[];

      for (final pet in pets) {
        print("Buscando ocorrências do pet ${pet.idPet}");

        if (pet.idPet == null) continue;

        final ocorrenciasDoPet =
            await _service.buscarOcorrencias(pet.idPet!,);

        print("Pet ${pet.idPet}: ${ocorrenciasDoPet.length} ocorrências",);

        todasOcorrencias.addAll(ocorrenciasDoPet);
      }
      
      print("TOTAL: ${todasOcorrencias.length}");

      ocorrencias = todasOcorrencias
          .where((ocorrencia) => ocorrencia.ativo)
          .toList();

      ocorrencias.sort(
        (a, b) => a.dataHora.compareTo(b.dataHora),
      );
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
    notifyListeners();

    final erro = await _service.criarLembrete(lembrete);

    if (erro != null) {
      isLoading = false;
      notifyListeners();
      return erro;
    }
    await carregarOcorrenciasDoPet(lembrete.idPet);

    return null;
  }

  //Deletar lembrete
  Future<String?> deletarLembrete(int idLembrete, int idPet) async {
    isLoading = true;
    notifyListeners();

    final erro = await _service.deletarLembrete(idLembrete);

    if (erro == null) {
      await carregarLembretesDoPet(idPet);
    } else {
      isLoading = false;
      notifyListeners();
    }

    return erro;
  }
}