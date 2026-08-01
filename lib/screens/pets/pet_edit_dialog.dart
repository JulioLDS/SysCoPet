import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/models/raca_model.dart';
import 'package:syscopet/services/pet_service.dart';

import '../../widgets/common/custom_snackbar.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';

class PetEditDialog extends StatefulWidget {
  final PetModel pet;

  const PetEditDialog({super.key, required this.pet});

  @override
  State<PetEditDialog> createState() => _PetEditDialogState();
}

class _PetEditDialogState extends State<PetEditDialog> {
  final _formKey = GlobalKey<FormState>();

  // ✅ FocusNodes para navegação
  final FocusNode _nomeFocus = FocusNode();
  final FocusNode _especieFocus = FocusNode();
  final FocusNode _racaFocus = FocusNode();
  final FocusNode _anoFocus = FocusNode();
  final FocusNode _mesFocus = FocusNode();
  final FocusNode _diaFocus = FocusNode();
  final FocusNode _pesoFocus = FocusNode();
  final FocusNode _alturaFocus = FocusNode();

  final nomeController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  final anoController = TextEditingController();
  final mesController = TextEditingController();
  final diaController = TextEditingController();

  String? especieSelecionada;
  int? racaSelecionadaId;

  List<RacaModel> racas = [];
  bool carregandoRacas = false;

  final PetService petService = PetService();

