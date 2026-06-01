import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syscopet/providers/auth_provider.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ✅ FocusNodes
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  final checkboxFocusNode = FocusNode();

  bool _agreeTerms = false;

  // ✅ Controles de visibilidade das senhas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    checkboxFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aceite os termos de uso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha todos os campos')));
      return;
    }
    if (passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha mínima de 6 caracteres')),
      );
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Senhas não coincidem')));
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.register(
      nome: nameController.text,
      email: emailController.text,
      senha: passwordController.text,
    );
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Usuário criado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
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
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 15),

        // ✅ Campo Nome
        TextField(
          controller: nameController,
          focusNode: nameFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(emailFocusNode),
          decoration: InputDecoration(
            labelText: 'Nome completo',
            prefixIcon: const Icon(
              Icons.person_outline,
              color: Color(0xFF0D9488),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Campo E-mail
        TextField(
          controller: emailController,
          focusNode: emailFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(passwordFocusNode),
          decoration: InputDecoration(
            labelText: 'E-mail',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: Color(0xFF0D9488),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // ✅ Campo Senha com visibilidade
        TextField(
          controller: passwordController,
          focusNode: passwordFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(confirmPasswordFocusNode),
          obscureText: _obscurePassword, // ✅ Controlado pelo estado
          decoration: InputDecoration(
            labelText: 'Senha',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFF0D9488),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Campo Confirmar Senha com visibilidade
        TextField(
          controller: confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              FocusScope.of(context).requestFocus(checkboxFocusNode);
            });
          },
          obscureText: _obscureConfirmPassword, // ✅ Controlado pelo estado
          decoration: InputDecoration(
            labelText: 'Confirmar senha',
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
                setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword,
                );
              },
              focusNode: FocusNode(skipTraversal: true),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        const SizedBox(height: 16),

        // ✅ Checkbox dos Termos
        Focus(
          focusNode: checkboxFocusNode,
          canRequestFocus: true,
          skipTraversal: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _agreeTerms = !_agreeTerms),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    onChanged: (value) =>
                        setState(() => _agreeTerms = value ?? false),
                    activeColor: const Color(0xFF0D9488),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
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
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ✅ Botão Cadastrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: authProvider.isLoading ? null : () => _handleRegister(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 15),

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
        const SizedBox(height: 15),

        OutlinedButton.icon(
          onPressed: () {},
          icon: Image.asset(
            'assets/icons/google.png',
            height: 24,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.g_mobiledata,
              size: 24,
              color: Color(0xFF0D9488),
            ),
          ),
          label: const Text('Continuar com Google'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: Color(0xFF0D9488)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
