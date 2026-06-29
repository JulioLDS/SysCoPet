import 'package:flutter/material.dart';

class CustomSnackbar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, SnackbarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, SnackbarType.warning);
  }

  static void _show(BuildContext context, String message, SnackbarType type) {
    final overlay = Overlay.of(context);
    bool isRemoved = false;

    // ✅ Declara a variável primeiro
    late OverlayEntry overlayEntry;

    // ✅ Depois cria o OverlayEntry
    overlayEntry = OverlayEntry(
      builder: (context) => _SnackbarWidget(
        message: message,
        type: type,
        onDismiss: () {
          if (!isRemoved) {
            isRemoved = true;
            overlayEntry.remove();
          }
        },
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss após 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (!isRemoved) {
        isRemoved = true;
        overlayEntry.remove();
      }
    });
  }
}

enum SnackbarType { success, error, warning }

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Inicia animação de saída após 2.5s
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _animationController.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF0D9488);
      case SnackbarType.error:
        return const Color(0xFFEF4444);
      case SnackbarType.warning:
        return const Color(0xFFF59E0B);
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning_amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  // ✅ Centraliza o container
                  child: Container(
                    width: 420,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: _backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _backgroundColor.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_icon, color: Colors.white, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            _animationController.reverse().then((_) {
                              widget.onDismiss();
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
