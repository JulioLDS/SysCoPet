import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/custom_snackbar.dart';

class ReminderDetailsScreen extends StatefulWidget {
  final int idLembrete;
  final int idPet;

  const ReminderDetailsScreen({
    super.key,
    required this.idLembrete,
    required this.idPet,
  });

  @override
  State<ReminderDetailsScreen> createState() =>
      _ReminderDetailsScreenState();
}

class _ReminderDetailsScreenState
    extends State<ReminderDetailsScreen> {

  ReminderModel? _lembrete;
  bool _carregando = true;
  bool _houveAlteracao = false;

  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir lembrete',),
        content: Text('Deseja realmente excluir "${_lembrete!.titulo}"?',),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    final provider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    final erro = await provider.deletarLembrete(
      widget.idLembrete,
      widget.idPet,
    );

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context,erro,);
      return;
    }

    CustomSnackbar.showSuccess(
      context,
      'Lembrete excluído com sucesso!',
      color: const Color(0xFF047857),
    );

    Navigator.pop(context,true,);
  }

  

  @override
  void initState() {
    super.initState();
    _carregarLembrete();
  }

  Future<void> _carregarLembrete() async {
    final provider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    final lembrete = await provider.buscarLembretePorId(
      widget.idPet,
      widget.idLembrete,
    );

    if (!mounted) return;

    setState(() {
      _lembrete = lembrete;
      _carregando = false;
    });
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

  String _formatarRecorrencia(String recorrencia) {
    switch (recorrencia) {
      case 'unica':
        return 'Única';
      case 'diaria':
        return 'Diária';
      case 'semanal':
        return 'Semanal';
      case 'mensal':
        return 'Mensal';
      case 'outro':
        return 'Outro';
      default:
        return recorrencia;
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
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_lembrete == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text(
            'Lembrete não encontrado.',
          ),
        ),
      );
    }

    final lembrete = _lembrete!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: const Text('Detalhes do lembrete'),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              _houveAlteracao ? true : null,
            );
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // CABEÇALHO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),

                  child: Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _iconePorTipo(
                            lembrete.tipo,
                          ),
                          color:
                              const Color(0xFF0D9488),
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [
                            Text(
                              lembrete.titulo,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(0xFF1E293B),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              _formatarTipo(
                                lembrete.tipo,
                              ),
                              style: TextStyle(
                                color:
                                    Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // DESCRIÇÃO
                _infoCard(
                  titulo: 'Descrição',
                  valor:
                      lembrete.descricao == null ||
                              lembrete
                                  .descricao!.isEmpty
                          ? 'Sem descrição'
                          : lembrete.descricao!,
                  icon: Icons.description_outlined,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  titulo: 'Data',
                  valor: _formatarData(
                    lembrete.dataHora,
                  ),
                  icon:
                      Icons.calendar_today_outlined,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  titulo: 'Horário',
                  valor: _formatarHora(
                    lembrete.dataHora,
                  ),
                  icon: Icons.access_time,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  titulo: 'Tipo',
                  valor: _formatarTipo(
                    lembrete.tipo,
                  ),
                  icon: _iconePorTipo(
                    lembrete.tipo,
                  ),
                ),

                const SizedBox(height: 12),

                _infoCard(
                  titulo: 'Recorrência',
                  valor: _formatarRecorrencia(
                    lembrete.recorrencia,
                  ),
                  icon: Icons.repeat,
                ),

                const SizedBox(height: 12),

                _infoCard(
                  titulo: 'Status',
                  valor: lembrete.ativo
                      ? 'Ativo'
                      : 'Inativo',
                  icon: lembrete.ativo
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _editarLembrete,
                        icon:
                            const Icon(Icons.edit),
                        label:
                            const Text('Editar'),
                        style:
                            ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.all(
                            16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _confirmarExclusao,
                        icon:
                            const Icon(Icons.delete),
                        label:
                            const Text('Excluir'),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red,
                          foregroundColor:
                              Colors.white,
                          padding:
                              const EdgeInsets.all(
                            16,
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
      ),
    );
  }

  Widget _infoCard({
    required String titulo,
    required String valor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF0D9488),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  valor,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editarLembrete() {}
}