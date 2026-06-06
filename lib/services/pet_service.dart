import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/pet_model.dart';

class PetService {
  Future<String?> addPet(PetModel pet) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/pets'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_usuario': pet.idUsuario,
          'nome': pet.nome,
          'especie': pet.especie,
          'data_nascimento':
              pet.dataNascimento?.toIso8601String(),
          'peso': pet.peso,
          'altura': pet.altura,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        return data['erro'] ??
            'Erro ao cadastrar pet';
      }

      return null;
    } catch (e) {
      return 'Erro de conexão';
    }
  }

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

  
}