import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_details_screen.dart';

class AllRemindersScreen extends StatefulWidget {
  const AllRemindersScreen({
    super.key,
  });

  @override
  State<AllRemindersScreen> createState() =>
      _AllRemindersScreenState();
}

class _AllRemindersScreenState
    extends State<AllRemindersScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await _carregarLembretes();
    });
  }

  Future<void> _carregarLembretes() async {
    final petProvider = Provider.of<PetProvider>(
      context,
      listen: false,
    );

    final reminderProvider =
        Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    await reminderProvider.carregarOcorrenciasDosPets(
      petProvider.pets,
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

PetModel? _buscarPet(
    int idPet,
    List<PetModel> pets,
  ) {
    try {
      return pets.firstWhere(
        (pet) => pet.idPet == idPet,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider =
        Provider.of<ReminderProvider>(context);

    final petProvider =
        Provider.of<PetProvider>(context);

    final lembretes =
        reminderProvider.ocorrencias
            .where(
              (lembrete) =>
                  lembrete.ativo &&
                  _getProximaData(lembrete) != null,
            )
            .toList()
          ..sort((a, b) {
            final dataA = _getProximaData(a)!;
            final dataB = _getProximaData(b)!;

            return dataA.compareTo(dataB);
          });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text(
          'Todos os lembretes',
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),

      body: reminderProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : lembretes.isEmpty
              ? const Center(
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
                        style: TextStyle(
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
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lembrete =
                          lembretes[index];

                      final proximaData =
                          _getProximaData(
                        lembrete,
                      )!;

                      final pet =
                          _buscarPet(
                        lembrete.idPet,
                        petProvider.pets,
                      );

                      return _buildReminderCard(
                        lembrete: lembrete,
                        proximaData: proximaData,
                        pet: pet,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildReminderCard({
    required ReminderOccurrenceModel lembrete,
    required DateTime proximaData,
    required PetModel? pet,
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
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),

          child: Row(
            children: [
              Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: ClipOval(
                    child: pet?.urlFoto != null &&
                            pet!.urlFoto!.isNotEmpty
                        ? Image.network(
                            pet.urlFoto!,
                            width: 52,
                            height: 52,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return _buildPetFallback(
                                lembrete.tipo,
                              );
                            },
                          )
                        : _buildPetFallback(
                            lembrete.tipo,
                          ),
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
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      pet?.nome ?? 'Pet',
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
                        _buildBadge(
                          _formatarTipo(
                            lembrete.tipo,
                          ),
                        ),

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
                              _formatarData(
                                proximaData,
                              ),
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
                              _formatarHora(
                                proximaData,
                              ),
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
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetFallback(
    String tipo,
  ) {
    return Container(
      color: const Color(0xFFECFDF5),
      alignment: Alignment.center,
      child: Icon(
        _getIconByType(tipo),
        color: const Color(0xFF0D9488),
        size: 24,
      ),
    );
  }

  Widget _buildBadge(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
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