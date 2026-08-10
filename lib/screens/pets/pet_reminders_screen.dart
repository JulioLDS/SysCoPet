import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_details_screen.dart';

class PetRemindersScreen extends StatefulWidget {
  final PetModel pet;

  const PetRemindersScreen({
    super.key,
    required this.pet,
  });

  @override
  State<PetRemindersScreen> createState() =>
      _PetRemindersScreenState();
}

class _PetRemindersScreenState
    extends State<PetRemindersScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _carregarLembretes();
    });
  }

  Future<void> _carregarLembretes() async {
    if (widget.pet.idPet == null) return;

    final reminderProvider =
        Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    await reminderProvider.carregarOcorrenciasDoPet(
      widget.pet.idPet!,
    );
  }

  DateTime? _getProximaData(
    ReminderOccurrenceModel lembrete,
  ) {
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

  @override
  Widget build(BuildContext context) {
    final reminderProvider =
        Provider.of<ReminderProvider>(context);

    final lembretes =
        reminderProvider.ocorrenciasPet
            .where(
              (lembrete) =>
                  lembrete.ativo &&
                  _getProximaData(lembrete) != null,
            )
            .toList()
          ..sort((a, b) {
            final dataA =
                _getProximaData(a)!;

            final dataB =
                _getProximaData(b)!;

            return dataA.compareTo(dataB);
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          'Lembretes de ${widget.pet.nome}',
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),

      body: reminderProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : lembretes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.notifications_none,
                        size: 60,
                        color: Colors.grey,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '${widget.pet.nome} não possui lembretes próximos.',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarLembretes,

                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),

                    itemCount: lembretes.length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),

                    itemBuilder:
                        (context, index) {

                      final lembrete =
                          lembretes[index];

                      final proximaData =
                          _getProximaData(
                        lembrete,
                      )!;

                      return _buildReminderCard(
                        lembrete: lembrete,
                        proximaData:
                            proximaData,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildReminderCard({
    required ReminderOccurrenceModel lembrete,
    required DateTime proximaData,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),

      child: InkWell(
        borderRadius: BorderRadius.circular(16),

        onTap: () async {
          final atualizou =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  ReminderDetailsScreen(
                idLembrete:
                    lembrete.id,
                idPet:
                    lembrete.idPet,
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
            borderRadius:
                BorderRadius.circular(16),

            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFECFDF5),
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Icon(
                  _getIconByType(
                    lembrete.tipo,
                  ),
                  color:
                      const Color(0xFF0D9488),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      lembrete.titulo,

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      widget.pet.nome,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 6,

                      children: [
                        _buildBadge(
                          _formatarTipo(
                            lembrete.tipo,
                          ),
                        ),

                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              _formatarData(
                                proximaData,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 4),

                            Text(
                              _formatarHora(
                                proximaData,
                              ),
                              style:
                                  const TextStyle(
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
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(
    String texto,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius:
            BorderRadius.circular(12),
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