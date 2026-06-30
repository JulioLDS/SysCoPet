import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  final PetService _petService = PetService();
  List<PetModel> pets =[];

  bool isLoading = false;

  Future<String?> cadastrarPet(PetModel pet) async {
    return await _petService.addPet(pet);
  }

  Future<void> carregarPets(int usuarioId) async {
  pets = await _petService.buscarPetsUsuario(usuarioId);

  notifyListeners();
  }

  Future<String?> atualizarPet(PetModel pet) async {
  return await _petService.atualizarPet(pet);
  }

  Future<String?> deletarPet(int idPet) async {
  return await _petService.deletarPet(idPet);
}

  Future<String?> uploadFotoPet(int idPet,XFile imagem,) async {
   return await _petService.uploadFotoPet(idPet,imagem,);
}

  Future<String?> removerFotoPet(int idPet,) async
   {return await _petService.removerFotoPet(idPet,);
}

}