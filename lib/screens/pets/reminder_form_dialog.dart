import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/reminder_model.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/custom_snackbar.dart';

class ReminderFormDialog extends StatefulWidget {
  final int idPet;

  const ReminderFormDialog({super.key, required this.idPet});

  @override
  State<ReminderFormDialog> createState() => _ReminderFormDialogState();
}

class _ReminderFormDialogState extends State<ReminderFormDialog> {
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
    tituloController.addListener(_updateTituloLength);
    descricaoController.addListener(_updateDescricaoLength);
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
    final hoje = DateTime.now();

    final data = await showDatePicker(
      context: context,
      initialDate: dataSelecionada ?? hoje,
      firstDate: hoje,
      lastDate: DateTime(hoje.year + 5),
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
    if (!_formKey.currentState!.validate()) return;

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

    final provider = Provider.of<ReminderProvider>(context, listen: false);
    final erro = await provider.criarLembrete(lembrete);

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context, erro);
      return;
    }

    CustomSnackbar.showSuccess(
      context,
      'Lembrete criado com sucesso!',
      color: const Color(0xFF047857),
    );
    Navigator.pop(context, true);
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
                      const Text(
                        'Novo lembrete',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Crie um lembrete para cuidar ainda melhor do seu pet.',
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
                    onTap: () => Navigator.pop(context),
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
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: _salvar,
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
                  Text(
                    value.isEmpty ? 'Selecionar' : value,
                    style: TextStyle(
                      fontSize: 14,
                      color: value.isEmpty
                          ? Colors.grey.shade400
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
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
