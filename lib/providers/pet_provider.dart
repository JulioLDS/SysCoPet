import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  final PetService _petService = PetService();
  List<PetModel> pets = [];

  bool isLoading = false;

  Future<Map<String, String?>> cadastrarPet(PetModel pet) async {
    isLoading = true;
    notifyListeners();

    try {
      final resultado = await _petService.addPetComRetornoCompleto(pet);

      isLoading = false;
      notifyListeners();

      return resultado;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {'erro': e.toString(), 'alerta': null};
    }
  }

  Future<void> carregarPets(int usuarioId) async {
    pets = await _petService.buscarPetsUsuario(usuarioId);

    notifyListeners();
  }

  // ✅ Retorna Map com mensagem e alerta
  Future<Map<String, String?>> atualizarPet(PetModel pet) async {
    isLoading = true;
    notifyListeners();

    try {
      final resultado = await _petService.atualizarPetComRetornoCompleto(pet);

      isLoading = false;
      notifyListeners();

      return resultado;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {'erro': e.toString(), 'alerta': null};
    }
  }

  Future<String?> deletarPet(int idPet) async {
    return await _petService.deletarPet(idPet);
  }

  Future<String?> uploadFotoPet(int idPet, XFile imagem) async {
    return await _petService.uploadFotoPet(idPet, imagem);
  }

  Future<String?> removerFotoPet(int idPet) async {
    return await _petService.removerFotoPet(idPet);
  }
}
