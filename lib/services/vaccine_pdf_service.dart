import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pet_model.dart';
import '../models/vaccine_calendar_model.dart';

class VaccinePdfService {
  static const PdfColor _corTeal = PdfColor.fromInt(0xFF0D9488);
  static const PdfColor _corTealClaro = PdfColor.fromInt(0xFFCCFBF1);
  static const PdfColor _corVerde = PdfColor.fromInt(0xFF059669);
  static const PdfColor _corVerdeClaro = PdfColor.fromInt(0xFFD1FAE5);
  static const PdfColor _corLaranja = PdfColor.fromInt(0xFFF59E0B);
  static const PdfColor _corLaranjaClaro = PdfColor.fromInt(0xFFFEF3C7);
  static const PdfColor _corVermelho = PdfColor.fromInt(0xFFEF4444);
  static const PdfColor _corVermelhoClaro = PdfColor.fromInt(0xFFFEF2F2);
  static const PdfColor _corAzul = PdfColor.fromInt(0xFF3B82F6);
  static const PdfColor _corAzulClaro = PdfColor.fromInt(0xFFDBEAFE);
  static const PdfColor _corCinza = PdfColor.fromInt(0xFF64748B);
  static const PdfColor _corCinzaClaro = PdfColor.fromInt(0xFFF1F5F9);
  static const PdfColor _corEscuro = PdfColor.fromInt(0xFF1E293B);

  static Future<Uint8List> gerarCarteiraVacinaPdf({
    required PetModel pet,
    required List<VaccineCalendarModel> calendario,
  }) async {
    final pdf = pw.Document();

    final aplicadas = calendario.where((v) => v.status == 'aplicada').toList();
    final pendentes = calendario.where((v) => v.status == 'pendente').toList()
      ..sort((a, b) => a.dataPrevista.compareTo(b.dataPrevista));
    final puladas = calendario.where((v) => v.status == 'pulada').toList();

    String formatarData(DateTime? data) {
      if (data == null) return '-';
      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    }

    String textoDose(VaccineCalendarModel dose) {
      if (dose.tipo == 'reforco') return 'Reforço';
      return 'Dose ${dose.doseNumero}';
    }

    String calcularIdade(DateTime? nascimento) {
      if (nascimento == null) return 'Não informada';
      final hoje = DateTime.now();
      int anos = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        anos--;
      }
      return '$anos ano${anos == 1 ? '' : 's'}';
    }

    DateTime? _parseData(String? data) {
      if (data == null || data.isEmpty) return null;
      try {
        return DateTime.parse(data.split('T').first);
      } catch (_) {
        return null;
      }
    }

    String dataGeracao() {
      final agora = DateTime.now();
      return '${agora.day.toString().padLeft(2, '0')}/'
          '${agora.month.toString().padLeft(2, '0')}/'
          '${agora.year} às '
          '${agora.hour.toString().padLeft(2, '0')}:'
          '${agora.minute.toString().padLeft(2, '0')}';
    }

