import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EmailFormWidget extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSendEmail;

  const EmailFormWidget({
    super.key,
    required this.emailController,
    required this.onSendEmail,
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
          'Recuperar senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),

        // Descrição
        Text(
          'Digite seu e-mail para receber\ninstruções de como redefinir sua senha.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Campo E-mail
        TextField(
          controller: emailController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSendEmail(),
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF0D9488),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: 'seu@email.com',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        // Botão Enviar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onSendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enviar instruções',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou', style: TextStyle(color: Colors.grey.shade500)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 24),

        // Botão Voltar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar para o login'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: Color(0xFF0D9488)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
