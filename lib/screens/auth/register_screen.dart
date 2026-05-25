import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggle; // Callback para voltar para Login

  const RegisterScreen({super.key, required this.onToggle});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Row(
          children: [
            Text(
              'Cadastrar',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D9488),
              ),
            ),
            const Spacer(),
            TextButton(onPressed: widget.onToggle, child: const Text('Entrar')),
          ],
        ),
        const Divider(height: 32),

        const SizedBox(height: 24),

        // Boas-vindas
        Text(
          'Criar uma conta 🐾',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Cadastre-se para começar a cuidar do seu pet.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 32),

        // Campos de Input
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nome completo',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),   
          ),
          controller: nameController,

        ),
        const SizedBox(height: 16),

        TextField(
          decoration: const InputDecoration(
            labelText: 'E-mail',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          controller: emailController,
        ),
        const SizedBox(height: 16),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Senha',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_outlined),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          controller: passwordController,
        ),
        const SizedBox(height: 16),

        TextField(
          decoration: const InputDecoration(
            labelText: 'Confirmar senha',
            prefixIcon: Icon(Icons.lock_outline),
            suffixIcon: Icon(Icons.visibility_outlined),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          controller: passwordController,
        ),
        const SizedBox(height: 16),

        // Checkbox Termos
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: false, // TODO: Estado do checkbox
              onChanged: (value) {},
              activeColor: const Color(0xFF0D9488),
            ),
            Expanded(
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  children: [
                    TextSpan(text: 'Eu concordo com os '),
                    TextSpan(
                      text: 'Termos de Uso',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' e '),
                    TextSpan(
                      text: 'Política de Privacidade',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Botão Cadastrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading
              ? null
             :() async {
              // TODO: Implementar cadastro

              final result = await authProvider.register(
                          nome: nameController.text,
                          email: emailController.text,
                          senha: passwordController.text,
                        );

                        if (!mounted) return;

                        if (result != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result)),
                          );

                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Usuário criado com sucesso'),
                          ),
                        );

                        Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: authProvider.isLoading
            ? const CircularProgressIndicator()
            :const Text(
              'Cadastrar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('ou', style: TextStyle(color: Colors.grey[600])),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),

        // Botões Sociais
        OutlinedButton.icon(
          onPressed: () {},
            icon: const Icon(
              Icons.g_mobiledata,
              size: 24,
            ),
            label: const Text('Continuar com Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),  
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.apple, size: 24),
          label: const Text('Continuar com Apple'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }
}
