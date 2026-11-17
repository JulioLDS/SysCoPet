import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_form_dialog.dart';
import 'reminder_details_screen.dart';

class PetAllRemindersScreen extends StatefulWidget {
  final PetModel pet;

  const PetAllRemindersScreen({super.key, required this.pet});

  @override
  State<PetAllRemindersScreen> createState() => _PetAllRemindersScreenState();
}

class _PetAllRemindersScreenState extends State<PetAllRemindersScreen> {
  // ✅ Paleta laranja/amarelo suave (consistente com o card de Lembretes)
  static const Color _corPrincipal = Color(0xFFF59E0B);
  static const Color _corFundoClaro = Color(0xFFFEF3C7);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ReminderProvider>(
        context,
        listen: false,
      ).carregarOcorrenciasDoPet(widget.pet.idPet!);
    });
  }

  DateTime? _getProximaData(ReminderOccurrenceModel lembrete) {
    final agora = DateTime.now();
    if (lembrete.dataHora.isAfter(agora)) return lembrete.dataHora;
    for (final data in lembrete.proximasOcorrencias) {
      if (data.isAfter(agora)) return data;
    }
    return null;
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
        return Icons.notifications_active;
    }
  }

  Color _getColorByType(String tipo) {
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

  Color _getBgColorByType(String tipo) {
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

  // ✅ Concluir (sem função, apenas visual)
  void _concluirLembrete(ReminderOccurrenceModel lembrete) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Função em desenvolvimento'),
        backgroundColor: Color(0xFF059669),
      ),
    );
  }

  // ✅ Excluir com dialog padronizado
  Future<void> _excluirLembrete(ReminderOccurrenceModel lembrete) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogExcluirLembrete(titulo: lembrete.titulo),
    );

    if (confirmou == true && mounted) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deletarLembrete(lembrete.id, lembrete.idPet);
      if (!mounted) return;
      await provider.carregarOcorrenciasDoPet(widget.pet.idPet!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lembrete excluído!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final agora = DateTime.now();

    final todosLembretes = reminderProvider.ocorrenciasPet
        .where((r) => r.idPet == widget.pet.idPet && r.ativo)
        .toList();

    // Separar em futuros e passados/concluídos
    final futuros =
        todosLembretes.where((r) {
            final data = _getProximaData(r);
            return data != null && data.isAfter(agora);
          }).toList()
          ..sort((a, b) => _getProximaData(a)!.compareTo(_getProximaData(b)!));

    final passados =
        todosLembretes.where((r) {
            final data = _getProximaData(r);
            return data == null || !data.isAfter(agora);
          }).toList()
          ..sort((a, b) => _getProximaData(b)!.compareTo(_getProximaData(a)!));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Lembretes de ${widget.pet.nome}'),
        backgroundColor: _corPrincipal,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reminderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todosLembretes.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (futuros.isNotEmpty) ...[
                        _buildSectionTitle(
                          'Próximos Lembretes',
                          Icons.upcoming,
                        ),
                        const SizedBox(height: 12),
                        ...futuros.map(
                          (lembrete) =>
                              _buildLembreteCard(lembrete, isFuture: true),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (passados.isNotEmpty) ...[
                        _buildSectionTitle(
                          'Histórico de Lembretes',
                          Icons.history,
                        ),
                        const SizedBox(height: 12),
                        ...passados.map(
                          (lembrete) =>
                              _buildLembreteCard(lembrete, isFuture: false),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final resultado = await showDialog<bool>(
            context: context,
            builder: (_) => ReminderFormDialog(idPet: widget.pet.idPet!),
          );
          if (resultado == true && mounted) {
            await Provider.of<ReminderProvider>(
              context,
              listen: false,
            ).carregarOcorrenciasDoPet(widget.pet.idPet!);
          }
        },
        backgroundColor: _corPrincipal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Lembrete',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _corPrincipal, size: 22),
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

  Widget _buildLembreteCard(
    ReminderOccurrenceModel lembrete, {
    required bool isFuture,
  }) {
    final data = _getProximaData(lembrete) ?? lembrete.dataHora;
    final corTipo = _getColorByType(lembrete.tipo);
    final corFundoTipo = _getBgColorByType(lembrete.tipo);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corFundoTipo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconByType(lembrete.tipo),
                  color: corTipo,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lembrete.titulo,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isFuture
                            ? const Color(0xFF1E293B)
                            : Colors.grey.shade700,
                        decoration: isFuture
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Badge do tipo
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: corFundoTipo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatarTipo(lembrete.tipo),
                            style: TextStyle(
                              fontSize: 11,
                              color: corTipo,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatarData(data),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ Ações apenas para lembretes futuros
          if (isFuture) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botão Concluir (visual normal, sem função)
                Material(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _concluirLembrete(lembrete),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Color(0xFF059669),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Concluir',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão Excluir
                Material(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _excluirLembrete(lembrete),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_outline,
                            color: Color(0xFFEF4444),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Excluir',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 12,
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
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: _corFundoClaro,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active,
                color: _corPrincipal,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhum lembrete registrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie lembretes para manter a rotina do seu pet sempre em dia.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
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
    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }
}

// ✅ Dialog padronizado para exclusão
class _DialogExcluirLembrete extends StatelessWidget {
  final String titulo;

  const _DialogExcluirLembrete({required this.titulo});

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
