import 'package:flutter/foundation.dart';

class PetModel {
  final int? idPet;
  final int idUsuario;
  final String nome;
  final String especie;
  final int? idRaca;
  final String? nomeRaca;
  final String? dataNascimento;
  final double peso;
  final double? altura;
  final String porte;
  final String? urlFoto;

  PetModel({
    this.idPet,
    required this.idUsuario,
    required this.nome,
    required this.especie,
    this.idRaca,
    this.nomeRaca,
    this.dataNascimento,
    required this.peso,
    this.altura,
    required this.porte,
    this.urlFoto,
  });

  //Preparo para campos nulos
  static int? _intNullable(dynamic valor) {
    if (valor == null) return null;
    if (valor is int) return valor;
    return int.tryParse(valor.toString());
  }

  static int _intObrigatorio(dynamic valor, {int padrao = 0}) {
    if (valor == null) return padrao;
    if (valor is int) return valor;
    return int.tryParse(valor.toString()) ?? padrao;
  }

  static double? _doubleNullable(dynamic valor) {
    if (valor == null) return null;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();

    return double.tryParse(valor.toString().replaceAll(',', '.'));
  }

  static double _doubleObrigatorio(dynamic valor, {double padrao = 0}) {
    if (valor == null) return padrao;
    if (valor is double) return valor;
    if (valor is int) return valor.toDouble();

    return double.tryParse(valor.toString().replaceAll(',', '.')) ?? padrao;
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      idPet: int.parse(json['id'].toString()),
      idUsuario: _intObrigatorio(json['id_usuario']),
      nome: json['nome']?.toString() ?? '',
      especie: json['especie']?.toString() ?? '',
      idRaca: _intNullable(json['id_raca']),
      nomeRaca: json['nome_raca']?.toString(),
      dataNascimento: json['data_nascimento']?.toString(),
      peso: _doubleObrigatorio(json['peso']),
      altura: _doubleNullable(json['altura']),
      porte: json['porte']?.toString() ?? '',
      urlFoto: json['url_foto']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPet': idPet,
      'id_usuario': idUsuario,
      'nome': nome,
      'especie': especie,
      'id_raca': idRaca,
      'data_nascimento': dataNascimento,
      'peso': peso,
      'altura': altura,
      'porte': porte,
      'url_foto': urlFoto,
    }..removeWhere((key, value) => value == null);
  }

  String? get dataNascimentoFormatada {
    if (dataNascimento == null) return null;

    return dataNascimento!.split('T').first;
  }
}
