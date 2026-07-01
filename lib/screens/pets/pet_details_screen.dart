import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import 'package:syscopet/screens/pets/pet_edit_screen.dart';

import '../../models/pet_model.dart';

class PetDetailsScreen extends StatefulWidget {
  final PetModel pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  final ImagePicker _picker = ImagePicker();
  Future<void> _selecionarFoto() async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagem == null) return;

    final provider = Provider.of<PetProvider>(context, listen: false);

    final erro = await provider.uploadFotoPet(widget.pet.idPet!, imagem);

    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Foto enviada!")));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.nome)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // FOTO
            CircleAvatar(
              radius: 60,
              backgroundImage: widget.pet.urlFoto != null
                  ? NetworkImage(widget.pet.urlFoto!)
                  : null,
              child: widget.pet.urlFoto == null
                  ? const Icon(Icons.pets, size: 60)
                  : null,
            ),

            const SizedBox(height: 16),

            //upload
            ElevatedButton.icon(
              onPressed: _selecionarFoto,
              icon: const Icon(Icons.photo_camera),
              label: Text(
                widget.pet.urlFoto == null ? "Adicionar foto" : "Alterar foto",
              ),
            ),

            //Deletar foto
            if (widget.pet.urlFoto != null)
              TextButton.icon(
                onPressed: () async {
                  final provider = Provider.of<PetProvider>(
                    context,
                    listen: false,
                  );

                  final erro = await provider.removerFotoPet(widget.pet.idPet!);

                  if (!mounted) return;

                  if (erro != null) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(erro)));
                    return;
                  }

                  setState(() {});
                },
                icon: const Icon(Icons.delete),
                label: const Text("Remover foto"),
              ),

            const SizedBox(height: 30),

            _infoTile('Nome', widget.pet.nome),

            _infoTile('Espécie', widget.pet.especie),

            _infoTile('Peso', '${widget.pet.peso} kg'),

            _infoTile('Altura', widget.pet.altura?.toString() ?? '-'),

            _infoTile(
              'Porte',
              widget.pet.porte.isEmpty ? '-' : widget.pet.porte,
            ),

            _infoTile(
              'Nascimento',
              formatarData(widget.pet.dataNascimento) ?? '-',
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Editar pet'),
                onPressed: () async {
                  // abrir tela edição
                  final atualizou = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPetFormScreen(pet: widget.pet),
                    ),
                  );
                  if (atualizou == true) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Excluir pet'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _confirmarExclusao(context),
              ),
            ),

            const SizedBox(height: 40),

            Card(
              child: ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Lembretes'),
                subtitle: const Text('Em desenvolvimento'),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.vaccines),
                title: const Text('Vacinas'),
                subtitle: const Text('Em desenvolvimento'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String titulo, String valor) {
    return Card(
      child: ListTile(title: Text(titulo), subtitle: Text(valor)),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir pet'),
        content: const Text('Deseja excluir este pet?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final petProvider = Provider.of<PetProvider>(
                context,
                listen: false,
              );
              final erro = await petProvider.deletarPet(widget.pet.idPet!);

              if (!context.mounted) return;

              if (erro != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(erro)));
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet excluído com sucesso')),
              );

              Navigator.pop(context, true);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

String formatarData(String? data) {
  if (data == null) return 'Não informado';

  final limpa = data.split('T').first;
  final partes = limpa.split('-');

  return '${partes[2]}/${partes[1]}/${partes[0]}';
}
