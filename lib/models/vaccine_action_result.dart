class VaccineActionResult {
  final bool sucesso;
  final String? erro;
  final List<String> avisos;
  final DateTime? proximoReforco;

  VaccineActionResult({
    required this.sucesso,
    this.erro,
    this.avisos = const [],
    this.proximoReforco,
  });
}