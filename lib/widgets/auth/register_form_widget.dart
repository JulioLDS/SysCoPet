import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../screens/auth/legal_screen.dart';

class RegisterFormWidget extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final FocusNode nameFocusNode;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode confirmPasswordFocusNode;
  final FocusNode checkboxFocusNode;
  final VoidCallback onRegister;
  final VoidCallback onGoogleRegister;
  final bool isLoading;

  const RegisterFormWidget({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.nameFocusNode,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.confirmPasswordFocusNode,
    required this.checkboxFocusNode,
    required this.onRegister,
    required this.onGoogleRegister,
    required this.isLoading,
  });

  @override
  // ✅ Mude de _RegisterFormWidgetState para RegisterFormWidgetState
  State<RegisterFormWidget> createState() => RegisterFormWidgetState();
}

// ✅ Classe pública (sem o _)
class RegisterFormWidgetState extends State<RegisterFormWidget> {
  bool _agreeTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ✅ Getter público para verificar se os termos foram aceitos
  bool get isTermsAccepted => _agreeTerms;

  Route _buildLightRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero, // ✅ Sem animação
      reverseTransitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crie uma conta ',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            SvgPicture.asset('assets/icons/patas.svg', height: 30, width: 30),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Cadastre-se para começar a cuidar do seu pet.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 15),

        // Campo Nome
        TextField(
          controller: widget.nameController,
          focusNode: widget.nameFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(widget.emailFocusNode),
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

        // Campo E-mail
        TextField(
          controller: widget.emailController,
          focusNode: widget.emailFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(widget.passwordFocusNode),
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

        // Campo Senha com visibilidade
        TextField(
          controller: widget.passwordController,
          focusNode: widget.passwordFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => FocusScope.of(
            context,
          ).requestFocus(widget.confirmPasswordFocusNode),
          obscureText: _obscurePassword,
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

        // Campo Confirmar Senha com visibilidade
        TextField(
          controller: widget.confirmPasswordController,
          focusNode: widget.confirmPasswordFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              FocusScope.of(context).requestFocus(widget.checkboxFocusNode);
            });
          },
          obscureText: _obscureConfirmPassword,
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

        // Checkbox dos Termos
        Focus(
          focusNode: widget.checkboxFocusNode,
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
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'Eu concordo com os '),
                            TextSpan(
                              text: 'Termos de Uso',
                              style: const TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    _buildLightRoute(
                                      LegalScreen(
                                        title: 'Termos de Uso',
                                        content: [
                                          const TextSpan(
                                            text: '1. Aceitação dos Termos\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Ao acessar e usar o aplicativo PetSaúde, você aceita e concorda em estar vinculado aos termos e provisões deste acordo.\n\n',
                                          ),
                                          const TextSpan(
                                            text: '2. Uso do Serviço\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Este aplicativo destina-se a auxiliar no gerenciamento de saúde de animais de estimação. O usuário é responsável por manter a precisão das informações inseridas.\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                '3. Isenção de Responsabilidade\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'O PetSaúde não substitui o aconselhamento veterinário profissional. Em caso de emergência médica, procure sempre um veterinário qualificado.\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                '4. Propriedade Intelectual\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Todo o conteúdo, marca e design do PetSaúde são propriedade exclusiva da empresa.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: ' e '),
                            TextSpan(
                              text: 'Política de Privacidade',
                              style: const TextStyle(
                                color: Color(0xFF0D9488),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    _buildLightRoute(
                                      LegalScreen(
                                        title: 'Política de Privacidade',
                                        content: [
                                          const TextSpan(
                                            text: '1. Coleta de Dados\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Coletamos informações que você nos fornece diretamente, como nome, e-mail e dados de saúde do seu pet.\n\n',
                                          ),
                                          const TextSpan(
                                            text: '2. Uso das Informações\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Utilizamos seus dados para personalizar sua experiência, enviar lembretes de vacinas e melhorar nossos serviços.\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                '3. Compartilhamento de Dados\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Nunca vendemos seus dados pessoais. Podemos compartilhar informações apenas com parceiros veterinários quando necessário para o atendimento.\n\n',
                                          ),
                                          const TextSpan(
                                            text: '4. Segurança\n\n',
                                          ),
                                          const TextSpan(
                                            text:
                                                'Implementamos medidas de segurança para proteger suas informações contra acesso não autorizado.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
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

        // Botão Cadastrar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: widget.isLoading
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
          onPressed: widget.onGoogleRegister,
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
