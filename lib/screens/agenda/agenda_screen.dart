import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/pet_provider.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../models/pet_model.dart';
import '../pets/reminder_form_dialog.dart';
import '../pets/reminders_all_screen.dart';
import '../../widgets/reminders/complete_reminder_action.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key, this.onVoltar});

  // Na Home a agenda é uma aba, não uma rota separada.
  final VoidCallback? onVoltar;

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _mesAtual = DateTime.now();
  DateTime? _diaSelecionado;
  bool _carregando = true;
  bool _abrindoFormulario = false;

  // ✅ Chaves globais para cada dia (permite calcular posição na tela)
  final Map<String, GlobalKey> _diaKeys = {};

  // ✅ Overlay entry para o popover (fica acima de TUDO)
  OverlayEntry? _popoverOverlay;

  static const double _cellWidth = 44;
  static const double _cellHeight = 48;

  @override
  void initState() {
    super.initState();
    _diaSelecionado = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _carregarDados();
    });
  }

  @override
  void dispose() {
    _removerPopover();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    if (auth.currentUser != null) {
      if (petProvider.pets.isEmpty) {
        await petProvider.carregarPets(auth.currentUser!.id);
      }
      await reminderProvider.carregarOcorrenciasDosPets(petProvider.pets);
    }

    if (mounted) setState(() => _carregando = false);
  }

  String _nomePetPorId(int idPet) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final petEncontrado = petProvider.pets.where((pet) => pet.idPet == idPet);
    if (petEncontrado.isEmpty) return 'Pet';
    return petEncontrado.first.nome;
  }

  void _voltar() {
    _removerPopover();
    if (widget.onVoltar != null) {
      widget.onVoltar!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _mesAnterior() {
    _removerPopover();
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1, 1);
    });
  }

  void _proximoMes() {
    _removerPopover();
    setState(() {
      _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1, 1);
    });
  }

  List<ReminderOccurrenceModel> _lembretesDoDia(DateTime dia) {
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    return reminderProvider.ocorrencias.where((lembrete) {
      if (!lembrete.pendente) return false;
      final data = _getProximaData(lembrete);
      if (data == null) return false;
      return data.year == dia.year &&
          data.month == dia.month &&
          data.day == dia.day;
    }).toList();
  }

  DateTime? _getProximaData(ReminderOccurrenceModel lembrete) {
    if (!lembrete.pendente) return null;
    final agora = DateTime.now();
    if (lembrete.dataHora.isAfter(agora)) return lembrete.dataHora;
    for (final data in lembrete.proximasOcorrencias) {
      if (data.isAfter(agora)) return data;
    }
    return null;
  }

  String _formatarData(DateTime data) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    const diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    return '${diasSemana[data.weekday % 7]}, ${data.day} de ${meses[data.month - 1]}';
  }

  String _nomeMes(DateTime data) {
    const meses = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return '${meses[data.month - 1]} de ${data.year}';
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

  // ✅ Remove o popover da overlay
  void _removerPopover() {
    _popoverOverlay?.remove();
    _popoverOverlay = null;
  }

  // ✅ Mostra o popover próximo ao dia clicado, acima de tudo
  void _mostrarPopover(DateTime dia) {
    _removerPopover();

    final key = _diaKeys[_chaveDia(dia)];
    if (key?.currentContext == null) return;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox;
    final posicao = renderBox.localToGlobal(Offset.zero);
    final tamanho = renderBox.size;

    _popoverOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // ✅ Camada transparente que cobre a tela toda e fecha o popover ao clicar
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _removerPopover(),
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
            ),
            // ✅ Popover posicionado próximo ao dia clicado
            Positioned(
              left: (posicao.dx + (tamanho.width / 2) - 110).clamp(
                0.0,
                MediaQuery.of(context).size.width - 240,
              ),
              top: posicao.dy + tamanho.height + 8,
              child: _buildPopover(dia),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_popoverOverlay!);
  }

  String _chaveDia(DateTime dia) => '${dia.year}-${dia.month}-${dia.day}';

  // A escolha do pet fica dentro do próprio formulário da agenda.
  Future<void> _abrirFluxoNovoLembrete() async {
    if (_abrindoFormulario) return;
    _removerPopover();
    final auth = context.read<AuthProvider>();
    final pets = context.read<PetProvider>();
    final user = auth.currentUser;
    if (user == null) return;
    setState(() => _abrindoFormulario = true);
    try {
      await pets.carregarPets(user.id);
      if (!mounted || !identical(auth.currentUser, user)) return;
      final disponiveis = List<PetModel>.unmodifiable(
        pets.pets.where((pet) => pet.idPet != null),
      );
      if (disponiveis.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicione um pet primeiro!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
        return;
      }
      final criou = await showDialog<bool>(
        context: context,
        builder: (_) => ReminderFormDialog(
          petsDisponiveis: disponiveis,
          dataInicial: _diaSelecionado,
        ),
      );
      if (criou == true && mounted && identical(auth.currentUser, user)) {
        await _carregarDados();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível carregar os pets. Tente novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _abrindoFormulario = false);
    }
  }

  List<Widget> _buildListaLembretes(List<ReminderOccurrenceModel> ocorrencias) {
    final ordenados =
        ocorrencias.where((l) => _getProximaData(l) != null).toList()
          ..sort((a, b) => _getProximaData(a)!.compareTo(_getProximaData(b)!));

    return ordenados
        .take(5)
        .map((lembrete) => _buildLembreteCard(lembrete))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final reminderProvider = Provider.of<ReminderProvider>(context);

    const diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

    final primeiroDiaMes = DateTime(_mesAtual.year, _mesAtual.month, 1);
    final ultimoDiaMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0);
    final diasNoMes = ultimoDiaMes.day;
    final diaSemanaInicio = primeiroDiaMes.weekday % 7;

    final diasDoCalendario = <DateTime?>[];
    for (var i = 0; i < diaSemanaInicio; i++) {
      diasDoCalendario.add(null);
    }
    for (var i = 1; i <= diasNoMes; i++) {
      diasDoCalendario.add(DateTime(_mesAtual.year, _mesAtual.month, i));
    }

    final totalSemanas = (diasDoCalendario.length / 7).ceil();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Agenda',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: widget.onVoltar != null || Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Voltar',
                icon: const Icon(Icons.arrow_back),
                onPressed: _voltar,
              )
            : null,
        actions: [
          // ✅ Botão "Hoje" com texto e background
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () {
                  _removerPopover();
                  setState(() {
                    _mesAtual = DateTime(hoje.year, hoje.month, 1);
                    _diaSelecionado = hoje;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.today, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                      const Text(
                        'Hoje',
                        style: TextStyle(
                          color: Colors.white,
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
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ CALENDÁRIO
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left,
                                    size: 28,
                                  ),
                                  onPressed: _mesAnterior,
                                  color: const Color(0xFF0D9488),
                                ),
                                Text(
                                  _nomeMes(_mesAtual),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_right,
                                    size: 28,
                                  ),
                                  onPressed: _proximoMes,
                                  color: const Color(0xFF0D9488),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: diasSemana.map((dia) {
                                return Expanded(
                                  child: Text(
                                    dia,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            // ✅ Grid de dias
                            Column(
                              children: List.generate(totalSemanas, (
                                semanaIndex,
                              ) {
                                final inicio = semanaIndex * 7;
                                final fim = (inicio + 7).clamp(
                                  0,
                                  diasDoCalendario.length,
                                );
                                final diasDaSemana = diasDoCalendario.sublist(
                                  inicio,
                                  fim,
                                );

                                return SizedBox(
                                  height: _cellHeight,
                                  child: Row(
                                    children: diasDaSemana.map((dia) {
                                      if (dia == null) {
                                        return const Expanded(
                                          child: SizedBox(
                                            width: _cellWidth,
                                            height: _cellHeight,
                                          ),
                                        );
                                      }

                                      final chave = _chaveDia(dia);
                                      final ehHoje =
                                          dia.year == hoje.year &&
                                          dia.month == hoje.month &&
                                          dia.day == hoje.day;
                                      final ehSelecionado =
                                          _diaSelecionado != null &&
                                          dia.year == _diaSelecionado!.year &&
                                          dia.month == _diaSelecionado!.month &&
                                          dia.day == _diaSelecionado!.day;
                                      final lembretesDia = _lembretesDoDia(dia);
                                      final temLembrete =
                                          lembretesDia.isNotEmpty;

                                      return Expanded(
                                        child: GestureDetector(
                                          key: _diaKeys.putIfAbsent(
                                            chave,
                                            () => GlobalKey(),
                                          ), // ✅ GlobalKey para cada dia
                                          onTap: () {
                                            setState(() {
                                              _diaSelecionado = dia;
                                            });
                                            if (temLembrete) {
                                              // ✅ Mostra popover próximo ao dia clicado
                                              _mostrarPopover(dia);
                                            } else {
                                              _removerPopover();
                                            }
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: ehSelecionado
                                                  ? const Color(0xFF0D9488)
                                                  : temLembrete
                                                  ? const Color(0xFFECFDF5)
                                                  : ehHoje
                                                  ? const Color(0xFFCCFBF1)
                                                  : Colors.transparent,
                                              border:
                                                  temLembrete && !ehSelecionado
                                                  ? Border.all(
                                                      color: const Color(
                                                        0xFF0D9488,
                                                      ).withOpacity(0.4),
                                                      width: 1.5,
                                                    )
                                                  : null,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${dia.day}',
                                                style: TextStyle(
                                                  color: ehSelecionado
                                                      ? Colors.white
                                                      : temLembrete
                                                      ? const Color(0xFF0D9488)
                                                      : const Color(0xFF1E293B),
                                                  fontWeight:
                                                      ehSelecionado ||
                                                          temLembrete ||
                                                          ehHoje
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(
                                        0xFF0D9488,
                                      ).withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Lembrete',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFCCFBF1),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Hoje',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ✅ PRÓXIMOS LEMBRETES
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF0D9488),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Próximos lembretes',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AllRemindersScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver todos',
                                  style: TextStyle(
                                    color: Color(0xFF0D9488),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.chevron_right,
                                  color: Color(0xFF0D9488),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (reminderProvider.ocorrencias.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_none,
                                color: Colors.grey.shade500,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Nenhum lembrete próximo.',
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
                        ..._buildListaLembretes(reminderProvider.ocorrencias),
                      const SizedBox(height: 16),

                      // ✅ BOTÃO ADICIONAR LEMBRETE
                      SizedBox(
                        width: double.infinity,
                        child: Material(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _abrindoFormulario
                                ? null
                                : _abrirFluxoNovoLembrete,
                            borderRadius: BorderRadius.circular(14),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Color(0xFF0D9488),
                                    size: 22,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Adicionar lembrete',
                                    style: TextStyle(
                                      color: Color(0xFF0D9488),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
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
              ),
            ),
    );
  }

  // ✅ POPOVER: mini-card que aparece sobre o dia clicado
  Widget _buildPopover(DateTime dia) {
    final lembretes = _lembretesDoDia(dia);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF0D9488), size: 16),
                const SizedBox(width: 6),
                Text(
                  'Dia ${dia.day}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                  onPressed: () => _removerPopover(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...lembretes.map((lembrete) {
              final corTipo = _corPorTipo(lembrete.tipo);
              final fundoTipo = _corFundoPorTipo(lembrete.tipo);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: fundoTipo,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _iconePorTipo(lembrete.tipo),
                        color: corTipo,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lembrete.titulo,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _nomePetPorId(lembrete.idPet),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _concluirLembrete(ReminderOccurrenceModel lembrete) async {
    _removerPopover();
    final result = await confirmarConclusaoLembrete(
      context,
      idLembrete: lembrete.id,
      idPet: lembrete.idPet,
      titulo: lembrete.titulo,
      recorrencia: lembrete.recorrencia,
    );
    if (mounted && result != null) setState(() {});
  }

  Widget _buildLembreteCard(ReminderOccurrenceModel lembrete) {
    final concluindo = context.read<ReminderProvider>().estaConcluindo(
      lembrete.id,
    );
    final podeConcluir = lembrete.recorrencia == 'unica' && !concluindo;
    final proximaData = _getProximaData(lembrete)!;
    final corTipo = _corPorTipo(lembrete.tipo);
    final fundoTipo = _corFundoPorTipo(lembrete.tipo);
    final nomePet = _nomePetPorId(lembrete.idPet);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: fundoTipo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_iconePorTipo(lembrete.tipo), color: corTipo, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lembrete.titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.pets, color: corTipo, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      nomePet,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '  •  ',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _formatarData(proximaData),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: lembrete.recorrencia == 'unica'
                ? 'Concluir lembrete'
                : 'Conclusão por ocorrência indisponível',
            child: Material(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: podeConcluir ? () => _concluirLembrete(lembrete) : null,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check,
                        color: podeConcluir
                            ? const Color(0xFF0D9488)
                            : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        concluindo ? 'Concluindo...' : 'Concluir',
                        style: TextStyle(
                          color: podeConcluir
                              ? const Color(0xFF0D9488)
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: concluindo
                ? null
                : () async {
                    final confirmou = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          _DialogExcluirLembreteAgenda(titulo: lembrete.titulo),
                    );
                    if (confirmou == true) {
                      final provider = Provider.of<ReminderProvider>(
                        context,
                        listen: false,
                      );
                      await provider.deletarLembrete(
                        lembrete.id,
                        lembrete.idPet,
                      );
                      await _carregarDados();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lembrete excluído!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}

// ✅ Dialog padronizado para exclusão de lembrete na Agenda
class _DialogExcluirLembreteAgenda extends StatelessWidget {
  final String titulo;

  const _DialogExcluirLembreteAgenda({required this.titulo});

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
              // ✅ Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFEF4444),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Excluir lembrete',
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

              // ✅ Caixa de aviso
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tem certeza que deseja excluir "$titulo"?',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Essa ação não pode ser desfeita e o lembrete será permanentemente removido.',
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

              // ✅ Botões
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
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Excluir',
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