    pw.Widget badge(String texto, PdfColor corFundo, PdfColor corTexto) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(
          color: corFundo,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          texto,
          style: pw.TextStyle(
            color: corTexto,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        header: (context) => pw.Container(
          height: 50,
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF0D9488),
            borderRadius: pw.BorderRadius.only(
              topLeft: pw.Radius.circular(8),
              topRight: pw.Radius.circular(8),
            ),
          ),
          padding: const pw.EdgeInsets.symmetric(horizontal: 20),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '4UPet',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Carteira de Vacinação',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 20),
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _corCinzaClaro,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Documento gerado pelo aplicativo 4UPet em ${dataGeracao()}',
                style: pw.TextStyle(fontSize: 8, color: _corCinza),
              ),
              pw.Text(
                'Cuidando de quem você ama!',
                style: pw.TextStyle(fontSize: 8, color: _corTeal),
              ),
            ],
          ),
        ),
        build: (context) => [
          // ✅ DADOS DO PET
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _corTealClaro,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: _corTeal, width: 1),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    color: _corTeal,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      pet.nome.substring(0, 1).toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        pet.nome,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: _corEscuro,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Espécie: ',
                            style: pw.TextStyle(fontSize: 10, color: _corCinza),
                          ),
                          pw.Text(
                            pet.especie,
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: _corEscuro,
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Text(
                            'Idade: ',
                            style: pw.TextStyle(fontSize: 10, color: _corCinza),
                          ),
                          pw.Text(
                            calcularIdade(_parseData(pet.dataNascimento)),
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: _corEscuro,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // ✅ RESUMO ESTATÍSTICO
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _corCinzaClaro,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _statBox('Aplicadas', '${aplicadas.length}', _corVerde),
                _statBox('Pendentes', '${pendentes.length}', _corLaranja),
                _statBox('Puladas', '${puladas.length}', _corCinza),
                _statBox('Total', '${calendario.length}', _corTeal),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // ✅ VACINAS APLICADAS
          pw.Text(
            'Vacinas Aplicadas',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _corTeal,
            ),
          ),
          pw.SizedBox(height: 10),

          if (aplicadas.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _corCinzaClaro,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'Nenhuma vacina aplicada registrada.',
                style: pw.TextStyle(color: _corCinza, fontSize: 11),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: _corTealClaro, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF0D9488),
                  ),
                  children: [
                    _headerCell('Vacina'),
                    _headerCell('Dose'),
                    _headerCell('Data Aplicação'),
                    _headerCell('Status'),
                  ],
                ),
                ...aplicadas.map((dose) {
                  return pw.TableRow(
                    children: [
                      _dataCell(dose.vacinaNome, bold: true),
                      _dataCell(textoDose(dose)),
                      _dataCell(formatarData(dose.dataAplicacao)),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: badge('Em dia', _corVerdeClaro, _corVerde),
                      ),
                    ],
                  );
                }),
              ],
            ),

          pw.SizedBox(height: 24),

          // ✅ PRÓXIMAS VACINAS
          pw.Text(
            'Próximas Vacinas',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: _corLaranja,
            ),
          ),
          pw.SizedBox(height: 10),

          if (pendentes.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: _corCinzaClaro,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'Nenhuma vacina pendente. Seu pet está em dia!',
                style: pw.TextStyle(color: _corVerde, fontSize: 11),
              ),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: _corLaranjaClaro, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFFF59E0B),
                  ),
                  children: [
                    _headerCell('Vacina', cor: PdfColors.white),
                    _headerCell('Dose', cor: PdfColors.white),
                    _headerCell('Data Prevista', cor: PdfColors.white),
                    _headerCell('Tipo', cor: PdfColors.white),
                  ],
                ),
                ...pendentes.map((dose) {
                  final agora = DateTime.now();
                  final diasRestantes = dose.dataPrevista
                      .difference(agora)
                      .inDays;
                  final estaAtrasada = diasRestantes < 0;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: estaAtrasada ? _corVermelhoClaro : PdfColors.white,
                    ),
                    children: [
                      _dataCell(dose.vacinaNome, bold: true),
                      _dataCell(textoDose(dose)),
                      _dataCell(
                        formatarData(dose.dataPrevista),
                        cor: estaAtrasada ? _corVermelho : _corEscuro,
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: _badgeTipo(dose, badge),
                      ),
                    ],
                  );
                }),
              ],
            ),

          // ✅ VACINAS PULADAS
          if (puladas.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text(
              'Vacinas Puladas',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _corCinza,
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: _corCinzaClaro, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: _corCinza),
                  children: [
                    _headerCell('Vacina', cor: PdfColors.white),
                    _headerCell('Dose', cor: PdfColors.white),
                    _headerCell('Data Prevista', cor: PdfColors.white),
                  ],
                ),
                ...puladas.map((dose) {
                  return pw.TableRow(
                    children: [
                      _dataCell(dose.vacinaNome),
                      _dataCell(textoDose(dose)),
                      _dataCell(formatarData(dose.dataPrevista)),
                    ],
                  );
                }),
              ],
            ),
          ],

          pw.SizedBox(height: 30),

          // ✅ MENSAGEM FINAL
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: _corTealClaro,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: _corTeal, width: 1),
            ),
            child: pw.Row(
              children: [
                pw.Container(
                  width: 24,
                  height: 24,
                  decoration: pw.BoxDecoration(
                    color: _corTeal,
                    shape: pw.BoxShape.circle,
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      '-',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(width: 12),
                pw.Expanded(
                  child: pw.Text(
                    'Mantenha o calendário de vacinas em dia para garantir uma vida longa e saudável para seu pet.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: _corTeal,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _headerCell(String texto, {PdfColor? cor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          color: cor ?? PdfColors.white,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _dataCell(String texto, {bool bold = false, PdfColor? cor}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        texto,
        style: pw.TextStyle(
          color: cor ?? _corEscuro,
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _statBox(String label, String valor, PdfColor cor) {
    return pw.Column(
      children: [
        pw.Text(
          valor,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: cor,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _corCinza)),
      ],
    );
  }

  static pw.Widget _badgeTipo(
    VaccineCalendarModel dose,
    pw.Widget Function(String, PdfColor, PdfColor) badge,
  ) {
    if (dose.obrigatoria) {
      return badge('Obrigatória', _corVermelhoClaro, _corVermelho);
    }
    if (dose.essencial) {
      return badge('Essencial', _corAzulClaro, _corAzul);
    }
    return badge('Opcional', _corCinzaClaro, _corCinza);
  }
}
