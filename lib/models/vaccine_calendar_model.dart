class VaccineCalendarModel {
  final int id;
  final int idPet;
  final int vacinaTemplateId;
  final int doseNumero;

  final DateTime dataPrevista;
  final DateTime? dataAplicacao;

  final String tipo;
  final String status;

  final DateTime? proximoReforco;

  final String vacinaNome;

  final bool obrigatoria;
  final bool essencial;
  final bool atrasada;

  VaccineCalendarModel({
    required this.id,
    required this.idPet,
    required this.vacinaTemplateId,
    required this.doseNumero,
    required this.dataPrevista,
    this.dataAplicacao,
    required this.tipo,
    required this.status,
    this.proximoReforco,
    required this.vacinaNome,
    required this.obrigatoria,
    required this.essencial,
    required this.atrasada,
  });

  factory VaccineCalendarModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VaccineCalendarModel(
      id: int.parse(
        json['id'].toString(),
      ),

      idPet: int.parse(
        json['id_pet'].toString(),
      ),

      // O backend usa id_vacina
      vacinaTemplateId: int.parse(
        json['id_vacina'].toString(),
      ),

      doseNumero: int.parse(
        json['dose_numero'].toString(),
      ),

      dataPrevista: DateTime.parse(
        json['data_prevista'].toString(),
      ),

      dataAplicacao:
          json['data_aplicacao'] != null
              ? DateTime.parse(
                  json['data_aplicacao'].toString(),
                )
              : null,

      tipo: json['tipo']?.toString() ?? 'serie',

      status:
          json['status']?.toString() ?? 'pendente',

      proximoReforco:
          json['proximo_reforco'] != null
              ? DateTime.parse(
                  json['proximo_reforco'].toString(),
                )
              : null,

      vacinaNome:
          json['vacina_nome']?.toString() ??
          'Vacina',

      obrigatoria:
          json['obrigatoria'] ?? false,

      essencial:
          json['essencial'] ?? true,

      atrasada:
          json['atrasada'] ?? false,
    );
  }
}