  @override
  void initState() {
    super.initState();

    nomeController.text = widget.pet.nome;
    pesoController.text = widget.pet.peso.toString();

    if (widget.pet.altura != null) {
      alturaController.text = widget.pet.altura.toString();
    }

    especieSelecionada = widget.pet.especie;
    racaSelecionadaId = widget.pet.idRaca;

    if (widget.pet.dataNascimento != null) {
      final data = widget.pet.dataNascimento!.split('T').first;
      final partes = data.split('-');

      if (partes.isNotEmpty) {
        anoController.text = partes[0];
      }

      if (partes.length >= 2) {
        mesController.text = partes[1];
      }

      if (partes.length >= 3) {
        diaController.text = partes[2];
      }
    }

    if (especieSelecionada == 'cao' || especieSelecionada == 'gato') {
      carregarRacas(especieSelecionada!, focarAposCarregar: false);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    anoController.dispose();
    mesController.dispose();
    diaController.dispose();

    _nomeFocus.dispose();
    _especieFocus.dispose();
    _racaFocus.dispose();
    _anoFocus.dispose();
    _mesFocus.dispose();
    _diaFocus.dispose();
    _pesoFocus.dispose();
    _alturaFocus.dispose();

    super.dispose();
  }

  Future<void> carregarRacas(
    String especie, {
    bool focarAposCarregar = false,
  }) async {
    setState(() {
      carregandoRacas = true;
      racas = [];
    });

    try {
      final resultado = await petService.listarRacas(especie);

      setState(() {
        racas = resultado;
      });

      if (focarAposCarregar) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && racas.isNotEmpty) {
            FocusScope.of(context).requestFocus(_racaFocus);
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'Erro ao carregar raças: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        carregandoRacas = false;
      });
    }
  }

  // ✅ MÉTODO CORRIGIDO: Apenas salva e devolve o resultado para a tela de detalhes
  Future<void> _salvarPet() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final usuario = authProvider.currentUser;

    final ano = anoController.text.trim();
    final mes = mesController.text.trim();
    final dia = diaController.text.trim();

    if (ano.isEmpty) {
      CustomSnackbar.showError(context, 'O ano de nascimento é obrigatório');
      return;
    }

    String? dataNascimento = ano;
    if (mes.isNotEmpty) {
      dataNascimento += '-${mes.padLeft(2, '0')}';
      if (dia.isNotEmpty) {
        dataNascimento += '-${dia.padLeft(2, '0')}';
      }
    }

    final pet = PetModel(
      idPet: widget.pet.idPet,
      nome: nomeController.text.trim(),
      especie: especieSelecionada!,
      idRaca: racaSelecionadaId,
      dataNascimento: dataNascimento,
      peso: double.parse(pesoController.text),
      altura: alturaController.text.isEmpty
          ? null
          : double.parse(alturaController.text),
      porte: widget.pet.porte,
      idUsuario: usuario!.id,
    );

    // 1. Chama a atualização no backend
    final resultado = await petProvider.atualizarPet(pet);

    if (!mounted) return;

    // 2. Retorna o resultado (Map) para a PetDetailsScreen tratar tudo
    // (mostrar alerta, mostrar sucesso e atualizar os dados na tela)
    Navigator.pop(context, resultado);
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0D9488),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Editar ${widget.pet.nome}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: nomeController,
                        focusNode: _nomeFocus,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_especieFocus);
                        },
                        decoration: InputDecoration(
                          labelText: 'Nome do Pet',
                          prefixIcon: const Icon(
                            Icons.pets,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o nome';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: especieSelecionada,
                        focusNode: _especieFocus,
                        decoration: InputDecoration(
                          labelText: 'Espécie',
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0D9488),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF0D9488),
                            size: 20,
                          ),
                        ),
                        iconSize: 20,
                        dropdownColor: Colors.white,
                        menuMaxHeight: 300,
                        selectedItemBuilder: (context) {
                          return [
                            const Row(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: Color(0xFF0D9488),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Cão',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: Color(0xFF8B5CF6),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Gato',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Color(0xFF0D9488),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Outro',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ];
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'cao',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: Color(0xFF0D9488),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Cão',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'gato',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.pets,
                                  color: Color(0xFF8B5CF6),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Gato',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'outro',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  color: Color(0xFF0D9488),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Outro',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            especieSelecionada = value;
                            racaSelecionadaId = null;
                            racas = [];
                          });

                          if (value == 'cao' || value == 'gato') {
                            carregarRacas(value!, focarAposCarregar: true);
                          } else {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                if (mounted) {
                                  FocusScope.of(
                                    context,
                                  ).requestFocus(_anoFocus);
                                }
                              },
                            );
                          }
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma espécie';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>(
                        key: ValueKey(
                          'raca_${especieSelecionada}_${racas.length}',
                        ),
                        value: racaSelecionadaId,
                        focusNode: _racaFocus,
                        decoration: InputDecoration(
                          labelText: carregandoRacas
                              ? 'Carregando raças...'
                              : 'Raça',
                          prefixIcon: const Icon(
                            Icons.pets,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF0D9488),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF0D9488),
                            size: 20,
                          ),
                        ),
                        iconSize: 20,
                        dropdownColor: Colors.white,
                        menuMaxHeight: 300,
                        selectedItemBuilder: (context) {
                          if (racas.isEmpty) {
                            return <Widget>[];
                          }

                          return racas.map((raca) {
                            return Text(
                              raca.nome,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1E293B),
                              ),
                            );
                          }).toList();
                        },
                        items: racas.isEmpty
                            ? null
                            : racas.map((raca) {
                                return DropdownMenuItem<int>(
                                  value: raca.idRaca,
                                  child: Row(
                                    children: [
                                      Icon(
                                        especieSelecionada == 'cao'
                                            ? Icons.pets
                                            : especieSelecionada == 'gato'
                                            ? Icons.pets
                                            : Icons.help_outline,
                                        color: especieSelecionada == 'cao'
                                            ? const Color(0xFF0D9488)
                                            : especieSelecionada == 'gato'
                                            ? const Color(0xFF8B5CF6)
                                            : const Color(0xFF0D9488),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        raca.nome,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        onChanged:
                            especieSelecionada == null ||
                                especieSelecionada == 'outro' ||
                                carregandoRacas ||
                                racas.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  racaSelecionadaId = value;
                                });

                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_anoFocus);
                                  },
                                );
                              },
                        validator: (value) {
                          if (especieSelecionada == 'cao' ||
                              especieSelecionada == 'gato') {
                            if (value == null) {
                              return 'Selecione uma raça';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: anoController,
                              focusNode: _anoFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_mesFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'Ano *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: mesController,
                              focusNode: _mesFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_diaFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'Mês',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: diaController,
                              focusNode: _diaFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_pesoFocus);
                              },
                              decoration: InputDecoration(
                                labelText: 'Dia',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: pesoController,
                        focusNode: _pesoFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_alturaFocus);
                        },
                        decoration: InputDecoration(
                          labelText: 'Peso (kg)',
                          prefixIcon: const Icon(
                            Icons.monitor_weight_outlined,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Digite o peso';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: alturaController,
                        focusNode: _alturaFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) {
                          _salvarPet();
                        },
                        decoration: InputDecoration(
                          labelText: 'Altura (cm) - opcional',
                          prefixIcon: const Icon(
                            Icons.height,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: petProvider.isLoading ? null : _salvarPet,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D9488),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: petProvider.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Salvar alterações',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
