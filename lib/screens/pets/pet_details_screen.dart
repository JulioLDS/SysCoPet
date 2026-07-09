import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/pet_model.dart';
import '../../widgets/common/custom_snackbar.dart';
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
      CustomSnackbar.showError(context, erro);
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

    CustomSnackbar.showSuccess(
      context,
      'Foto enviada com sucesso!',
      color: const Color(0xFF047857),
    );
  }

  Future<void> _removerFoto() async {
    final provider = Provider.of<PetProvider>(context, listen: false);
    final erro = await provider.removerFotoPet(_currentPet.idPet!);

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context, erro);
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

    CustomSnackbar.showSuccess(
      context,
      'Foto removida com sucesso!',
      color: const Color(0xFF047857),
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
                CustomSnackbar.showError(context, erro);
                return;
              }

              CustomSnackbar.showSuccess(
                context,
                'Pet excluído com sucesso!',
                color: const Color(0xFF047857),
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

  @override
  Widget build(BuildContext context) {
    final especieFormatada = _formatarEspecie(_currentPet.especie);
    final idade = calcularIdade(_currentPet.dataNascimento);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ✅ HEADER COM APP BAR
          SliverToBoxAdapter(
            child: Container(
              height: 100,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    // ✅ Botão Voltar com hover
                    _HoverButton(
                      onTap: () => Navigator.pop(context),
                      hoverColor: Colors.white.withOpacity(0.3),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Título e Subtítulo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPet.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$especieFormatada • $idade',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // ✅ Botão Editar com hover
                    _HoverButton(
                      onTap: () async {
                        final atualizou = await showDialog<bool>(
                          context: context,
                          builder: (context) => PetEditDialog(pet: _currentPet),
                        );

                        if (atualizou == true && mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                      hoverColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.edit,
                              color: Color(0xFF0D9488),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ CONTEÚDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 📷 CARD DE PERFIL
                  _buildProfileCard(),
                  const SizedBox(height: 24),

                  // 📊 VISÃO GERAL
                  _buildSectionTitle('Visão geral', Icons.bar_chart),
                  const SizedBox(height: 12),
                  _buildOverviewGrid(),
                  const SizedBox(height: 24),

                  // 💚 CUIDADOS
                  _buildSectionTitle('Cuidados', Icons.favorite_border),
                  const SizedBox(height: 12),
                  _buildCareItem(
                    icon: Icons.vaccines_outlined,
                    iconColor: const Color(0xFF10B981),
                    iconBg: const Color(0xFFD1FAE5),
                    title: 'Vacinas',
                    subtitle: 'Controle de Vacinas',
                    badge: 'Em desenvolvimento',
                    badgeColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 12),
                  _buildCareItem(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBg: const Color(0xFFEDE9FE),
                    title: 'Consultas',
                    subtitle: 'Histórico de Consultas',
                    badge: 'Em desenvolvimento',
                    badgeColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 12),
                  _buildCareItem(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFFF59E0B),
                    iconBg: const Color(0xFFFFEDD5),
                    title: 'Lembretes',
                    subtitle: 'Gerenciador de Lembretes',
                    badge: 'Em desenvolvimento',
                    badgeColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 24),

                  // ⏰ PRÓXIMOS LEMBRETES - BLOCO ÚNICO
                  _buildSectionTitle('Próximos lembretes', Icons.access_time),
                  const SizedBox(height: 12),

                  // ✅ Container único para todos os lembretes + botão
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ✅ Lembrete 1 - Vacina
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Ícone
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD1FAE5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.vaccines_outlined,
                                  color: Color(0xFF059669),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Vacina V8',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Mel',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Data/Hora com border radius
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      '24/05/2025',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                    Text(
                                      'Sábado, 10:00',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(
                                          0xFF059669,
                                        ).withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Seta
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF0D9488),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        // ✅ Linha separadora
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        // ✅ Lembrete 2 - Consulta
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Ícone
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDBEAFE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Texto
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Consulta veterinária',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Luna',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Data/Hora com border radius
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDBEAFE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      '02/06/2025',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2563EB),
                                      ),
                                    ),
                                    Text(
                                      'Segunda, 14:30',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Seta
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF0D9488),
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                        // ✅ Linha separadora
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        // ✅ Botão "Ver todos os lembretes" COM HOVER
                        StatefulBuilder(
                          builder: (context, setState) {
                            bool isHovered = false;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(() => isHovered = true),
                              onExit: (_) => setState(() => isHovered = false),
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isHovered
                                        ? const Color(0xFFECFDF5)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Ver todos os lembretes',
                                        style: TextStyle(
                                          color: Color(0xFF0D9488),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Color(0xFF0D9488),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ Botão "Adicionar lembrete" - SEM hover
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        CustomSnackbar.showWarning(
                          context,
                          'Funcionalidade em desenvolvimento',
                        );
                      },
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: const Color(0xFF0D9488).withOpacity(0.5),
                          strokeWidth: 2.5,
                          dashLength: 8,
                          gapLength: 5,
                          radius: 16,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D9488),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Adicionar lembrete',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Crie um novo lembrete para o seu pet',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF0D9488),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ Botão "Excluir pet" - SEM hover
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _confirmarExclusao(context),
                      child: CustomPaint(
                        painter: DashedBorderPainter(
                          color: Colors.red.withOpacity(0.5),
                          strokeWidth: 2.5,
                          dashLength: 8,
                          gapLength: 5,
                          radius: 16,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Excluir pet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Remover ${_currentPet.nome} da sua conta',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.red,
                                size: 24,
                              ),
                            ],
                          ),
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

  Widget _buildProfileCard() {
    final especieFormatada = _formatarEspecie(_currentPet.especie);
    final idade = calcularIdade(_currentPet.dataNascimento);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Foto do Pet com borda branca
            Column(
              children: [
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child:
                            _currentPet.urlFoto != null &&
                                _currentPet.urlFoto!.isNotEmpty
                            ? Image.network(
                                _currentPet.urlFoto!,
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                              )
                            : Icon(
                                Icons.pets,
                                size: 60,
                                color: Colors.grey.shade400,
                              ),
                      ),
                      // Botão da câmera
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _selecionarFoto,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF0D9488),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF0D9488),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ✅ Botão "Clique na câmera para adicionar foto"
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap:
                        _currentPet.urlFoto == null ||
                            _currentPet.urlFoto!.isEmpty
                        ? _selecionarFoto
                        : _removerFoto,
                    child: CustomPaint(
                      painter: DashedBorder(
                        color: const Color(0xFF0D9488).withOpacity(0.3),
                        strokeWidth: 2.5,
                        dashLength: 6,
                        gapLength: 4,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: const Color(0xFF0D9488),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _currentPet.urlFoto == null ||
                                      _currentPet.urlFoto!.isEmpty
                                  ? 'Clique na câmera para adicionar foto'
                                  : 'Clique para remover foto',
                              style: const TextStyle(
                                color: Color(0xFF0D9488),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
            const SizedBox(width: 28),
            // Informações
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPet.nome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      especieFormatada,
                      style: const TextStyle(
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    idade,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D9488), size: 20),
        const SizedBox(width: 8),
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

  Widget _buildOverviewGrid() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.monitor_weight_outlined,
            iconColor: const Color(0xFFEA580C),
            iconBg: const Color(0xFFFFEDD5),
            label: 'Peso',
            value: '${_currentPet.peso} kg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.height,
            iconColor: const Color(0xFF7C3AED),
            iconBg: const Color(0xFFEDE9FE),
            label: 'Altura',
            value: _currentPet.altura != null
                ? '${_currentPet.altura} cm'
                : 'N/A',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.cake_outlined,
            iconColor: const Color(0xFFEF4444),
            iconBg: const Color(0xFFFEE2E2),
            label: 'Nascimento',
            value: _formatarData(_currentPet.dataNascimento),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            icon: Icons.pets,
            iconColor: const Color(0xFF0D9488),
            iconBg: const Color(0xFFD1FAE5),
            label: 'Porte',
            value: _currentPet.porte.isNotEmpty ? _currentPet.porte : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard({
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCareItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      color: badgeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
        ],
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String date,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: iconColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }
}

// ✅ Widget para botão com hover - FORA da classe
class _HoverButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color hoverColor;

  const _HoverButton({
    required this.child,
    required this.onTap,
    required this.hoverColor,
  });

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovering ? 1.05 : 1.0),
          child: widget.child,
        ),
      ),
    );
  }
}

// ✅ Widget para borda tracejada
class DashedBorder extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorder({
    required this.color,
    required this.strokeWidth,
    this.dashLength = 6,
    this.gapLength = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ✅ Widget para borda tracejada arredondada
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double radius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    this.dashLength = 6,
    this.gapLength = 4,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
