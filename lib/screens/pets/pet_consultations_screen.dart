import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pet_model.dart';
import '../../models/reminder_ocurrence_model.dart';
import '../../providers/reminder_provider.dart';
import 'reminder_form_dialog.dart';

class PetConsultationsScreen extends StatefulWidget {
  final PetModel pet;

  const PetConsultationsScreen({super.key, required this.pet});

  @override
  State<PetConsultationsScreen> createState() => _PetConsultationsScreenState();
}

class _PetConsultationsScreenState extends State<PetConsultationsScreen> {
  // ✅ Paleta roxa suavizada
  static const Color _corPrincipal = Color(0xFF9F7AEA); // roxo lavanda suave
  static const Color _corFundoClaro = Color(0xFFF3E8FF); // lavanda bem claro
  static const Color _corFundoBadge = Color(0xFFEDE9FE);

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

  // ✅ Excluir consulta com dialog padronizado
  Future<void> _excluirConsulta(ReminderOccurrenceModel consulta) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => _DialogExcluirConsulta(petName: consulta.titulo),
    );

    if (confirmou == true && mounted) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      await provider.deletarLembrete(consulta.id, consulta.idPet);
      if (!mounted) return;
      await provider.carregarOcorrenciasDoPet(widget.pet.idPet!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Consulta excluída!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final agora = DateTime.now();

    final todasConsultas = reminderProvider.ocorrenciasPet
        .where((r) => r.idPet == widget.pet.idPet && r.tipo == 'consulta')
        .toList();

    final futuras =
        todasConsultas.where((r) {
            final data = _getProximaData(r);
            return data != null && data.isAfter(agora);
          }).toList()
          ..sort((a, b) => _getProximaData(a)!.compareTo(_getProximaData(b)!));

    final passadas =
        todasConsultas.where((r) {
            final data = _getProximaData(r);
            return data == null || !data.isAfter(agora);
          }).toList()
          ..sort((a, b) => _getProximaData(b)!.compareTo(_getProximaData(a)!));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Consultas de ${widget.pet.nome}'),
        backgroundColor: _corPrincipal, // ✅ roxo suavizado
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reminderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : todasConsultas.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.width - 40
                      : MediaQuery.of(context).size.width * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (futuras.isNotEmpty) ...[
                        _buildSectionTitle(
                          'Próximas Consultas',
                          Icons.upcoming,
                        ),
                        const SizedBox(height: 12),
                        ...futuras.map(
                          (consulta) =>
                              _buildConsultationCard(consulta, isFuture: true),
                        ),
                        const SizedBox(height: 32),
                      ],
                      if (passadas.isNotEmpty) ...[
                        _buildSectionTitle(
                          'Histórico de Consultas',
                          Icons.history,
                        ),
                        const SizedBox(height: 12),
                        ...passadas.map(
                          (consulta) =>
                              _buildConsultationCard(consulta, isFuture: false),
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
            builder: (_) => ReminderFormDialog(
              idPet: widget.pet.idPet!,
              tipoInicial: 'consulta',
            ),
          );
          if (resultado == true && mounted) {
            await Provider.of<ReminderProvider>(
              context,
              listen: false,
            ).carregarOcorrenciasDoPet(widget.pet.idPet!);
          }
        },
        backgroundColor: _corPrincipal, // ✅ roxo suavizado
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Consulta',
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

  Widget _buildConsultationCard(
    ReminderOccurrenceModel consulta, {
    required bool isFuture,
  }) {
    final data = _getProximaData(consulta) ?? consulta.dataHora;
    final corPrincipal = isFuture ? _corPrincipal : Colors.grey.shade600;
    final corFundo = isFuture ? _corFundoClaro : Colors.grey.shade100;

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
                  color: corFundo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: corPrincipal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consulta.titulo,
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
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: corPrincipal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatarData(data),
                          style: TextStyle(
                            fontSize: 13,
                            color: corPrincipal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.access_time, size: 14, color: corPrincipal),
                        const SizedBox(width: 6),
                        Text(
                          '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 13, color: corPrincipal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ Ações para consultas futuras
          if (isFuture) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ✅ Botão Concluir (visual normal, sem função)
                Material(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Função em desenvolvimento'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
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
                // ✅ Botão Excluir funcional
                Material(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _excluirConsulta(consulta),
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
                color: _corFundoBadge,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services,
                color: _corPrincipal,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma consulta registrada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mantenha a saúde do seu pet em dia agendando suas visitas ao veterinário.',
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

// ✅ Dialog padronizado para exclusão (mesmo padrão do DeletePetDialog)
class _DialogExcluirConsulta extends StatelessWidget {
  final String petName;

  const _DialogExcluirConsulta({required this.petName});

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
                      'Excluir consulta',
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
                            'Tem certeza que deseja excluir "$petName"?',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Essa ação não pode ser desfeita e a consulta será permanentemente removida.',
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
