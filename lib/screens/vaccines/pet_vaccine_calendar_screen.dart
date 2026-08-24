import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/pet_model.dart';
import '../../models/vaccine_calendar_model.dart';
import '../../providers/vaccine_provider.dart';

class PetVaccineCalendarScreen
    extends StatefulWidget {
  final PetModel pet;

  const PetVaccineCalendarScreen({
    super.key,
    required this.pet,
  });

  @override
  State<PetVaccineCalendarScreen>
      createState() =>
          _PetVaccineCalendarScreenState();
}

class _PetVaccineCalendarScreenState
    extends State<PetVaccineCalendarScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<VaccineProvider>(
        context,
        listen: false,
      ).carregarCalendario(
        widget.pet.idPet!,
      );
    });
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _textoDose(
    VaccineCalendarModel dose,
  ) {
    if (dose.tipo == 'reforco') {
      return 'Reforço';
    }

    return 'Dose ${dose.doseNumero}';
  }

  Color _corStatus(
    VaccineCalendarModel dose,
  ) {
    if (dose.status == 'aplicada') {
      return Colors.green;
    }

    if (dose.status == 'pulada') {
      return Colors.grey;
    }

    if (dose.atrasada) {
      return Colors.red;
    }

    return Colors.orange;
  }

  String _textoStatus(
    VaccineCalendarModel dose,
  ) {
    if (dose.status == 'aplicada') {
      return 'Aplicada';
    }

    if (dose.status == 'pulada') {
      return 'Pulada';
    }

    if (dose.atrasada) {
      return 'Atrasada';
    }

    return 'Pendente';
  }

  Future<void> _marcarComoAplicada(
    VaccineCalendarModel dose,
  ) async {
    final agora = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: agora,
      firstDate: DateTime(2000),
      lastDate: agora,
      helpText: 'Data de aplicação',
    );

    if (data == null || !mounted) return;

    final provider =
        Provider.of<VaccineProvider>(
      context,
      listen: false,
    );

    final resultado =
        await provider.registrarDose(
      dose: dose,
      status: 'aplicada',
      dataAplicacao: data,
    );

    if (!mounted) return;

    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            resultado.erro ??
                'Erro ao registrar vacina.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Dose registrada como aplicada!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    if (resultado.avisos.isNotEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: Colors.orange,
              ),
              SizedBox(width: 8),
              Text('Atenção'),
            ],
          ),
          content: Text(
            resultado.avisos.join('\n\n'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Entendi'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pularDose(
    VaccineCalendarModel dose,
  ) async {
    final confirmou =
        await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Pular dose',
        ),
        content: Text(
          'Deseja realmente marcar '
          '"${dose.vacinaNome}" como pulada?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Cancelar',
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),
            child: const Text(
              'Pular dose',
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    final provider =
        Provider.of<VaccineProvider>(
      context,
      listen: false,
    );

    final resultado =
        await provider.registrarDose(
      dose: dose,
      status: 'pulada',
    );

    if (!mounted) return;

    if (!resultado.sucesso) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            resultado.erro ??
                'Erro ao pular dose.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Dose marcada como pulada.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
        Provider.of<VaccineProvider>(
      context,
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      appBar: AppBar(
        title: Text(
          'Vacinas de ${widget.pet.nome}',
        ),
        backgroundColor:
            const Color(0xFF0D9488),
        foregroundColor: Colors.white,
      ),

      body: provider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : provider.calendario.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.vaccines_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma vacina encontrada.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      provider
                          .carregarCalendario(
                    widget.pet.idPet!,
                  ),

                  child: ListView.separated(
                    padding:
                        const EdgeInsets.all(
                      20,
                    ),

                    itemCount:
                        provider
                            .calendario.length,

                    separatorBuilder:
                        (_, __) =>
                            const SizedBox(
                      height: 12,
                    ),

                    itemBuilder:
                        (context, index) {
                      final dose =
                          provider.calendario[
                              index];

                      return _buildDoseCard(
                        dose,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildDoseCard(
    VaccineCalendarModel dose,
  ) {
    final corStatus =
        _corStatus(dose);

    final podeRegistrar =
        dose.status == 'pendente';

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: dose.atrasada &&
                  dose.status ==
                      'pendente'
              ? Colors.red.shade200
              : Colors.grey.shade200,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      const Color(
                        0xFFECFDF5,
                      ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: const Icon(
                  Icons.vaccines,
                  color:
                      Color(0xFF0D9488),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      dose.vacinaNome,
                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      _textoDose(dose),
                      style: TextStyle(
                        color: Colors
                            .grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color: corStatus
                      .withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
                child: Text(
                  _textoStatus(dose),
                  style: TextStyle(
                    color: corStatus,
                    fontWeight:
                        FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (dose.obrigatoria)
                _badge(
                  'Obrigatória',
                  Colors.red,
                ),

              if (dose.essencial)
                _badge(
                  'Essencial',
                  Colors.blue,
                ),
            ],
          ),

          if (dose.obrigatoria ||
              dose.essencial)
            const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              Text(
                'Prevista: '
                '${_formatarData(dose.dataPrevista)}',
              ),
            ],
          ),

          if (dose.dataAplicacao !=
              null) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Colors.green,
                ),

                const SizedBox(width: 8),

                Text(
                  'Aplicada em: '
                  '${_formatarData(dose.dataAplicacao!)}',
                ),
              ],
            ),
          ],

          if (dose.proximoReforco !=
              null) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(
                  Icons.update,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                Text(
                  'Próximo reforço: '
                  '${_formatarData(dose.proximoReforco!)}',
                ),
              ],
            ),
          ],

          if (podeRegistrar) ...[
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child:
                      ElevatedButton.icon(
                    onPressed: () =>
                        _marcarComoAplicada(
                      dose,
                    ),
                    icon: const Icon(
                      Icons.check,
                    ),
                    label: const Text(
                      'Aplicada',
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed: () =>
                        _pularDose(
                      dose,
                    ),
                    icon: const Icon(
                      Icons.skip_next,
                    ),
                    label: const Text(
                      'Pular',
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

  Widget _badge(
    String texto,
    Color cor,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}