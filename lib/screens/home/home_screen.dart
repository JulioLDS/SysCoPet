import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import 'package:syscopet/providers/reminder_provider.dart';
import '../pets/pet_form_dialog.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';
import '../pets/pet_edit_dialog.dart';
import '../pets/pet_details_screen.dart';
import '../pets/my_pets_screen.dart'; // ✅ Adicione esta linha

// ✅ Widget helper para hover
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

// ✅ Painter para borda tracejada
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DashedBorderPainter({
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

    // ✅ Ajuste: margem maior para dentro
    final margin = strokeWidth + 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        margin,
        margin,
        size.width - (margin * 2),
        size.height - (margin * 2),
      ),
      const Radius.circular(20),
    );

    final path = Path();
    path.addRRect(rect);

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

// ✅ Tela principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  //Métodos pro lembrete (nao sei um lugar pra por)
  String _nomePetPorId(int idPet) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    final petEncontrado = petProvider.pets.where((pet) => pet.idPet == idPet);

    if (petEncontrado.isEmpty) {
      return 'Pet';
    }

    return petEncontrado.first.nome;
  }

  IconData _iconePorTipo(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return Icons.restaurant;
      case 'banho':
        return Icons.shower;
      case 'medicamento':
        return Icons.medication;
      case 'consulta':
        return Icons.calendar_month;
      case 'vacina':
        return Icons.vaccines;
      default:
        return Icons.notifications_active;
    }
  }

  Color _corPorTipo(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return const Color(0xFFEA580C);
      case 'banho':
        return const Color(0xFF2563EB);
      case 'medicamento':
        return const Color(0xFF9333EA);
      case 'consulta':
        return const Color(0xFF0D9488);
      case 'vacina':
        return const Color(0xFF059669);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _corFundoPorTipo(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return const Color(0xFFFED7AA);
      case 'banho':
        return const Color(0xFFDBEAFE);
      case 'medicamento':
        return const Color(0xFFE9D5FF);
      case 'consulta':
        return const Color(0xFFCCFBF1);
      case 'vacina':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  String _formatarTipo(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return 'Alimentação';
      case 'banho':
        return 'Banho';
      case 'medicamento':
        return 'Medicamento';
      case 'consulta':
        return 'Consulta';
      case 'vacina':
        return 'Vacina';
      default:
        return tipo;
    }
  }

  String _formatarDataLembrete(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHoraLembrete(DateTime data) {
    return '${_nomeDiaSemana(data)}, '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }

  String _nomeDiaSemana(DateTime data) {
    switch (data.weekday) {
      case DateTime.monday:
        return 'Segunda';
      case DateTime.tuesday:
        return 'Terça';
      case DateTime.wednesday:
        return 'Quarta';
      case DateTime.thursday:
        return 'Quinta';
      case DateTime.friday:
        return 'Sexta';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final reminderProvider = Provider.of<ReminderProvider>(
        context,
        listen: false,
      );

      await petProvider.carregarPets(auth.currentUser!.id);
      await reminderProvider.carregarOcorrenciasDosPets(petProvider.pets);
      print("Pets carregados: ${petProvider.pets.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final user = authProvider.currentUser;
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final proximosLembretes =
        reminderProvider.ocorrencias
            .where(
              (lembrete) =>
                  lembrete.ativo && lembrete.dataHora.isAfter(DateTime.now()),
            )
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    //mude o número do take para mudar quantos lembretes aparecem na tela
    final lembretesParaMostrar = proximosLembretes.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ✅ CONTEÚDO SCROLLÁVEL (por baixo)
          Positioned.fill(
            top: 78, // ✅ Altura do header
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ SEÇÃO 1: BOAS-VINDAS
                  Container(
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // ✅ Background2 como fundo da seção
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/background2.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),

                        // ✅ Pets grandes
                        Positioned(
                          right: 300,
                          bottom: -220,
                          child: Image.asset(
                            'assets/images/pets_lado_esquerdo.png',
                            height: 600,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),

                        // ✅ Conteúdo de texto com card suave
                        Padding(
                          padding: const EdgeInsets.fromLTRB(200, 50, 40, 60),
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      const TextSpan(
                                        text:
                                            'Que alegria ter\nvocê por aqui, ',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF1E293B),
                                          height: 1.2,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${user?.nome?.split(' ').first ?? 'Usuário'}!',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0D9488),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Aqui, cada detalhe é pensado para o\nbem-estar e a saúde do seu pet.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ SEÇÃO 2: MEUS PETS + AÇÕES + LEMBRETES
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFF8FAFC,
                      ), // ✅ Volta a cor original do fundo
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // ✅ Conteúdo da seção
                        Padding(
                          padding: const EdgeInsets.fromLTRB(60, 30, 40, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.pets,
                                    color: const Color(0xFF0D9488),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Meus Pets',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async {
                                      final atualizou =
                                          await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MeusPetsScreen(),
                                            ),
                                          );

                                      if (atualizou == true && mounted) {
                                        final auth = Provider.of<AuthProvider>(
                                          context,
                                          listen: false,
                                        );
                                        await Provider.of<PetProvider>(
                                          context,
                                          listen: false,
                                        ).carregarPets(auth.currentUser!.id);
                                      }
                                    },
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Ver todos',
                                          style: TextStyle(
                                            color: Color(0xFF14B8A6),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Color(0xFF14B8A6),
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              SizedBox(
                                height: 280, // ✅ Aumentado de 240 para 260
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip
                                      .none, // ✅ Permite que a sombra ultrapasse
                                  padding: const EdgeInsets.symmetric(
                                    vertical:
                                        20, // ✅ Padding vertical para acomodar sombra
                                  ),
                                  children: [
                                    _buildAddPetCard(),
                                    const SizedBox(width: 15),
                                    ...petProvider.pets.map(
                                      (pet) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 15,
                                        ),
                                        child: _buildPetCard(
                                          pet: pet,
                                          age: calcularIdade(
                                            pet.dataNascimento,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // ✅ SEÇÃO AÇÕES RÁPIDAS - OPÇÃO 2
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
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
                                    // ✅ Título à esquerda
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.bolt,
                                                color: const Color(0xFF14B8A6),
                                                size: 28,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Ações rápidas',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // ✅ Texto com padding left de 10
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 15,
                                            ),
                                            child: Text(
                                              'Acesso fácil ao que\nimporta para o seu pet',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Icon(
                                            Icons.pets,
                                            color: const Color(
                                              0xFF14B8A6,
                                            ).withOpacity(0.15),
                                            size: 40,
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 20),

                                    // ✅ Cards à direita
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          _buildQuickActionCard(
                                            title: 'Vacinas',
                                            subtitle: 'Ver e agendar vacinas',
                                            icon: Icons.vaccines,
                                            color: const Color(0xFFD1FAE5),
                                            iconColor: const Color(0xFF059669),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildQuickActionCard(
                                            title: 'Consultas',
                                            subtitle: 'Agendar visita',
                                            icon: Icons.calendar_month,
                                            color: const Color(0xFFE9D5FF),
                                            iconColor: const Color(0xFF9333EA),
                                          ),
                                          const SizedBox(width: 12),
                                          _buildQuickActionCard(
                                            title: 'Lembretes',
                                            subtitle: 'Ver lembretes e alertas',
                                            icon: Icons.notifications_active,
                                            color: const Color(0xFFFED7AA),
                                            iconColor: const Color(0xFFEA580C),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // ✅ SEÇÃO PRÓXIMOS LEMBRETES - OPÇÃO 1 + TIMELINE
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
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
                                  children: [
                                    // ✅ Header
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_outlined,
                                          color: const Color(0xFF14B8A6),
                                          size: 28,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Próximos lembretes',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.pets,
                                          color: const Color(
                                            0xFF14B8A6,
                                          ).withOpacity(0.15),
                                          size: 32,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 36),
                                      child: Text(
                                        'Fique por dentro dos próximos cuidados do seu pet.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // ✅ Lista de lembretes com timeline
                                    if (reminderProvider.isLoading)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (lembretesParaMostrar.isEmpty)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.notifications_none,
                                              color: Colors.grey.shade500,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                'Nenhum lembrete próximo encontrado.',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      ...List.generate(
                                        lembretesParaMostrar.length,
                                        (index) {
                                          final lembrete =
                                              lembretesParaMostrar[index];

                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  index ==
                                                      lembretesParaMostrar
                                                              .length -
                                                          1
                                                  ? 0
                                                  : 16,
                                            ),
                                            child: _buildReminderWithTimeline(
                                              icon: _iconePorTipo(
                                                lembrete.tipo,
                                              ),
                                              iconBg: _corFundoPorTipo(
                                                lembrete.tipo,
                                              ),
                                              iconColor: _corPorTipo(
                                                lembrete.tipo,
                                              ),
                                              title: lembrete.titulo,
                                              pet: _nomePetPorId(
                                                lembrete.idPet,
                                              ),
                                              badge: _formatarTipo(
                                                lembrete.tipo,
                                              ),
                                              badgeColor: _corFundoPorTipo(
                                                lembrete.tipo,
                                              ),
                                              badgeTextColor: _corPorTipo(
                                                lembrete.tipo,
                                              ),
                                              date: _formatarDataLembrete(
                                                lembrete.dataHora,
                                              ),
                                              time: _formatarHoraLembrete(
                                                lembrete.dataHora,
                                              ),
                                              isFirst: index == 0,
                                            ),
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 16),

                                    Container(
                                      width: double.infinity,
                                      height: 50, // ✅ Altura fixa maior
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            print('Ver todos os lembretes');
                                          },
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          splashColor: const Color(
                                            0xFF0D9488,
                                          ).withOpacity(0.1),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.list_alt_outlined,
                                                color: const Color(0xFF0D9488),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Ver todos os lembretes',
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
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ HEADER FIXO (por cima de tudo, com sombra)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: 15,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        user?.nome?.substring(0, 2).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nome ?? 'Usuário',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    offset: const Offset(0, 40),
                    onSelected: (value) {
                      if (value == 'logout') {
                        _logout(context, authProvider);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Sair da conta'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 0 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 1 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: _selectedIndex == 2 ? 3 : 0,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3),
                      ),
                    ),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF0D9488),
              unselectedItemColor: Colors.grey,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'Início',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined),
                  label: 'Agenda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider authProvider) async {
    await authProvider.logout();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildAddPetCard() {
    return Container(
      width: 150,
      child: CustomPaint(
        foregroundPainter: DashedBorderPainter(
          // ✅ TROQUE AQUI
          color: const Color(0xFF0D9488),
          strokeWidth: 2.5,
          dashLength: 8,
          gapLength: 6,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const PetFormDialog(),
                );

                if (result == true) {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  await Provider.of<PetProvider>(
                    context,
                    listen: false,
                  ).carregarPets(auth.currentUser!.id);
                }
              },
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0D9488),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF0D9488),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Adicionar\nnovo pet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard({required dynamic pet, required String age}) {
    String especieFormatada;
    switch (pet.especie.toLowerCase()) {
      case 'cao':
        especieFormatada = 'Cão';
        break;
      case 'gato':
        especieFormatada = 'Gato';
        break;
      default:
        especieFormatada = pet.especie;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final atualizou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => PetDetailsScreen(pet: pet)),
          );

          if (atualizou == true) {
            final auth = Provider.of<AuthProvider>(context, listen: false);
            final petProvider = Provider.of<PetProvider>(context,listen: false,);

              final reminderProvider = Provider.of<ReminderProvider>(context,listen: false,);

              await petProvider.carregarPets(auth.currentUser!.id);

              await reminderProvider.carregarOcorrenciasDosPets(
                petProvider.pets,
              );
          }
        },
        borderRadius: BorderRadius.circular(16),
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Builder(
              builder: (context) {
                return GestureDetector(
                  onPanDown: (_) {},
                  child: HoverBuilder(
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
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.grey.shade100,
                                    backgroundImage:
                                        pet.urlFoto != null &&
                                            pet.urlFoto.isNotEmpty
                                        ? NetworkImage(pet.urlFoto!)
                                        : null,
                                    child:
                                        (pet.urlFoto == null ||
                                            pet.urlFoto.isEmpty)
                                        ? Icon(
                                            Icons.pets,
                                            size: 50,
                                            color: Colors.grey.shade400,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF0D9488),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                pet.nome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                especieFormatada,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    age,
                                    style: const TextStyle(
                                      color: Color(0xFF059669),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: HoverBuilder(
        builder: (context, isHovered) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered
                  ? Color.lerp(
                      color,
                      Colors.black,
                      0.05,
                    )! // ✅ Escurece 5% no hover
                  : color,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? iconColor.withOpacity(0.25)
                      : iconColor.withOpacity(0.1),
                  blurRadius: isHovered ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(16),
                splashColor: iconColor.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Row(
                  children: [
                    // ✅ Ícone maior em círculo colorido sólido
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    // ✅ Texto
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: iconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: iconColor.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    // ✅ Seta em círculo branco com arrow_forward
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: iconColor,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderWithTimeline({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String pet,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String date,
    required String time,
    required bool isFirst,
  }) {
    return HoverBuilder(
      builder: (context, isHovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Timeline (linha + bolinha)
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    // Bolinha
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: iconColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ✅ Card do lembrete com hover e clique
              Expanded(
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      print('Clicou no lembrete: $title');
                      // Aqui você pode navegar para a tela de detalhes
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isHovered ? Colors.grey.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isHovered
                              ? iconColor.withOpacity(0.3)
                              : Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isHovered
                                ? iconColor.withOpacity(0.1)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: isHovered ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ícone
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: iconColor, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Texto
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pets,
                                      color: iconColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      pet,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: badgeTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Data/Hora
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Seta
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isHovered ? iconColor : iconBg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chevron_right,
                              color: isHovered ? Colors.white : iconColor,
                              size: 18,
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
        );
      },
    );
  }
}

String calcularIdade(String? dataNascimento) {
  if (dataNascimento == null || dataNascimento.isEmpty) {
    return 'Sem idade';
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
  // Caso venha data no formato ISO: 2024-05-20 ou 2024-05-20T00:00:00.000Z
  else if (RegExp(r'^\d{4}-\d{1,2}-\d{1,2}').hasMatch(data)) {
    final match = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(data);

    if (match == null) {
      return 'Data inválida';
    }

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

  if (nascimento == null) {
    return 'Data inválida';
  }

  final hoje = DateTime.now();

  if (nascimento.isAfter(hoje)) {
    return 'Data inválida';
  }

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

  // Se tiver 1 ano ou mais, mostra apenas anos e meses
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
    if (temDia) {
      return 'Menos de 1 dia';
    }

    if (temMes) {
      return 'Menos de 1 mês';
    }

    return 'Menos de 1 ano';
  }

  return partesIdade.join(' e ');
}
