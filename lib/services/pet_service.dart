import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

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

  //Upload de foto
  Future<String?> uploadFotoPet(int idPet, XFile imagem,) async {

    final bytes = await imagem.readAsBytes();

    //debugagem
    print(imagem.mimeType);
    print(imagem.name);

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/$idPet/photo',
      ),
    );

    final mime = imagem.mimeType ?? 'image/jpeg';

    request.files.add(
      await http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: imagem.name,
        contentType: MediaType.parse(mime),
      ),
    );

    final response = await request.send();

    final body = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      print(body);

      try {
        final data = jsonDecode(body);
        return data['error'];
      } catch (_) {
        return body;
      }
    }
  }

    //Deletar foto
Future<String?> removerFotoPet(int idPet) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConfig.baseUrl}/pets/$idPet/photo',
      ),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      return data['error'];
    }

    return null;
  }
}

