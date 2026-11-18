class ReminderModel {
  final int? idLembrete;
  final int idPet;
  final String titulo;
  final String? descricao;
  final DateTime dataHora;
  final String tipo;
  final String recorrencia;
  final bool ativo;
  final bool concluido;

  // O booleano da API atual representa somente a conclusão de lembrete único.
  bool get concluidoDefinitivamente => recorrencia == 'unica' && concluido;
  bool get pendente => ativo && !concluidoDefinitivamente;

  ReminderModel({
    this.idLembrete,
    required this.idPet,
    required this.titulo,
    this.descricao,
    required this.dataHora,
    required this.tipo,
    required this.recorrencia,
    this.ativo = true,
    this.concluido = false,
  });

  ReminderModel copyWith({bool? concluido}) => ReminderModel(
    idLembrete: idLembrete,
    idPet: idPet,
    titulo: titulo,
    descricao: descricao,
    dataHora: dataHora,
    tipo: tipo,
    recorrencia: recorrencia,
    ativo: ativo,
    concluido: concluido ?? this.concluido,
  );

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      idLembrete: json['id'] != null
          ? int.parse(json['id'].toString())
          : json['id_lembrete'] != null
          ? int.parse(json['id_lembrete'].toString())
          : null,
      idPet: int.parse(json['id_pet'].toString()),
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      dataHora: DateTime.parse(json['data_hora']).toLocal(),
      tipo: json['tipo'] ?? '',
      recorrencia: json['recorrencia'] ?? 'unica',
      ativo: json['ativo'] ?? true,
      concluido: json['concluido'] == true || json['concluido'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_pet': idPet,
      'titulo': titulo,
      'descricao': descricao,
      'data_hora': dataHora.toUtc().toIso8601String(),
      'tipo': tipo,
      'recorrencia': recorrencia,
      'ativo': ativo,
      'concluido': concluido,
    };
  }
}
