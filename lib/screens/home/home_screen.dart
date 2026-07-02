import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/pet_provider.dart';
import '../pets/pet_form_dialog.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_screen.dart';
import '../pets/pet_edit_dialog.dart';
import '../pets/pet_details_screen.dart';

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

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);

      await petProvider.carregarPets(auth.currentUser!.id);
      print("Pets carregados: ${petProvider.pets.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. HEADER FIXO
          Container(
            color: const Color(0xFF0D9488),
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

          // 2. CONTEÚDO COM ROLAGEM
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, ${user?.nome?.split(' ').first ?? 'Usuário'}! 👋',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Que bom te ver por aqui! Veja como estão os cuidados dos seus pets hoje.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Meus Pets',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildAddPetCard(),
                        const SizedBox(width: 15),
                        ...petProvider.pets.map(
                          (pet) => Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: _buildPetCard(
                              pet: pet,
                              age: calcularIdade(pet.dataNascimento),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Ações rápidas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionCard(
                        title: 'Vacinas',
                        subtitle: 'Ver e agendar',
                        icon: Icons.vaccines_outlined,
                        color: const Color(0xFFD1FAE5),
                        iconColor: const Color(0xFF059669),
                      ),
                      _buildQuickActionCard(
                        title: 'Consultas',
                        subtitle: 'Agendar visita',
                        icon: Icons.calendar_month_outlined,
                        color: const Color(0xFFDBEAFE),
                        iconColor: const Color(0xFF2563EB),
                      ),
                      _buildQuickActionCard(
                        title: 'Lembretes',
                        subtitle: 'Ver lembretes',
                        icon: Icons.notifications_outlined,
                        color: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Próximos lembretes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildReminderItem(
                          icon: Icons.vaccines_outlined,
                          iconBg: const Color(0xFFD1FAE5),
                          iconColor: const Color(0xFF059669),
                          title: 'Vacina V8',
                          pet: 'Mel',
                          date: '24/05/2025',
                          time: 'Sábado, 10:00',
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        _buildReminderItem(
                          icon: Icons.calendar_today_outlined,
                          iconBg: const Color(0xFFDBEAFE),
                          iconColor: const Color(0xFF2563EB),
                          title: 'Consulta veterinária',
                          pet: 'Luna',
                          date: '02/06/2025',
                          time: 'Segunda, 14:30',
                        ),
                        Divider(height: 1, color: Colors.grey[200]),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.list_alt_outlined,
                            color: Color(0xFF0D9488),
                          ),
                          label: const Text(
                            'Ver todos os lembretes',
                            style: TextStyle(
                              color: Color(0xFF0D9488),
                              fontWeight: FontWeight.w600,
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
            await Provider.of<PetProvider>(
              context,
              listen: false,
            ).carregarPets(auth.currentUser!.id);
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
              borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(16),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  age,
                                  style: const TextStyle(
                                    color: Color(0xFF059669),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
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
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: iconColor.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String pet,
    required String date,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  pet,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
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
