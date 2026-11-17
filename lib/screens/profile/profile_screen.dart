import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syscopet/screens/home/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/common/user_avatar.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../settings/account_screen.dart';
import '../settings/notifications_screen.dart';
import '../settings/privacy_screen.dart';
import '../settings/help_screen.dart';
import '../settings/about_screen.dart';
import '../pets/my_pets_screen.dart';
import '../pets/reminders_all_screen.dart';
import '../agenda/agenda_screen.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _touchedIndex = -1;

  // ============ HELPERS DE DADOS ============

  DateTime? _getProximaData(ReminderOccurrenceModel lembrete) {
    final agora = DateTime.now();
    if (lembrete.dataHora.isAfter(agora)) return lembrete.dataHora;
    for (final data in lembrete.proximasOcorrencias) {
      if (data.isAfter(agora)) return data;
    }
    return null;
  }

  String _nomePetPorId(int idPet) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets.where((p) => p.idPet == idPet);
    return pet.isEmpty ? 'Pet' : pet.first.nome;
  }

  int _lembretesPorPet(int idPet) {
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    return reminderProvider.ocorrencias
        .where((l) => l.idPet == idPet && l.ativo)
        .length;
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

  String _formatarDataCurta(DateTime data) {
    const meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${data.day} de ${meses[data.month - 1]}';
  }

  Widget _badgeRelativo(DateTime data) {
    final hoje = DateTime.now();
    final apenasData = DateTime(data.year, data.month, data.day);
    final hojeData = DateTime(hoje.year, hoje.month, hoje.day);
    final diff = apenasData.difference(hojeData).inDays;

    String texto;
    Color cor;
    if (diff == 0) {
      texto = 'Hoje';
      cor = const Color(0xFF0D9488);
    } else if (diff == 1) {
      texto = 'Amanhã';
      cor = const Color(0xFF3B82F6);
    } else if (diff <= 7) {
      texto = 'Em $diff dias';
      cor = const Color(0xFFA855F7);
    } else {
      texto = _formatarDataCurta(data);
      cor = Colors.grey.shade600;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  ReminderOccurrenceModel? _proximoLembrete(
    List<ReminderOccurrenceModel> ocorrencias,
  ) {
    final futuros =
        ocorrencias.where((l) => l.ativo && _getProximaData(l) != null).toList()
          ..sort((a, b) => _getProximaData(a)!.compareTo(_getProximaData(b)!));
    return futuros.isEmpty ? null : futuros.first;
  }

  List<ReminderOccurrenceModel> _lembretesDoMes(
    List<ReminderOccurrenceModel> ocorrencias,
  ) {
    final agora = DateTime.now();
    final doMes =
        ocorrencias.where((l) {
            final d = _getProximaData(l);
            return d != null && d.year == agora.year && d.month == agora.month;
          }).toList()
          ..sort((a, b) => _getProximaData(a)!.compareTo(_getProximaData(b)!));
    return doMes;
  }

  Map<String, _TipoLembrete> _calcularDistribuicao(
    List<ReminderOccurrenceModel> ocorrencias,
  ) {
    final contagem = <String, int>{
      'vacina': 0,
      'alimentacao': 0,
      'banho': 0,
      'consulta': 0,
    };
    for (final l in ocorrencias) {
      if (contagem.containsKey(l.tipo)) {
        contagem[l.tipo] = (contagem[l.tipo] ?? 0) + 1;
      }
    }
    final total = contagem.values.fold(0, (s, c) => s + c);
    final ordem = ['vacina', 'alimentacao', 'banho', 'consulta'];
    final labels = {
      'vacina': 'Vacinas',
      'alimentacao': 'Alimentação',
      'banho': 'Banho',
      'consulta': 'Consultas',
    };
    final cores = {
      'vacina': const Color(0xFF0D9488),
      'alimentacao': const Color(0xFFF59E0B),
      'banho': const Color(0xFF3B82F6),
      'consulta': const Color(0xFFA855F7),
    };

    final resultado = <String, _TipoLembrete>{};
    for (final tipo in ordem) {
      final pct = total == 0
          ? 0
          : ((contagem[tipo] ?? 0) / total * 100).round();
      resultado[tipo] = _TipoLembrete(labels[tipo]!, pct, cores[tipo]!);
    }
    return resultado;
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, _TipoLembrete> dist,
  ) {
    final keys = dist.keys.toList();
    return dist.entries.map((e) {
      final isTouched = _touchedIndex == keys.indexOf(e.key);
      return PieChartSectionData(
        color: e.value.color,
        value: e.value.percentage.toDouble(),
        title: isTouched ? '${e.value.percentage}%' : '',
        radius: isTouched ? 42 : 34, // ✅ fatias menores
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final petProvider = context.watch<PetProvider>();
    final reminderProvider = context.watch<ReminderProvider>();

    final ocorrencias = reminderProvider.ocorrencias;
    final totalPets = petProvider.pets.length;
    final lembretesAtivos = ocorrencias.where((l) => l.ativo).length;
    final dist = _calcularDistribuicao(ocorrencias);
    final totalDist = dist.values.fold(0, (s, v) => s + v.percentage);
    final proximo = _proximoLembrete(ocorrencias);
    final doMes = _lembretesDoMes(ocorrencias);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [_buildSettingsMenu(), const SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              children: [
                // ===== LINHA 1: Usuário + Destaque =====
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 2, child: _cardUsuario(user)),
                      const SizedBox(width: 20),
                      Expanded(flex: 1, child: _cardCuidando()),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== LINHA 2: 4 Métricas =====
                Row(
                  children: [
                    Expanded(
                      child: _metricCard(
                        icon: Icons.pets,
                        value: '$totalPets',
                        label: 'Total de Pets',
                        bg: const Color(0xFFECFDF5),
                        fg: const Color(0xFF0D9488),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MeusPetsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _metricCard(
                        icon: Icons.notifications_active,
                        value: '$lembretesAtivos',
                        label: 'Lembretes Ativos',
                        bg: const Color(0xFFFEF3C7),
                        fg: const Color(0xFFF59E0B),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllRemindersScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _metricCard(
                        icon: Icons.check_circle,
                        value: '92%',
                        label: 'Taxa de Conclusão',
                        bg: const Color(0xFFD1FAE5),
                        fg: const Color(0xFF059669),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: _proximoLembreteCard(proximo)),
                  ],
                ),
                const SizedBox(height: 20),

                // ===== LINHA 3: Donut + Barras + Pets (mesma altura) =====
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _cardDonut(dist, totalDist)),
                      const SizedBox(width: 20),
                      Expanded(child: _cardBarras()),
                      const SizedBox(width: 20),
                      Expanded(child: _cardPets(petProvider.pets)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ===== LINHA 4: Lembretes do mês + Destaque =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _cardLembretesMes(doMes)),
                    const SizedBox(width: 20),
                    Expanded(flex: 1, child: _cardBemCuidado()),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============ WIDGETS ============

  Widget _cardUsuario(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              UserAvatar(
                user: user,
                radius: 48,
                fontSize: 26,
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.nome ?? 'Usuário',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _pillButton(
            icon: Icons.edit,
            label: 'Editar perfil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCuidando() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Color(0xFF0D9488), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Cuidando de quem\nvocê ama!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
                height: 1.3,
              ),
            ),
          ),
          _ilustracaoCachorro(),
        ],
      ),
    );
  }

  Widget _proximoLembreteCard(ReminderOccurrenceModel? lembrete) {
    final proxima = lembrete != null ? _getProximaData(lembrete) : null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              lembrete != null
                  ? _iconePorTipo(lembrete.tipo)
                  : Icons.calendar_today,
              color: const Color(0xFF0D9488),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Próximo lembrete',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  lembrete != null
                      ? '${_formatarTipo(lembrete.tipo)} • ${_nomePetPorId(lembrete.idPet)}'
                      : 'Nenhum agendado',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (proxima != null)
                  Text(
                    proxima.day == DateTime.now().day &&
                            proxima.month == DateTime.now().month
                        ? 'Hoje, ${_formatarDataCurta(proxima)}'
                        : _formatarDataCurta(proxima),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF0D9488)),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color bg,
    required Color fg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _cardShadow(),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: fg,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF0D9488)),
          ],
        ),
      ),
    );
  }

  Widget _cardDonut(Map<String, _TipoLembrete> dist, int total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.pie_chart, 'Distribuição de Cuidados'),
          const SizedBox(height: 16),
          Row(
            children: [
              // ✅ Donut compacto
              SizedBox(
                width: 110,
                height: 110,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (e, r) {
                            setState(() {
                              if (!e.isInterestedForInteractions ||
                                  r?.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex =
                                  r!.touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30, // ✅ menor
                        sections: _buildPieChartSections(dist),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // ✅ Legenda com underline entre cada item
              Expanded(
                child: Column(
                  children: dist.entries
                      .map(
                        (e) => Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: e.value.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.value.label,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '${e.value.percentage}%',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 30, thickness: 1),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cardBarras() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.bar_chart, 'Engajamento Mensal'),
          const SizedBox(height: 16),
          // ✅ Altura fixa para o gráfico
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 15,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF0D9488),
                    getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                      '${rod.toY.round()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const meses = ['Mai', 'Jun', 'Jul', 'Ago'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            meses[v.toInt()],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, m) => Text(
                        '${v.toInt()}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _barGroup(0, 8),
                  _barGroup(1, 11),
                  _barGroup(2, 13),
                  _barGroup(3, 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF0D9488),
          width: 28,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 15,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  Widget _cardPets(List<dynamic> pets) {
    return Container(
      padding: const EdgeInsets.all(14), // ✅ de 20 para 14
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pets,
                color: Color(0xFF0D9488),
                size: 20,
              ), // ✅ de 22 para 20
              const SizedBox(width: 6), // ✅ de 8 para 6
              const Expanded(
                child: Text(
                  'Seus Pets',
                  style: TextStyle(
                    fontSize: 15, // ✅ de 16 para 15
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              _pillButton(
                icon: Icons.visibility,
                label: 'Ver todos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeusPetsScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4), // ✅ de 8 para 4
          if (pets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Nenhum pet cadastrado.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: pets.map((pet) => _petRow(pet)).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _petRow(dynamic pet) {
    final qtd = _lembretesPorPet(pet.idPet);
    return Column(
      children: [
        InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgendaScreen()),
          ),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6), // ✅ de 10 para 6
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18, // ✅ de 22 para 18
                  backgroundColor: const Color(0xFFECFDF5),
                  backgroundImage:
                      pet.urlFoto != null && pet.urlFoto!.isNotEmpty
                      ? NetworkImage(pet.urlFoto!)
                      : null,
                  child: pet.urlFoto == null || pet.urlFoto!.isEmpty
                      ? const Icon(
                          Icons.pets,
                          color: Color(0xFF0D9488),
                          size: 16,
                        ) // ✅ de 18 para 16
                      : null,
                ),
                const SizedBox(width: 10), // ✅ de 12 para 10
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13, // ✅ de padrão para 13
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        calcularIdade(pet.dataNascimento),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ), // ✅ de 12 para 11
                      ),
                    ],
                  ),
                ),
                Text(
                  '$qtd lembretes',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ), // ✅ de 12 para 11
                ),
                const SizedBox(width: 4), // ✅ de 6 para 4
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 16,
                ), // ✅ de 20 para 16
              ],
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _cardLembretesMes(List<ReminderOccurrenceModel> doMes) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF0D9488),
                size: 22,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lembretes deste mês',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              _pillButton(
                icon: Icons.calendar_month,
                label: 'Ver agenda',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AgendaScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (doMes.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Nenhum lembrete neste mês.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
          else
            ...doMes.map((l) => _lembreteMesRow(l)),
        ],
      ),
    );
  }

  Widget _lembreteMesRow(ReminderOccurrenceModel lembrete) {
    final proxima = _getProximaData(lembrete)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _corFundoPorTipo(lembrete.tipo),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconePorTipo(lembrete.tipo),
                  color: _corPorTipo(lembrete.tipo),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  '${_formatarTipo(lembrete.tipo)} – ${_nomePetPorId(lembrete.idPet)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  _formatarDataCurta(proxima),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 80, child: _badgeRelativo(proxima)),
              const SizedBox(width: 8),
              _pillButton(
                icon: Icons.check,
                label: 'Marcar como concluído',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funcionalidade em desenvolvimento'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              _pillButton(
                icon: Icons.delete_outline,
                label: 'Excluir',
                bg: const Color(0xFFFEF2F2),
                fg: const Color(0xFFEF4444),
                onTap: () => _excluirLembrete(lembrete),
              ),
            ],
          ),
        ),
        const Divider(height: 1), // ✅ underline entre lembretes
      ],
    );
  }

  Widget _cardBemCuidado() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.favorite, color: Color(0xFF0D9488), size: 26),
                const SizedBox(height: 8),
                const Text(
                  'Seu pet sempre bem cuidado!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continue organizando os lembretes e mantenha a saúde do seu pet em dia.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _ilustracaoCachorro(),
        ],
      ),
    );
  }

  Widget _ilustracaoCachorro() {
    return Image.asset(
      'assets/images/dog_care.png',
      width: 70,
      height: 70,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.pets, color: Color(0xFF0D9488), size: 36),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color bg = const Color(0xFFECFDF5),
    Color fg = const Color(0xFF0D9488),
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fg, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D9488), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: _cardShadow(),
    );
  }

  List<BoxShadow> _cardShadow() {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  // ✅ Menu de configurações idêntico ao da Home
  Widget _buildSettingsMenu() {
    return PopupMenuButton<String>(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.settings_outlined,
          color: Color(0xFF0D9488),
          size: 24,
        ),
      ),
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          enabled: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'GERAL',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        PopupMenuItem<String>(
          value: 'minha_conta',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Minha conta',
          ),
        ),
        PopupMenuItem<String>(
          value: 'notificacoes',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
          ),
        ),
        PopupMenuItem<String>(
          value: 'privacidade',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(
            icon: Icons.shield_outlined,
            title: 'Privacidade',
          ),
        ),
        PopupMenuItem<String>(
          value: 'ajuda',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(icon: Icons.help_outline, title: 'Ajuda'),
        ),
        PopupMenuItem<String>(
          value: 'sobre',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(icon: Icons.info_outline, title: 'Sobre o app'),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          padding: EdgeInsets.zero,
          child: _buildMenuItem(
            icon: Icons.logout,
            title: 'Sair da conta',
            isDanger: true,
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'minha_conta':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            );
            break;
          case 'notificacoes':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            break;
          case 'privacidade':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            );
            break;
          case 'ajuda':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HelpScreen()),
            );
            break;
          case 'sobre':
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
            break;
          case 'logout':
            showDialog<bool>(
              context: context,
              builder: (_) => const LogoutConfirmationDialog(),
            ).then((confirmou) {
              if (confirmou == true && context.mounted) _logout();
            });
            break;
        }
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isDanger = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDanger
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isDanger
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF0D9488),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDanger
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  Future<void> _excluirLembrete(ReminderOccurrenceModel lembrete) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir lembrete'),
        content: Text('Deseja excluir "${lembrete.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou == true) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deletarLembrete(lembrete.id, lembrete.idPet);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lembrete excluído!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _TipoLembrete {
  final String label;
  final int percentage;
  final Color color;
  _TipoLembrete(this.label, this.percentage, this.color);
}

// ✅ Dialog padronizado (mesmo padrão visual do app)
class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Sair da conta',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFFEF4444),
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tem certeza que deseja sair?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Você precisará fazer login novamente para acessar sua conta.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Sair',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
