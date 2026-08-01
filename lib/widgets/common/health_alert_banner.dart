import 'package:flutter/material.dart';

class HealthAlertBanner {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: HealthAlertBannerWidget(
            message: message,
            onClose: () {
              if (overlayEntry.mounted) {
                overlayEntry.remove();
              }
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class HealthAlertInfo {
  final String mainAlert;
  final String? percentageInfo;

  HealthAlertInfo({required this.mainAlert, this.percentageInfo});

  factory HealthAlertInfo.fromMessage(String message) {
    final pesoMatch = RegExp(
      r'(Peso está \d+%[^.]*(?:\.|$))',
    ).firstMatch(message);

    if (pesoMatch != null) {
      final percentageInfo = pesoMatch.group(1)!.trim();
      var mainAlert = message.replaceFirst(pesoMatch.group(1)!, '').trim();
      if (mainAlert.startsWith('ALERTA DE SAÚDE:')) {
        mainAlert = mainAlert.replaceFirst('ALERTA DE SAÚDE:', '').trim();
      }
      return HealthAlertInfo(
        mainAlert: mainAlert,
        percentageInfo: percentageInfo,
      );
    }

    var cleanMessage = message;
    if (cleanMessage.startsWith('ALERTA DE SAÚDE:')) {
      cleanMessage = cleanMessage.replaceFirst('ALERTA DE SAÚDE:', '').trim();
    }
    return HealthAlertInfo(mainAlert: cleanMessage, percentageInfo: null);
  }
}

class HealthAlertBannerWidget extends StatefulWidget {
  final String message;
  final VoidCallback onClose;

  const HealthAlertBannerWidget({
    super.key,
    required this.message,
    required this.onClose,
  });

  @override
  State<HealthAlertBannerWidget> createState() =>
      _HealthAlertBannerWidgetState();
}

class _HealthAlertBannerWidgetState extends State<HealthAlertBannerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late HealthAlertInfo _alertInfo;

  static const autoDismissDuration = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _alertInfo = HealthAlertInfo.fromMessage(widget.message);

    _controller = AnimationController(
      duration: autoDismissDuration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.forward();

    // ✅ Auto-dismiss após 15 segundos
    Future.delayed(autoDismissDuration, () {
      if (mounted) {
        widget.onClose();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // ✅ Brilho laranja externo (glow)
            BoxShadow(
              color: const Color(0xFFF97316).withOpacity(0.35),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            // Sombra sutil para profundidade
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Barra única contínua
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 6),
                  painter: ProgressBarPainter(
                    progress: _progressAnimation.value,
                    color: const Color(0xFFF97316),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Ícone de alerta com "raios"
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF97316),
                        size: 44,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 8,
                    child: Transform.rotate(
                      angle: 0.4,
                      child: Container(
                        width: 10,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 0,
                    child: Transform.rotate(
                      angle: 0.8,
                      child: Container(
                        width: 12,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    right: -4,
                    child: Transform.rotate(
                      angle: 1.2,
                      child: Container(
                        width: 8,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            const Text(
              'Atenção!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Alerta principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDD5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Color(0xFFF97316),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'ALERTA DE SAÚDE: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF97316),
                                fontSize: 13.5,
                              ),
                            ),
                            TextSpan(
                              text: _alertInfo.mainAlert,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 13.5,
                                height: 1.5,
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
            const SizedBox(height: 10),

            // Card 2: Percentual
            if (_alertInfo.percentageInfo != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.scale,
                        color: Color(0xFFA855F7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPercentageText(_alertInfo.percentageInfo!),
                    ),
                  ],
                ),
              ),
            if (_alertInfo.percentageInfo != null) const SizedBox(height: 10),

            // Card 3: Dica motivacional
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDFA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Color(0xFF0D9488),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cuidar da saúde do seu pet é garantir mais qualidade de vida para ele.',
                      style: TextStyle(
                        color: Color(0xFF0F766E),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botão OK
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.onClose,
                icon: const Icon(Icons.check, size: 20),
                label: const Text(
                  'OK, entendi!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageText(String text) {
    final match = RegExp(r'(\d+)%').firstMatch(text);
    if (match != null) {
      final number = match.group(1)!;
      final before = text.substring(0, match.start);
      final after = text.substring(match.end);
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: before,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
            ),
            TextSpan(
              text: number,
              style: const TextStyle(
                color: Color(0xFFF97316),
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
            TextSpan(
              text: '%$after',
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
            ),
          ],
        ),
      );
    }
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
    );
  }
}

// ✅ Pintor da barra única contínua
class ProgressBarPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressBarPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Fundo cinza
    final bgPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(3),
      ),
      bgPaint,
    );

    // Barra de progresso
    final progressPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width * progress, size.height),
        const Radius.circular(3),
      ),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressBarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
