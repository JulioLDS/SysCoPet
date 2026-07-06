class RacaModel {
  final int idRaca;
  final String nome;
  final String especie;

  RacaModel({
    required this.idRaca,
    required this.nome,
    required this.especie,
  });

  factory RacaModel.fromJson(Map<String, dynamic> json) {
    return RacaModel(
      idRaca: int.parse(json['id'].toString()),
      nome: json['nome'],
      especie: json['especie'],
    );
  }
}