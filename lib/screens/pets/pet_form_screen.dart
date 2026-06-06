import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();

  String? especieSelecionada;
  DateTime? dataNascimento;

  @override
  void dispose() {
    nomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (data != null) {
      setState(() {
        dataNascimento = data;
      });
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

    final pet = PetModel(
      idUsuario: usuario!.id,
      nome: nomeController.text.trim(),
      especie: especieSelecionada!,
      dataNascimento: dataNascimento,
      peso: double.parse(pesoController.text),
      altura: alturaController.text.isEmpty
          ? null
          : double.parse(alturaController.text),
      porte: '',
    );

    final erro = await petProvider.cadastrarPet(pet);

    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet cadastrado com sucesso!'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar Pet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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

              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  dataNascimento == null
                      ? 'Selecionar data'
                      : '${dataNascimento!.day}/${dataNascimento!.month}/${dataNascimento!.year}',
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _selecionarData,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: pesoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                ),
                validator: (value) {
                  final peso = double.tryParse(value ?? '');

                  if (peso == null) {
                    return 'Peso inválido';
                  }

                  if (peso <= 0 || peso >= 200) {
                    return 'Peso deve estar entre 0 e 200kg';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

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
                    : const Text('Cadastrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
