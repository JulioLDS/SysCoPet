import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pet_model.dart';

class PetService {
  //Adicionar pet
  Future<String?> addPet(PetModel pet) async {
  final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pets'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(pet.toJson()),
    );

  final data = jsonDecode(response.body);

  if (response.statusCode != 201) {

      if (data['erros'] != null) {
        return (data['erros']as List).join('\n');
      }

      return data['erro'] ?? 'Erro desconhecido';
  }

    return null;
  }

//Buscar pet
  Future<List<PetModel>> buscarPetsUsuario(int idUsuario) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/usuario/$idUsuario',
      ),
    );

    final List data = jsonDecode(response.body);

    return data
        .map((pet) => PetModel.fromJson(pet))
        .toList();
  }

//Editar pet
  Future<String?> atualizarPet(PetModel pet) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/pets/${pet.idPet}'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(pet.toJson()),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      if (data['erros'] != null) {
        return (data['erros'] as List).join('\n');
      }

      return data['erro'] ?? 'Erro desconhecido';
    }

    return null;
  }

  //Deletar pet
  Future<String?> deletarPet(int idPet) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/$idPet',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['erro'] ?? 'Erro ao excluir pet';
    }

    return null;
  }

}