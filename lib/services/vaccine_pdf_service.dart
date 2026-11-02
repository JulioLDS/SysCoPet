import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pet_model.dart';
import '../models/vaccine_calendar_model.dart';

class VaccinePdfService {
  static Future<Uint8List> gerarCarteiraVacinaPdf({
    required PetModel pet,
    required List<VaccineCalendarModel> calendario,
  }) async {
    final pdf = pw.Document();

    final aplicadas = calendario
        .where((v) => v.status == 'aplicada')
        .toList();

    final proximas = calendario
        .where((v) => v.status == 'pendente')
        .toList()
      ..sort(
        (a, b) =>
            a.dataPrevista.compareTo(b.dataPrevista),
      );

    String formatarData(DateTime? data) {
      if (data == null) return '-';

      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    }

    String textoDose(
      VaccineCalendarModel dose,
    ) {
      if (dose.tipo == 'reforco') {
        return 'Reforço';
      }

      return 'Dose ${dose.doseNumero}';
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),

        build: (context) => [
          pw.Center(
            child: pw.Text(
              'Carteira de Vacinação',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          pw.SizedBox(height: 24),

          pw.Text(
            'Dados do Pet',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            'Nome: ${pet.nome}',
          ),

          pw.Text(
            'Espécie: ${pet.especie}',
          ),

          if (pet.dataNascimento != null)
            pw.Text(
              'Nascimento: ${pet.dataNascimento}',
            ),

          pw.SizedBox(height: 24),

          pw.Text(
            'Vacinas Aplicadas',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          if (aplicadas.isEmpty)
            pw.Text(
              'Nenhuma vacina aplicada registrada.',
            )
          else
            pw.Table.fromTextArray(
              headers: [
                'Vacina',
                'Dose',
                'Aplicação',
              ],
              data: aplicadas.map((dose) {
                return [
                  dose.vacinaNome,
                  textoDose(dose),
                  formatarData(
                    dose.dataAplicacao,
                  ),
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 24),

          pw.Text(
            'Próximas Vacinas',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.SizedBox(height: 10),

          if (proximas.isEmpty)
            pw.Text(
              'Nenhuma vacina pendente.',
            )
          else
            pw.Table.fromTextArray(
              headers: [
                'Vacina',
                'Dose',
                'Prevista',
                'Tipo',
              ],
              data: proximas.map((dose) {
                return [
                  dose.vacinaNome,
                  textoDose(dose),
                  formatarData(
                    dose.dataPrevista,
                  ),
                  dose.obrigatoria
                      ? 'Obrigatória'
                      : dose.essencial
                          ? 'Essencial'
                          : '-',
                ];
              }).toList(),
            ),

          pw.SizedBox(height: 30),

          pw.Divider(),

          pw.Text(
            'Documento gerado pelo aplicativo 4U Pet.',
            style: const pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }
}