import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_details_screen.dart';

class AllRemindersScreen extends StatefulWidget {
  const AllRemindersScreen({super.key});

  @override
  State<AllRemindersScreen> createState() => _AllRemindersScreenState();
}

class _AllRemindersScreenState extends State<AllRemindersScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _carregarLembretes();
    });
  }

  Future<void> _carregarLembretes() async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    await reminderProvider.carregarOcorrenciasDosPets(petProvider.pets);
  }

  DateTime? _getProximaData(ReminderOccurrenceModel lembrete) {
    final agora = DateTime.now();

    if (lembrete.dataHora.isAfter(agora)) {
      return lembrete.dataHora;
    }

    for (final data in lembrete.proximasOcorrencias) {
      if (data.isAfter(agora)) {
        return data;
      }
    }

    return null;
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
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

  IconData _getIconByType(String tipo) {
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
        return Icons.notifications;
    }
  }

  String _buscarNomePet(int idPet, List<PetModel> pets) {
    try {
      final pet = pets.firstWhere((pet) => pet.idPet == idPet);

      return pet.nome;
    } catch (_) {
      return 'Pet';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    final petProvider = Provider.of<PetProvider>(context);

    final lembretes =
        reminderProvider.ocorrencias
            .where(
              (lembrete) => lembrete.ativo && _getProximaData(lembrete) != null,
            )
            .toList()
          ..sort((a, b) {
            final dataA = _getProximaData(a)!;
            final dataB = _getProximaData(b)!;

            return dataA.compareTo(dataB);
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ✅ HEADER COM GRADIENTE (padronizado com ReminderDetailsScreen)
      body: CustomScrollView(
        slivers: [
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
                    // Título
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Todos os lembretes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gerencie todos os seus lembretes',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ CONTEÚDO (lista de lembretes)
          SliverToBoxAdapter(
            child: reminderProvider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : lembretes.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Nenhum lembrete próximo.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true, // ✅ Necessário dentro do CustomScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // ✅ Desabilita scroll interno
                    padding: const EdgeInsets.all(20),
                    itemCount: lembretes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lembrete = lembretes[index];

                      final proximaData = _getProximaData(lembrete)!;

                      final nomePet = _buscarNomePet(
                        lembrete.idPet,
                        petProvider.pets,
                      );

                      return _buildReminderCard(
                        lembrete: lembrete,
                        proximaData: proximaData,
                        nomePet: nomePet,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required ReminderOccurrenceModel lembrete,
    required DateTime proximaData,
    required String nomePet,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () async {
          final atualizou = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => ReminderDetailsScreen(
                idLembrete: lembrete.id,
                idPet: lembrete.idPet,
              ),
            ),
          );

          if (atualizou == true) {
            await _carregarLembretes();
          }
        },

        child: Container(
          padding: const EdgeInsets.all(18),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),

          child: Row(
            children: [
              Container(
                width: 75,
                height: 75,

                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: Icon(
                  _getIconByType(lembrete.tipo),
                  color: const Color(0xFF0D9488),
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      lembrete.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      nomePet,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildBadge(_formatarTipo(lembrete.tipo)),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatarData(proximaData),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatarHora(proximaData),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFF0D9488), // ✅ Mudado de Colors.grey para teal
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Color(0xFF059669),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ✅ Widget para botão com hover (padronizado com PetDetailsScreen)
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
