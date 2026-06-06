class PetModel {
  final int? idPet;
  final int idUsuario;
  final String nome;
  final String especie;
  final DateTime? dataNascimento;
  final double peso;
  final double? altura;
  final String porte;

  PetModel({
    this.idPet,
    required this.idUsuario,
    required this.nome,
    required this.especie,
    this.dataNascimento,
    required this.peso,
    this.altura,
    required this.porte,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      idPet: json['id_pet'],
      idUsuario: json['id_usuario'],
      nome: json['nome'],
      especie: json['especie'],
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'])
          : null,
      peso: double.parse(json['peso'].toString()),
      altura: json['altura'] != null
          ? double.parse(json['altura'].toString())
          : null,
      porte: json['porte'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nome': nome,
      'especie': especie,
      'data_nascimento': dataNascimento?.toIso8601String(),
      'peso': peso,
      'altura': altura,
    };
  }
}