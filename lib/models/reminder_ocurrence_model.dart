class ReminderOccurrenceModel {

  final int id;
  final int idPet;
  final String titulo;
  final String tipo;
  final String recorrencia;
  final bool ativo;

  final DateTime dataHora;

  final List<DateTime> proximasOcorrencias;

  ReminderOccurrenceModel({
    required this.id,
    required this.idPet,
    required this.titulo,
    required this.tipo,
    required this.recorrencia,
    required this.ativo,
    required this.dataHora,
    required this.proximasOcorrencias,
  });

  factory ReminderOccurrenceModel.fromJson(
      Map<String,dynamic> json){

    return ReminderOccurrenceModel(

      id: int.parse(json['id'].toString()),
      idPet: int.parse(json['id_pet'].toString()),
      titulo: json['titulo'],
      tipo: json['tipo'],
      recorrencia: json['recorrencia'],
      ativo: json['ativo'],
      dataHora: DateTime.parse(json['data_hora']),
      proximasOcorrencias:
          (json['proximas_ocorrencias'] as List)
              .map(
                (e)=>DateTime.parse(e),
              )
              .toList(),
    );
  }
}