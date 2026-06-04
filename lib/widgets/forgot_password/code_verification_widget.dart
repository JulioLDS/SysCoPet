import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CodeVerificationWidget extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final bool canResend;
  final int secondsRemaining;

  const CodeVerificationWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onVerify,
    required this.onResend,
    required this.canResend,
    required this.secondsRemaining,
  });

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
          'Verificar Código',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Descrição
        Text(
          'Digite o código de 6 dígitos\nenviado para seu e-mail.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Inputs de código
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                textInputAction: index == 5
                    ? TextInputAction.done
                    : TextInputAction.next,
                obscureText: false,
                enableInteractiveSelection: false,
                enableSuggestions: false,
                autocorrect: false,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                  }
                  if (index == 5 && value.isNotEmpty) {
                    final code = controllers.map((c) => c.text).join();
                    if (code.length == 6) {
                      Future.delayed(
                        const Duration(milliseconds: 300),
                        onVerify,
                      );
                    }
                  }
                },
                onSubmitted: (value) {
                  if (index < 5 && value.isNotEmpty) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Botão Verificar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Verificar Código',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Link Reenviar Código
        TextButton(
          onPressed: canResend ? onResend:null,
          child:  Text(
            canResend ?
            'Reenviar Código'
            :'Reenviar em ${secondsRemaining}s',
            style: TextStyle(
              color: Color(0xFF0D9488),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
