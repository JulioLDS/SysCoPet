class PetModel {
  final int? idPet;
  final int idUsuario;
  final String nome;
  final String especie;
  final String? dataNascimento;
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
      idPet: int.parse(json['id'].toString()),
      idUsuario: int.parse(json['id_usuario'].toString()),
      nome: json['nome'],
      especie: json['especie'],
      dataNascimento: json['data_nascimento'],
      peso: double.parse(json['peso'].toString()),
      altura: json['altura'] != null
          ? double.parse(json['altura'].toString())
          : null,
      porte: json['porte'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_usuario': idUsuario,
      'nome': nome,
      'especie': especie,
      'data_nascimento': dataNascimento,
      'peso': peso,
      'altura': altura,
    };
  }

  String? get dataNascimentoFormatada {
    if (dataNascimento == null) return null;

    return dataNascimento!.split('T').first;
  }
}