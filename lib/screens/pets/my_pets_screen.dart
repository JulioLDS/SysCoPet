import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import 'package:syscopet/providers/auth_provider.dart';
import '../../models/pet_model.dart';
import '../pets/pet_details_screen.dart';
import '../pets/pet_form_dialog.dart';
import '../../widgets/common/custom_snackbar.dart';

class MeusPetsScreen extends StatefulWidget {
  const MeusPetsScreen({super.key});

  @override
  State<MeusPetsScreen> createState() => _MeusPetsScreenState();
}

class _MeusPetsScreenState extends State<MeusPetsScreen> {
  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await petProvider.carregarPets(authProvider.currentUser!.id);
    }
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

  // ✅ FUNÇÃO DE IDADE PADRONIZADA (IGUAL À DA HOME)
  String _calcularIdade(String? dataNascimento) {
    if (dataNascimento == null || dataNascimento.isEmpty) {
      return 'Idade não informada';
    }

    String data = dataNascimento.trim();
    String dataCompleta = data;
    bool temMes = false;
    bool temDia = false;

    // Caso venha só o ano: 2024
    if (RegExp(r'^\d{4}$').hasMatch(data)) {
      dataCompleta = '$data-01-01';
    }
    // Caso venha ano e mês: 2024-05
    else if (RegExp(r'^\d{4}-\d{1,2}$').hasMatch(data)) {
      final partes = data.split('-');
      final ano = partes[0];
      final mes = partes[1].padLeft(2, '0');
      dataCompleta = '$ano-$mes-01';
      temMes = true;
    }
    // Caso venha data no formato ISO: 2024-05-20
    else if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}').hasMatch(data)) {
      final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(data);
      if (match == null) return 'Data inválida';
      final ano = match.group(1)!;
      final mes = match.group(2)!.padLeft(2, '0');
      final dia = match.group(3)!.padLeft(2, '0');
      dataCompleta = '$ano-$mes-$dia';
      temMes = true;
      temDia = true;
    }
    // Caso venha no formato brasileiro: 20/05/2024
    else if (RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$').hasMatch(data)) {
      final partes = data.split('/');
      final dia = partes[0].padLeft(2, '0');
      final mes = partes[1].padLeft(2, '0');
      final ano = partes[2];
      dataCompleta = '$ano-$mes-$dia';
      temMes = true;
      temDia = true;
    } else {
      return 'Data inválida';
    }

    final nascimento = DateTime.tryParse(dataCompleta);
    if (nascimento == null) return 'Data inválida';

    final hoje = DateTime.now();
    if (nascimento.isAfter(hoje)) return 'Data inválida';

    int anos = hoje.year - nascimento.year;
    int meses = hoje.month - nascimento.month;
    int dias = hoje.day - nascimento.day;

    if (dias < 0) {
      meses--;
      final ultimoDiaMesAnterior = DateTime(hoje.year, hoje.month, 0);
      dias += ultimoDiaMesAnterior.day;
    }

    if (meses < 0) {
      anos--;
      meses += 12;
    }

    final partesIdade = <String>[];

    // Se tiver 1 ano ou mais, mostra anos e meses
    if (anos > 0) {
      partesIdade.add('$anos ${anos == 1 ? 'ano' : 'anos'}');
      if (temMes && meses > 0) {
        partesIdade.add('$meses ${meses == 1 ? 'mês' : 'meses'}');
      }
      return partesIdade.join(' e ');
    }

    // Se tiver menos de 1 ano, mostra meses e dias
    if (temMes && meses > 0) {
      partesIdade.add('$meses ${meses == 1 ? 'mês' : 'meses'}');
    }

    if (temDia && dias > 0) {
      partesIdade.add('$dias ${dias == 1 ? 'dia' : 'dias'}');
    }

    if (partesIdade.isEmpty) {
      if (temDia) return 'Menos de 1 dia';
      if (temMes) return 'Menos de 1 mês';
      return 'Menos de 1 ano';
    }

    return partesIdade.join(' e ');
  }

  String _obterNomeRaca(PetModel pet) {
    if (pet.idRaca == null ||
        pet.nomeRaca == null ||
        pet.nomeRaca!.trim().isEmpty) {
      return 'SRD';
    }
    return pet.nomeRaca!;
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final pets = petProvider.pets;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // ✅ HEADER COM GRADIENTE E BOTÃO VOLTAR
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // ✅ BOTÃO DE VOLTAR
                          _HoverButton(
                            onTap: () => Navigator.pop(context),
                            hoverColor: Colors.white.withOpacity(0.3),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.pets,
                              color: Color(0xFF0D9488),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Meus Pets',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Gerencie todos os seus pets em um só lugar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ CONTEÚDO EM GRID (VÁRIAS LINHAS)
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: pets.isEmpty
                ? _buildEmptyState()
                : SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.70,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final pet = pets[index];
                      return _buildPetCard(pet, index);
                    }, childCount: pets.length),
                  ),
          ),

          // ✅ ESPAÇO PARA O FAB NÃO SOBREPOR
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ✅ FLOATING ACTION BUTTON
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final cadastrou = await showDialog<bool>(
            context: context,
            builder: (_) => const PetFormDialog(),
          );

          if (cadastrou == true && mounted) {
            await _carregarPets();
            CustomSnackbar.showSuccess(
              context,
              'Pet cadastrado com sucesso!',
              color: const Color(0xFF047857),
            );
          }
        },
        backgroundColor: const Color(0xFF0D9488),
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Adicionar Pet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  // ✅ CARD DE PET (Estilo Vertical com Foto Grande)
  Widget _buildPetCard(PetModel pet, int index) {
    final especieFormatada = _formatarEspecie(pet.especie);
    final idade = _calcularIdade(
      pet.dataNascimento,
    ); // ✅ Agora usa a função completa
    final raca = _obterNomeRaca(pet);

    return HoverBuilder(
      builder: (context, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              if (isHovered)
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final atualizou = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => PetDetailsScreen(pet: pet)),
                );

                if (atualizou == true && mounted) {
                  await _carregarPets();
                }
              },
              borderRadius: BorderRadius.circular(25),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ FOTO DO PET
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0D9488).withOpacity(0.3),
                          width: 3,
                        ),
                        color: const Color(0xFFECFDF5),
                      ),
                      child: pet.urlFoto != null && pet.urlFoto!.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                pet.urlFoto!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            )
                          : const Icon(
                              Icons.pets,
                              color: Color(0xFF0D9488),
                              size: 50,
                            ),
                    ),
                    const SizedBox(height: 16),

                    // ✅ NOME (centralizado)
                    Text(
                      pet.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),

                    // ✅ RAÇA E ESPÉCIE (centralizados)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD1FAE5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            especieFormatada,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            raca,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ IDADE (Badge esticado, com padding horizontal para textos longos)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ), // ✅ Ajustado
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        idade,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ ESTADO VAZIO
  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.pets_outlined,
                color: Color(0xFF0D9488),
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Você ainda não tem pets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadastre seu primeiro pet para começar',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final cadastrou = await showDialog<bool>(
                  context: context,
                  builder: (_) => const PetFormDialog(),
                );

                if (cadastrou == true && mounted) {
                  await _carregarPets();
                  CustomSnackbar.showSuccess(
                    context,
                    'Pet cadastrado com sucesso!',
                    color: const Color(0xFF047857),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar meu primeiro pet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Widget helper para hover (reutilizado da Home)
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

// ✅ Widget helper para hover (igual da Home)
class HoverBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const HoverBuilder({super.key, required this.builder});

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: widget.builder(context, _isHovered),
    );
  }
}
