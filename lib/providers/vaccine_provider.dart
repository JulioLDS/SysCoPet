import 'package:flutter/material.dart';

import '../models/vaccine_action_result.dart';
import '../models/vaccine_calendar_model.dart';
import '../services/vaccine_service.dart';

class VaccineProvider extends ChangeNotifier {
  final VaccineService _service = VaccineService();

  List<VaccineCalendarModel> calendario = [];

  bool isLoading = false;

  Future<void> carregarCalendario(int idPet,) async {
    isLoading = true;
    notifyListeners();

    try {
      calendario =
          await _service.buscarCalendarioDoPet(
        idPet,
      );

      calendario.sort(
        (a, b) =>
            a.dataPrevista.compareTo(
          b.dataPrevista,
        ),
      );

      print('Vacinas carregadas: ' '${calendario.length}',);
    } catch (e) {
      print('Erro ao carregar calendário: $e',);

      calendario = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<VaccineActionResult> registrarDose({
    required VaccineCalendarModel dose,
    required String status,
    DateTime? dataAplicacao,
  }) async {
    isLoading = true;
    notifyListeners();

    final resultado =
        await _service.registrarDose(
      dose: dose,
      status: status,
      dataAplicacao: dataAplicacao,
    );

    if (!resultado.sucesso) {
      isLoading = false;
      notifyListeners();

      return resultado;
    }

    // Backend pode ter reprogramado
    // todas as próximas doses.
    await carregarCalendario(
      dose.idPet,
    );

    return resultado;
  }
}