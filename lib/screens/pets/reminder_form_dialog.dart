import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../models/pet_model.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/custom_snackbar.dart';

class ReminderFormDialog extends StatefulWidget {
  final int? idPet;
  final List<PetModel> petsDisponiveis;
  final DateTime? dataInicial;
  final ReminderModel? lembrete;
  final String? tipoInicial;

  const ReminderFormDialog({
    super.key,
    this.idPet,
    this.petsDisponiveis = const [],
    this.dataInicial,
    this.lembrete,
    this.tipoInicial,
  });

  @override
  State<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<ReminderFormDialog> {
  bool get _editando => widget.lembrete != null;
  bool get _escolherPet => !_editando && widget.idPet == null;
  int? _idPetSelecionado;
  bool _salvando = false;

  List<PetModel> get _petsDisponiveis => {
    for (final pet in widget.petsDisponiveis)
      if (pet.idPet != null) pet.idPet!: pet,
  }.values.toList();

  final _formKey = GlobalKey<FormState>();

  final FocusNode _tituloFocus = FocusNode();
  final FocusNode _descricaoFocus = FocusNode();

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();

  DateTime? dataSelecionada;
  TimeOfDay? horaSelecionada;

  String tipoSelecionado = 'alimentacao';
  String recorrenciaSelecionada = 'unica';

  int tituloLength = 0;
  int descricaoLength = 0;

  final tipos = const [
    'alimentacao',
    'banho',
    'medicamento',
    'consulta',
    'vacina',
  ];

  final recorrencias = const ['unica', 'diaria', 'semanal', 'mensal'];

  @override
  void initState() {
    super.initState();
    _idPetSelecionado = widget.lembrete?.idPet ?? widget.idPet;
    if (_escolherPet && _petsDisponiveis.length == 1) {
      _idPetSelecionado = _petsDisponiveis.single.idPet;
    }
    if (!_editando && widget.dataInicial != null) {
      final data = widget.dataInicial!;
      dataSelecionada = DateTime(data.year, data.month, data.day);
    }
    tituloController.addListener(_updateTituloLength);
    descricaoController.addListener(_updateDescricaoLength);

    // 1. Se estiver EDITANDO um lembrete existente, usa os dados dele
    if (widget.lembrete != null) {
      final lembrete = widget.lembrete!;

      tituloController.text = lembrete.titulo;
      descricaoController.text = lembrete.descricao ?? '';

      tipoSelecionado = lembrete.tipo;
      recorrenciaSelecionada = lembrete.recorrencia;

      final data = lembrete.dataHora;
      dataSelecionada = DateTime(data.year, data.month, data.day);
      horaSelecionada = TimeOfDay(hour: data.hour, minute: data.minute);

      // Atualiza os contadores logo ao abrir
      tituloLength = tituloController.text.length;
      descricaoLength = descricaoController.text.length;
    }
    // 2. Se for um NOVO lembrete, verifica se a Home passou um tipo inicial
    else {
      if (widget.tipoInicial != null) {
        tipoSelecionado = widget.tipoInicial!; // ✅ AQUI ELE PEGA 'consulta'
      } else {
        tipoSelecionado = 'alimentacao'; // Fallback padrão se nada for passado
      }
    }
  }

  void _updateTituloLength() {
    setState(() {
      tituloLength = tituloController.text.length;
    });
  }

  void _updateDescricaoLength() {
    setState(() {
      descricaoLength = descricaoController.text.length;
    });
  }

  @override
  void dispose() {
    tituloController.removeListener(_updateTituloLength);
    descricaoController.removeListener(_updateDescricaoLength);
    tituloController.dispose();
    descricaoController.dispose();
    _tituloFocus.dispose();
    _descricaoFocus.dispose();
    super.dispose();
  }

  // ✅ SELECIONAR DATA (Nativo com tema customizado)
  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final ultimaData = DateTime(hoje.year + 5);
    final escolhida = dataSelecionada ?? hoje;
    final inicial = escolhida.isBefore(hoje)
        ? hoje
        : escolhida.isAfter(ultimaData)
        ? ultimaData
        : escolhida;

    final data = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: hoje,
      lastDate: ultimaData,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: const Color(0xFFECFDF5),
              headerForegroundColor: const Color(0xFF0D9488),
              weekdayStyle: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
              dayStyle: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              // ✅ Apenas estas propriedades funcionam
              todayForegroundColor: WidgetStateProperty.all(
                const Color(0xFF0D9488),
              ),
              todayBackgroundColor: WidgetStateProperty.all(
                const Color(0xFFECFDF5),
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (data == null) return;
    setState(() {
      dataSelecionada = data;
    });
  }

  // ✅ SELECIONAR HORA (Nativo com tema customizado)
  // ✅ SELECIONAR HORA (Nativo com tema customizado)
  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: horaSelecionada ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D9488),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E293B),
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
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
    if (_salvando || !_formKey.currentState!.validate()) return;
    final idPet = _idPetSelecionado;
    if (idPet == null ||
        (_escolherPet && !_petsDisponiveis.any((pet) => pet.idPet == idPet))) {
      CustomSnackbar.showError(context, 'Selecione o pet do lembrete');
      return;
    }

    final dataHora = _montarDataHora();

    if (dataHora == null) {
      CustomSnackbar.showError(context, 'Selecione data e hora do lembrete');
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
      idLembrete: widget.lembrete?.idLembrete,
      idPet: idPet,
      titulo: tituloController.text.trim(),
      descricao: descricaoController.text.trim().isEmpty
          ? null
          : descricaoController.text.trim(),
      dataHora: dataHora,
      tipo: tipoSelecionado,
      recorrencia: recorrenciaSelecionada,
      ativo: widget.lembrete?.ativo ?? true,
      concluido: widget.lembrete?.concluido ?? false,
    );

    final provider = Provider.of<ReminderProvider>(context, listen: false);

    setState(() => _salvando = true);
    try {
      final erro = _editando
          ? await provider.atualizarLembrete(lembrete)
          : await provider.criarLembrete(lembrete);
      if (!mounted) return;
      if (erro != null) {
        CustomSnackbar.showError(context, erro);
        return;
      }
      if (!_editando && provider.avisoCriacao != null) {
        CustomSnackbar.showWarning(context, provider.avisoCriacao!);
      } else {
        CustomSnackbar.showSuccess(
          context,
          _editando
              ? 'Lembrete atualizado com sucesso!'
              : 'Lembrete criado com sucesso!',
          color: const Color(0xFF047857),
        );
      }
      Navigator.pop(context, true);
    } catch (_) {
      if (mounted)
        CustomSnackbar.showError(
          context,
          'Não foi possível salvar o lembrete. Tente novamente.',
        );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _buildPetSelector() {
    final pets = _petsDisponiveis;
    return DropdownButtonFormField<int>(
      key: const ValueKey('reminder-pet-selector'),
      value: _idPetSelecionado,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Pet',
        hintText: 'Selecione o pet',
        prefixIcon: const Icon(Icons.pets, color: Color(0xFF0D9488)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        helperText: pets.isEmpty
            ? 'Adicione um pet antes de criar um lembrete.'
            : null,
      ),
      items: pets
          .map(
            (pet) => DropdownMenuItem<int>(
              value: pet.idPet,
              child: Text(
                '${pet.nome} (${pet.especie})',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: _salvando || pets.isEmpty
          ? null
          : (value) => setState(() => _idPetSelecionado = value),
      validator: (value) =>
          value == null || !pets.any((pet) => pet.idPet == value)
          ? 'Selecione o pet do lembrete'
          : null,
    );
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  String _formatarHora(TimeOfDay? hora) {
    if (hora == null) return '';
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
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
      default:
        return valor;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return Icons.restaurant;
      case 'banho':
        return Icons.bathtub;
      case 'medicamento':
        return Icons.medication;
      case 'consulta':
        return Icons.medical_services;
      case 'vacina':
        return Icons.vaccines;
      default:
        return Icons.notifications;
    }
  }

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return const Color(0xFF10B981);
      case 'banho':
        return const Color(0xFF3B82F6);
      case 'medicamento':
        return const Color(0xFF8B5CF6);
      case 'consulta':
        return const Color(0xFFEF4444);
      case 'vacina':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF0D9488);
    }
  }

  IconData _getRecorrenciaIcon(String recorrencia) {
    switch (recorrencia) {
      case 'unica':
        return Icons.looks_one;
      case 'diaria':
        return Icons.calendar_view_day;
      case 'semanal':
        return Icons.calendar_view_week;
      case 'mensal':
        return Icons.calendar_view_month;
      default:
        return Icons.refresh;
    }
  }

  Color _getRecorrenciaColor(String recorrencia) {
    switch (recorrencia) {
      case 'unica':
        return const Color(0xFF6B7280);
      case 'diaria':
        return const Color(0xFFEA580C);
      case 'semanal':
        return const Color(0xFF3B82F6);
      case 'mensal':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF0D9488);
    }
  }

  IconData _getTipoIconByLabel(String label) {
    switch (label) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Banho':
        return Icons.bathtub;
      case 'Medicamento':
        return Icons.medication;
      case 'Consulta':
        return Icons.medical_services;
      case 'Vacina':
        return Icons.vaccines;
      default:
        return Icons.notifications;
    }
  }

  Color _getTipoColorByLabel(String label) {
    switch (label) {
      case 'Alimentação':
        return const Color(0xFF10B981);
      case 'Banho':
        return const Color(0xFF3B82F6);
      case 'Medicamento':
        return const Color(0xFF8B5CF6);
      case 'Consulta':
        return const Color(0xFFEF4444);
      case 'Vacina':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF0D9488);
    }
  }

  IconData _getRecorrenciaIconByLabel(String label) {
    switch (label) {
      case 'Única':
        return Icons.looks_one;
      case 'Diária':
        return Icons.calendar_view_day;
      case 'Semanal':
        return Icons.calendar_view_week;
      case 'Mensal':
        return Icons.calendar_view_month;
      default:
        return Icons.refresh;
    }
  }

  Color _getRecorrenciaColorByLabel(String label) {
    switch (label) {
      case 'Única':
        return const Color(0xFF6B7280);
      case 'Diária':
        return const Color(0xFFEA580C);
      case 'Semanal':
        return const Color(0xFF3B82F6);
      case 'Mensal':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF0D9488);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 600) {
      return _buildMobileLayout(context);
    }

    return _buildWebLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    final media = MediaQuery.of(context);
    final alturaDisponivel = (media.size.height - media.viewInsets.bottom - 32)
        .clamp(200.0, media.size.height)
        .toDouble();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: alturaDisponivel),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: Color(0xFF0D9488),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editando ? 'Editar Lembrete' : 'Novo lembrete',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _editando
                                ? 'Edite o seu lembrete'
                                : 'Crie um lembrete para cuidar ainda melhor do seu pet.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _salvando ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF0D9488),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_escolherPet) ...[
                        _buildPetSelector(),
                        const SizedBox(height: 16),
                      ],
                      _buildCompactInputField(
                        label: 'Título',
                        icon: Icons.edit,
                        iconColor: const Color(0xFF0D9488),
                        iconBg: const Color(0xFFECFDF5),
                        controller: tituloController,
                        focusNode: _tituloFocus,
                        maxLength: 250,
                        currentLength: tituloLength,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => FocusScope.of(
                          context,
                        ).requestFocus(_descricaoFocus),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Informe o título'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildCompactInputField(
                        label: 'Descrição',
                        icon: Icons.description,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBg: const Color(0xFFEDE9FE),
                        controller: descricaoController,
                        focusNode: _descricaoFocus,
                        maxLength: 500,
                        currentLength: descricaoLength,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                      ),
                      const SizedBox(height: 12),
                      _buildCompactDropdown(
                        label: 'Tipo',
                        icon: _getTipoIcon(tipoSelecionado),
                        iconColor: _getTipoColor(tipoSelecionado),
                        iconBg: _getTipoColor(tipoSelecionado).withOpacity(0.1),
                        value: _formatarTexto(tipoSelecionado),
                        items: tipos
                            .map((tipo) => _formatarTexto(tipo))
                            .toList(),
                        getIconForItem: _getTipoIconByLabel,
                        getColorForItem: _getTipoColorByLabel,
                        onChanged: (value) {
                          setState(() {
                            tipoSelecionado =
                                tipos[tipos.indexWhere(
                                  (t) => _formatarTexto(t) == value,
                                )];
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildCompactDropdown(
                        label: 'Recorrência',
                        icon: _getRecorrenciaIcon(recorrenciaSelecionada),
                        iconColor: _getRecorrenciaColor(recorrenciaSelecionada),
                        iconBg: _getRecorrenciaColor(
                          recorrenciaSelecionada,
                        ).withOpacity(0.1),
                        value: _formatarTexto(recorrenciaSelecionada),
                        items: recorrencias
                            .map((r) => _formatarTexto(r))
                            .toList(),
                        getIconForItem: _getRecorrenciaIconByLabel,
                        getColorForItem: _getRecorrenciaColorByLabel,
                        onChanged: (value) {
                          setState(() {
                            recorrenciaSelecionada =
                                recorrencias[recorrencias.indexWhere(
                                  (r) => _formatarTexto(r) == value,
                                )];
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMobileDateTimeField(
                              label: 'Data',
                              icon: Icons.calendar_today,
                              iconColor: const Color(0xFF0D9488),
                              iconBg: const Color(0xFFECFDF5),
                              value: _formatarData(dataSelecionada),
                              onTap: _selecionarData,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildMobileDateTimeField(
                              label: 'Horário',
                              icon: Icons.access_time,
                              iconColor: const Color(0xFF8B5CF6),
                              iconBg: const Color(0xFFEDE9FE),
                              value: _formatarHora(horaSelecionada),
                              onTap: _selecionarHora,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _salvando
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF0D9488),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Salvar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildMobileDateTimeField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value.isEmpty ? 'Selecionar' : value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: value.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebLayout(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFECFDF5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Color(0xFF0D9488),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editando ? 'Editar Lembrete' : 'Novo lembrete',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        _editando
                            ? 'Edite o seu lembrete'
                            : 'Crie um lembrete para cuidar ainda melhor do seu pet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _salvando ? null : () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Color(0xFF0D9488),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_escolherPet) ...[
                    _buildPetSelector(),
                    const SizedBox(height: 16),
                  ],
                  _buildCompactInputField(
                    label: 'Título',
                    icon: Icons.edit,
                    iconColor: const Color(0xFF0D9488),
                    iconBg: const Color(0xFFECFDF5),
                    controller: tituloController,
                    focusNode: _tituloFocus,
                    maxLength: 250,
                    currentLength: tituloLength,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_descricaoFocus),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Informe o título'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  _buildCompactInputField(
                    label: 'Descrição',
                    icon: Icons.description,
                    iconColor: const Color(0xFF8B5CF6),
                    iconBg: const Color(0xFFEDE9FE),
                    controller: descricaoController,
                    focusNode: _descricaoFocus,
                    maxLength: 500,
                    currentLength: descricaoLength,
                    maxLines: 2,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  const SizedBox(height: 8),
                  _buildCompactDropdown(
                    label: 'Tipo',
                    icon: _getTipoIcon(tipoSelecionado),
                    iconColor: _getTipoColor(tipoSelecionado),
                    iconBg: _getTipoColor(tipoSelecionado).withOpacity(0.1),
                    value: _formatarTexto(tipoSelecionado),
                    items: tipos.map((tipo) => _formatarTexto(tipo)).toList(),
                    getIconForItem: _getTipoIconByLabel,
                    getColorForItem: _getTipoColorByLabel,
                    onChanged: (value) {
                      setState(() {
                        tipoSelecionado =
                            tipos[tipos.indexWhere(
                              (t) => _formatarTexto(t) == value,
                            )];
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildCompactDropdown(
                    label: 'Recorrência',
                    icon: _getRecorrenciaIcon(recorrenciaSelecionada),
                    iconColor: _getRecorrenciaColor(recorrenciaSelecionada),
                    iconBg: _getRecorrenciaColor(
                      recorrenciaSelecionada,
                    ).withOpacity(0.1),
                    value: _formatarTexto(recorrenciaSelecionada),
                    items: recorrencias
                        .map((recorrencia) => _formatarTexto(recorrencia))
                        .toList(),
                    getIconForItem: _getRecorrenciaIconByLabel,
                    getColorForItem: _getRecorrenciaColorByLabel,
                    onChanged: (value) {
                      setState(() {
                        recorrenciaSelecionada =
                            recorrencias[recorrencias.indexWhere(
                              (r) => _formatarTexto(r) == value,
                            )];
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactDateTimeField(
                          label: 'Data',
                          icon: Icons.calendar_today,
                          iconColor: const Color(0xFF0D9488),
                          iconBg: const Color(0xFFECFDF5),
                          value: _formatarData(dataSelecionada),
                          onTap: _selecionarData,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCompactDateTimeField(
                          label: 'Horário',
                          icon: Icons.access_time,
                          iconColor: const Color(0xFF8B5CF6),
                          iconBg: const Color(0xFFEDE9FE),
                          value: _formatarHora(horaSelecionada),
                          onTap: _selecionarHora,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _salvando ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF0D9488),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactInputField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required TextEditingController controller,
    required FocusNode focusNode,
    required int maxLength,
    required int currentLength,
    int maxLines = 1,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  onTapOutside: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: textInputAction,
                  onFieldSubmitted: onFieldSubmitted,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    filled: true,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                  maxLength: maxLength,
                  maxLines: maxLines,
                  validator: validator,
                  buildCounter:
                      (
                        context, {
                        required currentLength,
                        required isFocused,
                        required maxLength,
                      }) => null,
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$currentLength/$maxLength',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDropdown({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData Function(String) getIconForItem,
    required Color Function(String) getColorForItem,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF0D9488),
                size: 20,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Row(
                    children: [
                      Icon(
                        getIconForItem(item),
                        color: getColorForItem(item),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(item, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDateTimeField({
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(icon, color: iconColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Selecionar' : value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: value.isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  Icon(
                    icon == Icons.calendar_today
                        ? Icons.calendar_today
                        : Icons.access_time,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
