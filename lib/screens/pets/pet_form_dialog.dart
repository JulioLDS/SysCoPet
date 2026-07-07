import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/models/raca_model.dart';
import 'package:syscopet/services/pet_service.dart';

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
      if (!mounted) return;
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

  Future<void> _salvarPet() async {
    if (!_formKey.currentState!.validate()) {
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
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro'),
          content: Text(erro),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

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

                      // ✅ Espécie - Após selecionar, vai para Raça ou Ano
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
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'cao', child: Text('Cão')),
                          DropdownMenuItem(value: 'gato', child: Text('Gato')),
                          DropdownMenuItem(
                            value: 'outro',
                            child: Text('Outro'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            especieSelecionada = value;
                            racaSelecionadaId = null;
                            racas = [];
                          });

                          if (value == 'cao' || value == 'gato') {
                            carregarRacas(value!);
                            // ✅ Após carregar raças, o foco vai para o campo de raça
                            // (isso já está sendo feito no carregarRacas)
                          } else {
                            // Se for "outro", pula direto para o ano
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                FocusScope.of(context).requestFocus(_anoFocus);
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

                      // ✅ Raça - Enter vai para Ano
                      // ✅ Raça - Após selecionar, vai para Ano
                      DropdownButtonFormField<int>(
                        value: racaSelecionadaId,
                        focusNode: _racaFocus,
                        decoration: InputDecoration(
                          labelText: carregandoRacas
                              ? 'Carregando raças...'
                              : 'Raça',
                          prefixIcon: const Icon(
                            Icons.pets_outlined,
                            color: Color(0xFF0D9488),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: racas.map((raca) {
                          return DropdownMenuItem<int>(
                            value: raca.idRaca,
                            child: Text(raca.nome),
                          );
                        }).toList(),
                        onChanged:
                            especieSelecionada == null ||
                                especieSelecionada == 'outro' ||
                                carregandoRacas
                            ? null
                            : (value) {
                                setState(() {
                                  racaSelecionadaId = value;
                                });

                                // ✅ Após selecionar a raça, vai para o campo de ano
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
                          final peso = double.tryParse(value.trim());
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
                          final altura = double.tryParse(value.trim());
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
