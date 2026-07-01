import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import 'package:syscopet/screens/pets/pet_edit_dialog.dart';

import '../../models/pet_model.dart';

class PetDetailsDialog extends StatefulWidget {
  final PetModel pet;

  const PetDetailsDialog({super.key, required this.pet});

  @override
  State<PetDetailsDialog> createState() => _PetDetailsDialogState();
}

class _PetDetailsDialogState extends State<PetDetailsDialog> {
  final ImagePicker _picker = ImagePicker();
  late PetModel _currentPet;

  @override
  void initState() {
    super.initState();
    _currentPet = widget.pet;
  }

  Future<void> _selecionarFoto() async {
    final imagem = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagem == null) return;

    final provider = Provider.of<PetProvider>(context, listen: false);
    final erro = await provider.uploadFotoPet(_currentPet.idPet!, imagem);

    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    setState(() {
      _currentPet = PetModel(
        idPet: _currentPet.idPet,
        nome: _currentPet.nome,
        especie: _currentPet.especie,
        dataNascimento: _currentPet.dataNascimento,
        peso: _currentPet.peso,
        altura: _currentPet.altura,
        porte: _currentPet.porte,
        idUsuario: _currentPet.idUsuario,
        urlFoto: provider.pets
            .firstWhere((p) => p.idPet == _currentPet.idPet)
            .urlFoto,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Foto enviada!")));
  }

  Future<void> _removerFoto() async {
    final provider = Provider.of<PetProvider>(context, listen: false);
    final erro = await provider.removerFotoPet(_currentPet.idPet!);

    if (!mounted) return;

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro)));
      return;
    }

    setState(() {
      _currentPet = PetModel(
        idPet: _currentPet.idPet,
        nome: _currentPet.nome,
        especie: _currentPet.especie,
        dataNascimento: _currentPet.dataNascimento,
        peso: _currentPet.peso,
        altura: _currentPet.altura,
        porte: _currentPet.porte,
        idUsuario: _currentPet.idUsuario,
        urlFoto: null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: _currentPet.urlFoto != null
                        ? NetworkImage(_currentPet.urlFoto!)
                        : null,
                    child: _currentPet.urlFoto == null
                        ? const Icon(
                            Icons.pets,
                            size: 40,
                            color: Color(0xFF0D9488),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPet.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatarEspecie(_currentPet.especie),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ScrollbarTheme(
                data: ScrollbarThemeData(
                  thumbColor: MaterialStateProperty.all(
                    const Color(0xFF0D9488),
                  ),
                  thickness: MaterialStateProperty.all(12.0),
                  radius: const Radius.circular(6),
                  crossAxisMargin: 4,
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _selecionarFoto,
                                icon: const Icon(
                                  Icons.photo_camera,
                                  color: Color(0xFF0D9488),
                                ),
                                label: Text(
                                  _currentPet.urlFoto == null
                                      ? "Adicionar foto"
                                      : "Alterar foto",
                                  style: const TextStyle(
                                    color: Color(0xFF0D9488),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF0D9488),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            if (_currentPet.urlFoto != null) ...[
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: _removerFoto,
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  "Remover",
                                  style: TextStyle(color: Colors.red),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        _infoCard(
                          icon: Icons.pets,
                          iconColor: const Color(0xFF0D9488),
                          iconBg: const Color(0xFFD1FAE5),
                          titulo: 'Nome',
                          valor: _currentPet.nome,
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.category_outlined,
                          iconColor: const Color(0xFF2563EB),
                          iconBg: const Color(0xFFDBEAFE),
                          titulo: 'Espécie',
                          valor: _formatarEspecie(_currentPet.especie),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                icon: Icons.monitor_weight_outlined,
                                iconColor: const Color(0xFFEA580C),
                                iconBg: const Color(0xFFFFEDD5),
                                titulo: 'Peso',
                                valor: '${_currentPet.peso} kg',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                icon: Icons.height,
                                iconColor: const Color(0xFF7C3AED),
                                iconBg: const Color(0xFFEDE9FE),
                                titulo: 'Altura',
                                valor: _currentPet.altura != null
                                    ? '${_currentPet.altura} cm'
                                    : '-',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _infoCard(
                          icon: Icons.cake_outlined,
                          iconColor: const Color(0xFFDC2626),
                          iconBg: const Color(0xFFFEE2E2),
                          titulo: 'Nascimento',
                          valor: formatarData(_currentPet.dataNascimento),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final atualizou = await showDialog<bool>(
                                context: context,
                                builder: (context) =>
                                    PetEditDialog(pet: _currentPet),
                              );
                              if (atualizou == true) {
                                Navigator.pop(context, true);
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Editar pet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmarExclusao(context),
                            icon: const Icon(Icons.delete),
                            label: const Text('Excluir pet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEDD5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.notifications,
                                color: Color(0xFFEA580C),
                              ),
                            ),
                            title: const Text(
                              'Lembretes',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Em desenvolvimento'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.vaccines,
                                color: Color(0xFF059669),
                              ),
                            ),
                            title: const Text(
                              'Vacinas',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: const Text('Em desenvolvimento'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String titulo,
    required String valor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('Excluir pet'),
          ],
        ),
        content: Text(
          'Deseja realmente excluir ${_currentPet.nome}? Esta ação não pode ser desfeita.',
        ),
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
              final erro = await petProvider.deletarPet(_currentPet.idPet!);

              if (!context.mounted) return;

              if (erro != null) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(erro)));
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pet excluído com sucesso'),
                  backgroundColor: Color(0xFF059669),
                ),
              );

              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  String _formatarEspecie(String especie) {
    switch (especie.toLowerCase()) {
      case 'cao':
        return 'Cão';
      case 'gato':
        return 'Gato';
      case 'outro':
        return 'Outro';
      default:
        return especie;
    }
  }
}

String formatarData(String? data) {
  if (data == null || data.isEmpty) return 'Não informado';

  final limpa = data.split('T').first;
  final partes = limpa.split('-');

  if (partes.length == 1) {
    return partes[0];
  } else if (partes.length == 2) {
    return '${partes[1]}/${partes[0]}';
  }

  return '${partes[2]}/${partes[1]}/${partes[0]}';
}
