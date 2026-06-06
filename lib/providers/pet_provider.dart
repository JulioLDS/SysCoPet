import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../services/pet_service.dart';

class PetProvider extends ChangeNotifier {
  final PetService _petService = PetService();
  List<PetModel> pets =[];

  bool isLoading = false;

  Future<String?> cadastrarPet(PetModel pet) async {
    isLoading = true;
    notifyListeners();

    final result = await _petService.addPet(pet);

    isLoading = false;
    notifyListeners();

    return result;
  }
  
  Future<void> carregarPets(int usuarioId) async {
  pets = await _petService.buscarPetsUsuario(usuarioId);

  notifyListeners();
  }

}