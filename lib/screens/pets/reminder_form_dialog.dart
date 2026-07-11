import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/custom_snackbar.dart';

class ReminderFormDialog extends StatefulWidget {
  final int idPet;

  const ReminderFormDialog({
    super.key,
    required this.idPet,
  });

  @override
  State<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<ReminderFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  String tipoSelecionado = 'alimentacao';
  String recorrenciaSelecionada = 'unica';

  final tipos = const [
    'alimentacao',
    'banho',
    'medicamento',
    'consulta',
    'vacina',
  ];

  final recorrencias = const [
    'unica',
    'diaria',
    'semanal',
    'mensal',
    'outro',
  ];

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
    );

    if (data == null) return;

    setState(() {
      dataSelecionada = data;
    });
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora == null) return;

    setState(() {
      horaSelecionada = hora;
    });
  }

  DateTime? _montarDataHora() {
    if (dataSelecionada == null || horaSelecionada == null) {
      return null;
    }

    return DateTime(
      dataSelecionada!.year,
      dataSelecionada!.month,
      dataSelecionada!.day,
      horaSelecionada!.hour,
      horaSelecionada!.minute,
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final dataHora = _montarDataHora();

    if (dataHora == null) {
      CustomSnackbar.showError(
        context,
        'Selecione data e hora do lembrete',
      );
      return;
    }

    if (dataHora.isBefore(DateTime.now())) {
      CustomSnackbar.showError(
        context,
        'Não é permitido criar lembrete no passado',
      );
      return;
    }

    final lembrete = ReminderModel(
      idPet: widget.idPet,
      titulo: tituloController.text.trim(),
      descricao: descricaoController.text.trim().isEmpty
          ? null
          : descricaoController.text.trim(),
      dataHora: dataHora,
      tipo: tipoSelecionado,
      recorrencia: recorrenciaSelecionada,
      ativo: true,
    );

    final provider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    final erro = await provider.criarLembrete(lembrete);

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context, erro);
      return;
    }

    Navigator.pop(context, true);
  }

  String _formatarData(DateTime? data) {
    if (data == null) return 'Selecionar data';

    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarHora(TimeOfDay? hora) {
    if (hora == null) return 'Selecionar hora';

    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  String _formatarTexto(String valor) {
    switch (valor) {
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
        return valor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo lembrete'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 250,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o título';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 500,
                  maxLines: 3,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: tipoSelecionado,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                  items: tipos.map((tipo) {
                    return DropdownMenuItem(
                      value: tipo,
                      child: Text(_formatarTexto(tipo)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      tipoSelecionado = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: recorrenciaSelecionada,
                  decoration: const InputDecoration(
                    labelText: 'Recorrência',
                    border: OutlineInputBorder(),
                  ),
                  items: recorrencias.map((recorrencia) {
                    return DropdownMenuItem(
                      value: recorrencia,
                      child: Text(_formatarTexto(recorrencia)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() {
                      recorrenciaSelecionada = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selecionarData,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_formatarData(dataSelecionada)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selecionarHora,
                        icon: const Icon(Icons.access_time),
                        label: Text(_formatarHora(horaSelecionada)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}