import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/vaccine_action_result.dart';
import '../models/vaccine_calendar_model.dart';

class VaccineService {
  Future<List<VaccineCalendarModel>>
      buscarCalendarioDoPet(
    int idPet,
  ) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vacinas/calendario/$idPet',
    );

    print('GET calendário de vacinas: $url');

    final response = await http.get(url);

    print(
      'Status calendário: ${response.statusCode}',
    );

    print(
      'Body calendário: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Erro ao buscar calendário de vacinas',
      );
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! List) {
      throw Exception(
        'Formato inválido retornado pela API',
      );
    }

    return decoded
        .map(
          (item) =>
              VaccineCalendarModel.fromJson(
            item,
          ),
        )
        .toList();
  }

  Future<VaccineActionResult> registrarDose({
    required VaccineCalendarModel dose,
    required String status,
    DateTime? dataAplicacao,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/vacinas/registrar-dose',
    );

    final body = {
      'id_pet': dose.idPet,
      'vacina_template_id':
          dose.vacinaTemplateId,
      'dose_numero': dose.doseNumero,
      'status': status,
      'tipo': dose.tipo,

      // Só envia se for aplicação
      'data_aplicacao':
          dataAplicacao != null
              ? _formatarSomenteData(
                  dataAplicacao,
                )
              : null,
    };

    print('POST registrar dose: $url');
    print(
      'Body registrar dose: ${jsonEncode(body)}',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print(
      'Status registrar dose: ${response.statusCode}',
    );

    print(
      'Body registrar dose: ${response.body}',
    );

    Map<String, dynamic> data = {};

    try {
      final decoded =
          jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (_) {}

    if (response.statusCode != 200) {
      String erro =
          'Erro ao registrar dose';

      if (data['erros'] is List) {
        erro = (data['erros'] as List)
            .map((e) => e.toString())
            .join('\n');
      } else if (data['erro'] != null) {
        erro = data['erro'].toString();
      }

      return VaccineActionResult(
        sucesso: false,
        erro: erro,
      );
    }

    final avisos =
        data['avisos'] is List
            ? (data['avisos'] as List)
                .map((e) => e.toString())
                .toList()
            : <String>[];

    return VaccineActionResult(
      sucesso: true,
      avisos: avisos,
      proximoReforco:
          data['proximo_reforco'] != null
              ? DateTime.parse(
                  data['proximo_reforco']
                      .toString(),
                )
              : null,
    );
  }

  String _formatarSomenteData(
    DateTime data,
  ) {
    final ano =
        data.year.toString();

    final mes =
        data.month
            .toString()
            .padLeft(2, '0');

    final dia =
        data.day
            .toString()
            .padLeft(2, '0');

    return '$ano-$mes-$dia';
  }
}