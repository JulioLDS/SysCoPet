import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/screens/pets/reminder_form_dialog.dart';

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
  State<ReminderDetailsScreen> createState() => _ReminderDetailsScreenState();
}

class _ReminderDetailsScreenState extends State<ReminderDetailsScreen> {
  ReminderModel? _lembrete;
  bool _carregando = true;
  bool _houveAlteracao = false;

  //Excluir
  Future<void> _confirmarExclusao() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteReminderDialog(reminderTitle: _lembrete!.titulo),
    );

    if (confirmar != true) return;

    final provider = Provider.of<ReminderProvider>(context, listen: false);

    final erro = await provider.deletarLembrete(
      widget.idLembrete,
      widget.idPet,
    );

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context, erro);
      return;
    }

    CustomSnackbar.showSuccess(
      context,
      'Lembrete excluído com sucesso!',
      color: const Color(0xFF047857),
    );

    // ✅ ADICIONE ESTAS LINHAS:
    if (mounted) {
      setState(() {
        _houveAlteracao = true;
      });
    }

    Navigator.pop(context, true);
  }

  Future<void> _editarLembrete() async {
    if (_lembrete == null) return;

    final atualizou = await showDialog<bool>(
      context: context,
      builder: (_) =>
          ReminderFormDialog(idPet: widget.idPet, lembrete: _lembrete!),
    );

    if (atualizou != true) return;

    await _carregarLembrete();

    if (!mounted) return;

    setState(() {
      _houveAlteracao = true;
    });

    CustomSnackbar.showSuccess(
      context,
      'Lembrete atualizado com sucesso!',
      color: const Color(0xFF047857),
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarLembrete();
  }

  Future<void> _carregarLembrete() async {
    final provider = Provider.of<ReminderProvider>(context, listen: false);

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

  Color _corFundoPorTipo(String tipo) {
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

  Color _corIconePorTipo(String tipo) {
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

  Color _corBadgeClaraPorTipo(String tipo) {
    switch (tipo) {
      case 'alimentacao':
        return const Color(0xFFFFF3E0);
      case 'banho':
        return const Color(0xFFE0F2FE);
      case 'medicamento':
        return const Color(0xFFF3E8FF);
      case 'consulta':
        return const Color(0xFFE0F2F1);
      case 'vacina':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_lembrete == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Column(
            children: [
              // Header com gradiente
              Container(
                height: 100,
                width: double.infinity,
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
                      const Text(
                        'Detalhes do lembrete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Mensagem de erro
              Expanded(
                child: Center(
                  child: Text(
                    'Lembrete não encontrado.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final lembrete = _lembrete!;
    final corFundo = _corFundoPorTipo(lembrete.tipo);
    final corIcone = _corIconePorTipo(lembrete.tipo);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ✅ HEADER COM GRADIENTE (igual PetDetailsScreen)
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
                      onTap: () =>
                          Navigator.pop(context, _houveAlteracao ? true : null),
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
                    // Título e Subtítulo
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lembrete.titulo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatarTipo(lembrete.tipo),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // ✅ Botão Editar com hover
                    _HoverButton(
                      onTap: _editarLembrete,
                      hoverColor: Colors.white,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit,
                              color: Color(0xFF0D9488),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Editar',
                              style: TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ CONTEÚDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ HEADER COM MOLDURA BRANCA
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _iconePorTipo(lembrete.tipo),
                                  color: corIcone,
                                  size: 32,
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
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _corBadgeClaraPorTipo(
                                          lembrete.tipo,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _iconePorTipo(lembrete.tipo),
                                            color: corIcone,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatarTipo(lembrete.tipo),
                                            style: TextStyle(
                                              color: corIcone,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ✅ CARDS DE INFORMAÇÃO
                      _infoCardModern(
                        titulo: 'Descrição',
                        valor:
                            lembrete.descricao == null ||
                                lembrete.descricao!.isEmpty
                            ? 'Sem descrição'
                            : lembrete.descricao!,
                        icon: Icons.description_outlined,
                      ),

                      const SizedBox(height: 12),

                      _infoCardModern(
                        titulo: 'Data',
                        valor: _formatarData(lembrete.dataHora),
                        icon: Icons.calendar_today_outlined,
                        showArrow: true,
                        onTap: _editarLembrete,
                      ),

                      const SizedBox(height: 12),

                      _infoCardModern(
                        titulo: 'Horário',
                        valor: _formatarHora(lembrete.dataHora),
                        icon: Icons.access_time,
                        showArrow: true,
                        onTap: _editarLembrete,
                      ),

                      const SizedBox(height: 12),

                      _infoCardModern(
                        titulo: 'Tipo',
                        valor: _formatarTipo(lembrete.tipo),
                        icon: _iconePorTipo(lembrete.tipo),
                        showArrow: true,
                        onTap: _editarLembrete,
                      ),

                      const SizedBox(height: 12),

                      _infoCardModern(
                        titulo: 'Recorrência',
                        valor: _formatarRecorrencia(lembrete.recorrencia),
                        icon: Icons.repeat,
                        showArrow: true,
                        onTap: _editarLembrete,
                      ),

                      const SizedBox(height: 12),

                      // ✅ STATUS COM BADGE ESTILIZADO
                      _statusCard(
                        titulo: 'Status',
                        ativo: lembrete.ativo,
                        icon: lembrete.ativo
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        onTap: _editarLembrete,
                      ),

                      const SizedBox(height: 32),

                      // ✅ BOTÕES DE AÇÃO
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _editarLembrete,
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text(
                                'Editar',
                                style: TextStyle(fontSize: 15),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0D9488),
                                side: const BorderSide(
                                  color: Color(0xFF0D9488),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _confirmarExclusao,
                              icon: const Icon(Icons.delete_outline, size: 20),
                              label: const Text(
                                'Excluir',
                                style: TextStyle(fontSize: 15),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFEF4444),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
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
          ),
        ],
      ),
    );
  }

  Widget _infoCardModern({
    required String titulo,
    required String valor,
    required IconData icon,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    final temAcao = showArrow && onTap != null;

    return MouseRegion(
      cursor: temAcao ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: temAcao ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
              if (temAcao)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusCard({
    required String titulo,
    required bool ativo,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFECFDF5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF0D9488), size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ativo
                            ? const Color(0xFFECFDF5)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: ativo
                                  ? const Color(0xFF0D9488)
                                  : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            ativo ? 'Ativo' : 'Inativo',
                            style: TextStyle(
                              color: ativo
                                  ? const Color(0xFF0D9488)
                                  : Colors.grey.shade600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Widget para botão com hover - IGUAL AO PetDetailsScreen
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

// ✅ Dialog Customizado para Exclusão de Lembrete (Padronizado com PetDetails)
class DeleteReminderDialog extends StatelessWidget {
  final String reminderTitle;

  const DeleteReminderDialog({super.key, required this.reminderTitle});

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

              // ✅ Mensagem de Aviso
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
                            'Tem certeza que deseja excluir "$reminderTitle"?',
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
