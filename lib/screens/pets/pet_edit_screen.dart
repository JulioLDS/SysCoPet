import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';

class EditPetFormScreen extends StatefulWidget {
  final PetModel pet;

  const EditPetFormScreen({
    super.key,
    required this.pet,
  });


  @override
  State<EditPetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<EditPetFormScreen> {

  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  final anoController = TextEditingController();
  final mesController = TextEditingController();
  final diaController = TextEditingController();

  String? especieSelecionada;

  @override
  void dispose() {
    nomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();

    anoController.dispose();
    mesController.dispose();
    diaController.dispose();
    
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    nomeController.text = widget.pet.nome;
    pesoController.text = widget.pet.peso.toString();

    if (widget.pet.altura != null) {
      alturaController.text = widget.pet.altura.toString();
    }

    especieSelecionada = widget.pet.especie;

    if (widget.pet.dataNascimento != null) {
      final data = widget.pet.dataNascimento!.split('T').first;

      final partes = data.split('-');

      if (partes.isNotEmpty) {
        anoController.text = partes[0];
      }

      if (partes.length >= 2) {
        mesController.text = partes[1];
      }

      if (partes.length >= 3) {
        diaController.text = partes[2];
      }
    }
  }

  Future<void> _salvarPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);

    final petProvider =
        Provider.of<PetProvider>(context, listen: false);

    final usuario = authProvider.currentUser;

    String? dataNascimento;

    final ano = anoController.text.trim();
    final mes = mesController.text.trim();
    final dia = diaController.text.trim();

    if (ano.isNotEmpty) {
      dataNascimento = ano;

      if (mes.isNotEmpty) {
        dataNascimento += '-${mes.padLeft(2, '0')}';

        if (dia.isNotEmpty) {
          dataNascimento += '-${dia.padLeft(2, '0')}';
        }
      }
    }

    final pet = PetModel(
      idPet: widget.pet.idPet,
      nome: nomeController.text.trim(),
      especie: especieSelecionada!,
      dataNascimento: dataNascimento,
      peso: double.parse(pesoController.text),
      altura: alturaController.text.isEmpty
          ? null
          : double.parse(alturaController.text),
      porte: '',
      idUsuario: usuario!.id,
    );

    final erro = await petProvider.atualizarPet(pet);

    if (!mounted) return;

    if (erro != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro'),
          content: Text(erro),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet alterado com sucesso!'),
      ),
    );

    await petProvider.carregarPets(usuario.id);
    if(!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              //nome
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Pet',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              //especie
              DropdownButtonFormField<String>(
                value: especieSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Espécie',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'cao',
                    child: Text('Cão'),
                  ),
                  DropdownMenuItem(
                    value: 'gato',
                    child: Text('Gato'),
                  ),
                  DropdownMenuItem(
                    value: 'outro',
                    child: Text('Outro'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    especieSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma espécie';
                  }
                  return null;
                },
              ),

              //Data de nascimento
              
              Row(
                children: [
                  Expanded(
                    child:TextField(
                    controller: anoController,
                    keyboardType: TextInputType.number,
                    decoration:  const InputDecoration(
                      labelText: 'Ano',
                    ),
                  ),
                  ),
                  
                  const SizedBox(width: 10),

                  Expanded(
                    child: TextField(
                    controller: mesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Mês (opcional)',
                    ),
                  ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child:TextField(
                    controller: diaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Dia (opcional)',
                    ),
                  ),
                  ),
                ],
              ),


              //peso
              const SizedBox(height: 16),

              TextFormField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                ),
                validator: (value) {
                  if(value==null || value.trim().isEmpty){
                    return 'Digite o peso';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              //altura
              TextFormField(
                controller: alturaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Altura (cm) - opcional',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: petProvider.isLoading
                    ? null
                    : _salvarPet,
                child: petProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Salvar alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}