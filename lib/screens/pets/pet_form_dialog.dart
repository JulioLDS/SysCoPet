import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/models/raca_model.dart';
import 'package:syscopet/services/pet_service.dart';

import '../../widgets/common/custom_snackbar.dart';
import '../../models/pet_model.dart';
import '../../providers/pet_provider.dart';
import '../../providers/auth_provider.dart';

class PetFormDialog extends StatefulWidget {
  const PetFormDialog({super.key});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
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
  void dispose() {
    nomeController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    anoController.dispose();
    mesController.dispose();
    diaController.dispose();

    // ✅ Dispose dos FocusNodes
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

  Future<void> carregarRacas(String especie) async {
    setState(() {
      carregandoRacas = true;
      racas = [];
      racaSelecionadaId = null;
    });

    try {
      final resultado = await petService.listarRacas(especie);

      setState(() {
        racas = resultado;
      });

      // ✅ Foca na raça após carregar
      if (racas.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          FocusScope.of(context).requestFocus(_racaFocus);
        });
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar raças: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        carregandoRacas = false;
      });
    }
  }

  IconData _getEspecieIcon(String? especie) {
    switch (especie) {
      case 'cao':
        return Icons.pets; //  Pata para cão
      case 'gato':
        return Icons.pets; //  Rosto para gato (temporário)
      case 'outro':
        return Icons.help_outline;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _salvarPet() async {
    if (!_formKey.currentState!.validate()) {
      print('❌ Validação falhou!');
      print('   especieSelecionada: $especieSelecionada');
      print('   racaSelecionadaId: $racaSelecionadaId');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final usuario = authProvider.currentUser;

    String? dataNascimento;
    final ano = anoController.text.trim();
    final mes = mesController.text.trim();
    final dia = diaController.text.trim();

    if (ano.isNotEmpty) {
      dataNascimento = ano;
      if (mes.isNotEmpty) {
        dataNascimento += '-${mes.padLeft(2, '0')}';
        if (dia.isNotEmpty) {
          dataNascimento += '-${dia.padLeft(2, '0')}';
        }
      }
    }

    final pet = PetModel(
      nome: nomeController.text.trim(),
      especie: especieSelecionada!,
      idRaca: racaSelecionadaId,
      dataNascimento: dataNascimento,
      peso: double.parse(pesoController.text),
      altura: alturaController.text.isEmpty
          ? null
          : double.parse(alturaController.text),
      porte: '',
      idUsuario: usuario!.id,
    );

    final erro = await petProvider.cadastrarPet(pet);

    if (!mounted) return;

    if (erro != null) {
      CustomSnackbar.showError(context, erro);
      return;
    }

    CustomSnackbar.showSuccess(
      context,
      'Pet criado com sucesso!',
      color: const Color(0xFF047857),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                  const Icon(Icons.pets, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cadastrar Pet',
                      style: TextStyle(
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
                      // ✅ Nome - Enter vai para Espécie
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

                      // ✅ Espécie com ÍCONES
                      // ✅ Espécie com ÍCONES (Padronizado com Raça)
                      FormField<String>(
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma espécie';
                          }
                          return null;
                        },
                        builder: (field) {
                          return InputDecorator(
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
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
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
                              errorText: field.errorText,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: especieSelecionada,
                                isExpanded: true,
                                hint: const Text('Selecione uma espécie'),
                                // ✅ Ícone de seta customizado
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.1),
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
                                // ✅ Campo selecionado: ÍCONE + TEXTO
                                selectedItemBuilder: (context) {
                                  return [
                                    // Cão
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/cao.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Cão',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Gato
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/gato.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Gato',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Outro
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/desconhecido.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Outro',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ];
                                },
                                // ✅ Na lista: ÍCONE + TEXTO
                                items: [
                                  // Cão
                                  DropdownMenuItem(
                                    value: 'cao',
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/cao.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Cão',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Gato
                                  DropdownMenuItem(
                                    value: 'gato',
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/gato.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Gato',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Outro
                                  DropdownMenuItem(
                                    value: 'outro',
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30,
                                          height: 30,
                                          child: Image.asset(
                                            'assets/icons/desconhecido.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Outro',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1E293B),
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
                                    field.didChange(value);
                                  });

                                  if (value == 'cao' ||
                                      value == 'gato' ||
                                      value == 'outro') {
                                    carregarRacas(value!);
                                  } else {
                                    Future.delayed(
                                      const Duration(milliseconds: 100),
                                      () {
                                        FocusScope.of(
                                          context,
                                        ).requestFocus(_anoFocus);
                                      },
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // Raça
                      FormField<int>(
                        validator: (value) {
                          if (especieSelecionada == 'cao' ||
                              especieSelecionada == 'gato' ||
                              especieSelecionada == 'outro') {
                            if (value == null) {
                              return 'Selecione uma raça';
                            }
                          }
                          return null;
                        },
                        builder: (field) {
                          return InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Raça',
                              prefixIcon: const Icon(
                                Icons.pets_outlined,
                                color: Color(0xFF0D9488),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              errorText: field.errorText,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: racaSelecionadaId,
                                isExpanded: true,
                                hint: Text(
                                  carregandoRacas
                                      ? 'Carregando raças...'
                                      : 'Selecione uma raça',
                                ),
                                // ✅ Ícone de seta customizado (igual ao da espécie)
                                icon: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF0D9488,
                                    ).withOpacity(0.1),
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
                                items: racas.map((raca) {
                                  return DropdownMenuItem<int>(
                                    value: raca.idRaca,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 30, // ✅ De 32 para 30
                                          height: 30, // ✅ De 32 para 30
                                          child: Image.asset(
                                            especieSelecionada == 'cao'
                                                ? 'assets/icons/cao.png'
                                                : especieSelecionada == 'gato'
                                                ? 'assets/icons/gato.png'
                                                : 'assets/icons/desconhecido.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            raca.nome,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged:
                                    especieSelecionada == null ||
                                        carregandoRacas
                                    ? null
                                    : (value) {
                                        setState(() {
                                          racaSelecionadaId = value;
                                        });
                                        field.didChange(value);
                                      },
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ✅ Data de nascimento
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
                                final ano = int.tryParse(value.trim());
                                if (ano == null) {
                                  return 'Digite apenas números';
                                }
                                if (ano < 0) {
                                  return 'O ano não pode ser negativo';
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
                                labelText: 'Mês - opcional',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final mes = int.tryParse(value.trim());
                                if (mes == null) {
                                  return 'Digite apenas números';
                                }
                                if (mes < 1 || mes > 12) {
                                  return 'Informe um mês entre 1 e 12';
                                }
                                return null;
                              },
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
                                labelText: 'Dia - opcional',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return null;
                                }
                                final dia = int.tryParse(value.trim());
                                if (dia == null) {
                                  return 'Digite apenas números';
                                }
                                if (dia < 1 || dia > 31) {
                                  return 'Informe um dia entre 1 e 31';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ✅ Peso - Enter vai para Altura
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

                          final peso = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );
                          if (peso == null) {
                            return 'Digite apenas números';
                          }
                          if (peso < 0) {
                            return 'O peso não pode ser negativo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // ✅ Altura - Enter vai para o botão
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return null;
                          }

                          final altura = double.tryParse(
                            value.trim().replaceAll(',', '.'),
                          );

                          if (altura == null) {
                            return 'Digite apenas números';
                          }
                          if (altura < 0) {
                            return 'Altura não pode ser negativa';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Botão Cadastrar
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
                                  'Cadastrar',
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
