import 'package:flutter/material.dart';
import 'package:syscopet/models/pet_model.dart';

import '../models/reminder_model.dart';
import '../services/reminder_service.dart';

class ReminderProvider extends ChangeNotifier {
  final ReminderService _service = ReminderService();

  List<ReminderModel> lembretes = [];
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

  //Criar lembrete
  Future<String?> criarLembrete(ReminderModel lembrete) async {
    isLoading = true;
    notifyListeners();

    final erro = await _service.criarLembrete(lembrete);

    if (erro == null) {
      await carregarLembretesDoPet(lembrete.idPet);
    } else {
      isLoading = false;
      notifyListeners();
    }

    return erro;
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