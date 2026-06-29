import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResetPasswordWidget extends StatefulWidget {
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onReset;

  const ResetPasswordWidget({
    super.key,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onReset,
  });

  @override
  State<ResetPasswordWidget> createState() => _ResetPasswordWidgetState();
}

class _ResetPasswordWidgetState extends State<ResetPasswordWidget> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ícone
        Container(
          width: 120,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Transform.translate(
            offset: const Offset(3, 3),
            child: SvgPicture.asset(
              'assets/icons/envelope.svg',
              width: 40,
              height: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Título
        Text(
          'Redefinir Senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Descrição
        Text(
          'Crie uma nova senha segura\npara sua conta.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Campo Nova Senha COM OLHO
        TextField(
          controller: widget.newPasswordController,
          obscureText: _obscureNewPassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Nova Senha',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF0D9488),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureNewPassword = !_obscureNewPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'Mínimo 6 caracteres',
          ),
        ),
        const SizedBox(height: 16),

        // Campo Confirmar Senha COM OLHO
        TextField(
          controller: widget.confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onReset(),
          decoration: InputDecoration(
            labelText: 'Confirmar Nova Senha',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF0D9488),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 24),

        // Botão Redefinir
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onReset,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Redefinir Senha',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
