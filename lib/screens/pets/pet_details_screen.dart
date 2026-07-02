import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_model.dart';
import 'pet_edit_dialog.dart';

class PetDetailsScreen extends StatefulWidget {
  final PetModel pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  State<PetDetailsScreen> createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
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

    // Atualiza localmente
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
    ).showSnackBar(const SnackBar(content: Text("Foto enviada com sucesso!")));
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Foto removida com sucesso!")));
  }

  @override
  Widget build(BuildContext context) {
    final especieFormatada = _formatarEspecie(_currentPet.especie);
    final idade = calcularIdade(_currentPet.dataNascimento);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ✅ HEADER
          Container(
            color: const Color(0xFF0D9488),
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentPet.nome,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$especieFormatada • $idade',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Botão Editar
                TextButton.icon(
                  onPressed: () async {
                    final atualizou = await showDialog<bool>(
                      context: context,
                      builder: (context) => PetEditDialog(pet: _currentPet),
                    );

                    if (atualizou == true) {
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text(
                    'Editar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ CONTEÚDO
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📷 FOTO DO PET
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage:
                                  _currentPet.urlFoto != null &&
                                      _currentPet.urlFoto!.isNotEmpty
                                  ? NetworkImage(_currentPet.urlFoto!)
                                  : null,
                              child:
                                  (_currentPet.urlFoto == null ||
                                      _currentPet.urlFoto!.isEmpty)
                                  ? Icon(
                                      Icons.pets,
                                      size: 80,
                                      color: Colors.grey.shade400,
                                    )
                                  : null,
                            ),
                            // Botões de foto
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  if (_currentPet.urlFoto != null)
                                    IconButton(
                                      onPressed: _removerFoto,
                                      icon: const Icon(Icons.delete),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  IconButton(
                                    onPressed: _selecionarFoto,
                                    icon: const Icon(Icons.camera_alt),
                                    style: IconButton.styleFrom(
                                      backgroundColor: const Color(0xFF0D9488),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentPet.urlFoto == null
                              ? 'Clique na câmera para adicionar foto'
                              : 'Clique na câmera para alterar foto',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 📊 VISÃO GERAL
                  _buildSectionTitle('Visão Geral'),
                  const SizedBox(height: 12),
                  _buildInfoGrid(),
                  const SizedBox(height: 24),

                  // 💉 VACINAS
                  _buildSectionTitle('Vacinas'),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    icon: Icons.vaccines_outlined,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFD1FAE5),
                    title: 'Controle de Vacinas',
                    subtitle: 'Em desenvolvimento',
                  ),
                  const SizedBox(height: 24),

                  // 📅 CONSULTAS
                  _buildSectionTitle('Consultas'),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFDBEAFE),
                    title: 'Histórico de Consultas',
                    subtitle: 'Em desenvolvimento',
                  ),
                  const SizedBox(height: 24),

                  // 🔔 LEMBRETES
                  _buildSectionTitle('Lembretes'),
                  const SizedBox(height: 12),
                  _buildPlaceholderCard(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFFEA580C),
                    iconBg: const Color(0xFFFFEDD5),
                    title: 'Gerenciador de Lembretes',
                    subtitle: 'Em desenvolvimento',
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade em desenvolvimento'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add, color: Color(0xFF0D9488)),
                      label: const Text(
                        'Adicionar Lembrete',
                        style: TextStyle(color: Color(0xFF0D9488)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0D9488)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 🗑️ Botão Excluir Pet
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmarExclusao(context),
                      icon: const Icon(Icons.delete),
                      label: const Text('Excluir Pet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFF0D9488),
            borderRadius: BorderRadius.horizontal(left: Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _buildInfoCard(
          icon: Icons.monitor_weight_outlined,
          iconColor: const Color(0xFFEA580C),
          iconBg: const Color(0xFFFFEDD5),
          label: 'Peso',
          value: '${_currentPet.peso} kg',
        ),
        _buildInfoCard(
          icon: Icons.height,
          iconColor: const Color(0xFF7C3AED),
          iconBg: const Color(0xFFEDE9FE),
          label: 'Altura',
          value: _currentPet.altura != null
              ? '${_currentPet.altura} cm'
              : 'N/A',
        ),
        _buildInfoCard(
          icon: Icons.cake_outlined,
          iconColor: const Color(0xFFDC2626),
          iconBg: const Color(0xFFFEE2E2),
          label: 'Nascimento',
          value: _formatarData(_currentPet.dataNascimento),
        ),
        _buildInfoCard(
          icon: Icons.pets,
          iconColor: const Color(0xFF0D9488),
          iconBg: const Color(0xFFD1FAE5),
          label: 'Porte',
          value: _currentPet.porte.isNotEmpty ? _currentPet.porte : 'N/A',
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(
            Icons.construction_outlined,
            color: Colors.grey.shade400,
            size: 24,
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

  String _formatarData(String? data) {
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

  String calcularIdade(String? dataNascimento) {
    if (dataNascimento == null || dataNascimento.isEmpty) {
      return 'Sem idade';
    }

    String dataCompleta = dataNascimento;

    if (RegExp(r'^\d{4}$').hasMatch(dataNascimento)) {
      dataCompleta = '$dataNascimento-01-01';
    } else if (RegExp(r'^\d{4}-\d{2}$').hasMatch(dataNascimento)) {
      dataCompleta = '$dataNascimento-01';
    }

    final nascimento = DateTime.parse(dataCompleta);
    final hoje = DateTime.now();

    int anos = hoje.year - nascimento.year;

    if (hoje.month < nascimento.month ||
        (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
      anos--;
    }

    return '$anos anos';
  }
}
